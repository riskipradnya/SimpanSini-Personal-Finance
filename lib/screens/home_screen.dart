import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

// Ganti dengan path yang benar sesuai struktur proyek Anda
import '../database/transaction_service.dart';
import '../database/auth_service.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;
  // PERBAIKAN: Menambahkan callback untuk navigasi
  final VoidCallback onViewAllPressed;

  const HomeScreen({
    super.key,
    required this.refreshNotifier,
    required this.onViewAllPressed,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User';
  String? _userProfileImage;
  bool _isLoading = true;
  List<Transaction> _allTransactions = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  // Variabel untuk menyimpan data grafik yang sudah diproses
  late Map<String, List<FlSpot>> _chartData;

  @override
  void initState() {
    super.initState();
    widget.refreshNotifier.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    await _loadUserData();
    await _loadTransactionsAndProcessChart();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserService().getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          _userName = user.name;
          _userProfileImage = user.profileImage;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Fallback jika terjadi error
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _userName = prefs.getString('user_name') ?? 'User';
          _userProfileImage = prefs.getString('profile_image');
        });
      }
    }
  }

  Future<void> _loadTransactionsAndProcessChart() async {
    try {
      final now = DateTime.now();
      // Mengatur tanggal awal adalah awal hari (00:00), 6 hari yang lalu. Total 7 hari.
      final startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

      final allTransactions = await TransactionService().getAllTransactions();

      final weeklyTransactions = allTransactions.where((transaction) {
        return !transaction.date.isBefore(startDate) &&
               transaction.date.isBefore(now.add(const Duration(days: 1)));
      }).toList();

      // Urutkan dari yang terbaru ke terlama
      weeklyTransactions.sort((a, b) => b.date.compareTo(a.date));

      // Proses semua data dalam satu fungsi
      _processData(weeklyTransactions, startDate);

    } catch (e) {
      print('Error loading transactions: $e');
      if (mounted) {
        setState(() {
          _allTransactions = [];
          _totalIncome = 0.0;
          _totalExpense = 0.0;
          _chartData = {'income': [], 'expense': []};
        });
      }
    }
  }

  // Fungsi terpusat untuk memproses data transaksi (lebih efisien)
  void _processData(List<Transaction> transactions, DateTime startDate) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    Map<int, double> dailyIncome = { for (var i = 0; i < 7; i++) i: 0.0 };
    Map<int, double> dailyExpense = { for (var i = 0; i < 7; i++) i: 0.0 };

    for (var transaction in transactions) {
      // Hitung total untuk summary cards
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else if (transaction.type == 'expense') {
        totalExpense += transaction.amount;
      }

      // Kelompokkan per hari untuk data grafik
      final dayIndex = transaction.date.difference(startDate).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        if (transaction.type == 'income') {
          dailyIncome[dayIndex] = (dailyIncome[dayIndex] ?? 0) + transaction.amount;
        } else {
          dailyExpense[dayIndex] = (dailyExpense[dayIndex] ?? 0) + transaction.amount;
        }
      }
    }

    if (mounted) {
      setState(() {
        _allTransactions = transactions;
        _totalIncome = totalIncome;
        _totalExpense = totalExpense;
        _chartData = {
          'income': _mapToFlSpots(dailyIncome),
          'expense': _mapToFlSpots(dailyExpense),
        };
      });
    }
  }

  List<FlSpot> _mapToFlSpots(Map<int, double> dailyTotals) {
    return dailyTotals.entries.map((entry) {
      final scaledAmount = entry.value / 100000; // Skala nominal untuk visualisasi
      return FlSpot(entry.key.toDouble(), scaledAmount);
    }).toList();
  }

  String _getDateRangeText() {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 6));
    return '${DateFormat('d MMM', 'id_ID').format(oneWeekAgo)} - ${DateFormat('d MMM yyyy', 'id_ID').format(now)}';
  }

  // PERBAIKAN: Membuat label hari dinamis sesuai data 7 hari terakhir
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = GoogleFonts.manrope(
      color: Colors.grey[700],
      fontWeight: FontWeight.w500,
      fontSize: 10,
    );
    
    final int index = value.toInt();
    if (index >= 0 && index < 7) {
      // Hitung tanggal berdasarkan indeks (0 = 6 hari lalu, 6 = hari ini)
      final day = DateTime.now().subtract(Duration(days: 6 - index));
      // Format untuk mendapatkan nama hari (Jum, Sab, Min, Sen, dll.)
      final dayName = DateFormat('E', 'id_ID').format(day);
      
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(dayName, style: style),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildChartSection(),
                          const SizedBox(height: 16),
                          _buildChartLegend(),
                          const SizedBox(height: 24),
                          _buildSummaryCards(),
                          const SizedBox(height: 24),
                          _buildRecentTransactions(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF8F9FD),
      pinned: true,
      elevation: 0,
      title: Row(
        children: [
          _buildProfileAvatar(),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang,',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                _userName,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => print("Notification tapped"),
          icon: Icon(
            Icons.notifications_none_rounded,
            color: Colors.grey[800],
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    if (_userProfileImage != null && _userProfileImage!.isNotEmpty) {
      final imageFile = File(_userProfileImage!);
      if (imageFile.existsSync()) {
        return CircleAvatar(
          radius: 22,
          backgroundImage: FileImage(imageFile),
        );
      }
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, color: Colors.grey[700], size: 30),
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Statistik Mingguan",
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getDateRangeText(),
          style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        SizedBox(height: 200, child: LineChart(_mainChartData())),
      ],
    );
  }

  LineChartData _mainChartData() {
    double maxY = _getMaxYValue();
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY > 0 ? maxY / 4 : 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 48,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: maxY,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (FlSpot spot) => Colors.black.withOpacity(0.8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final amount = (spot.y * 100000).toInt();
              final formatter = NumberFormat.currency(
                  locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

              final day = DateTime.now().subtract(Duration(days: 6 - spot.x.toInt()));
              final dayName = DateFormat('EEEE', 'id_ID').format(day);

              return LineTooltipItem(
                '$dayName\n${formatter.format(amount)}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        _buildLineChartBarData(
          spots: _chartData['income'] ?? [],
          gradient: const LinearGradient(colors: [Color(0xff23b6e6), Color(0xff02d39a)]),
        ),
        _buildLineChartBarData(
          spots: _chartData['expense'] ?? [],
          gradient: const LinearGradient(colors: [Color(0xfff12711), Color(0xfff5af19)]),
        ),
      ],
    );
  }

  LineChartBarData _buildLineChartBarData(
      {required List<FlSpot> spots, required Gradient gradient}) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      gradient: gradient,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: gradient.colors.map((color) => color.withOpacity(0.3)).toList(),
        ),
      ),
    );
  }

  double _getMaxYValue() {
    final allYValues = [
      ..._chartData['income'] ?? [],
      ..._chartData['expense'] ?? [],
    ].map((spot) => spot.y).toList();

    if (allYValues.isEmpty) return 5.0;

    double maxY = allYValues.reduce((a, b) => a > b ? a : b);
    return maxY > 0 ? (maxY * 1.25).ceilToDouble() : 5.0;
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = GoogleFonts.manrope(
      color: Colors.grey[700],
      fontWeight: FontWeight.w500,
      fontSize: 10,
    );
    if (value == 0) return Text('0', style: style, textAlign: TextAlign.left);
    if (value >= meta.max) return const SizedBox.shrink();

    double actualValue = value * 100000;
    String text;
    if (actualValue >= 1000000) {
      text = '${(actualValue / 1000000).toStringAsFixed(1)}M';
    } else {
      text = '${(actualValue / 1000).toStringAsFixed(0)}K';
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(const Color(0xff23b6e6), "Pemasukan"),
        const SizedBox(width: 24),
        _legendItem(const Color(0xfff12711), "Pengeluaran"),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final balance = _totalIncome - _totalExpense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Keuangan',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Pemasukan',
                amount: formatter.format(_totalIncome),
                icon: Icons.trending_up,
                color: Colors.green,
                backgroundColor: Colors.green.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Pengeluaran',
                amount: formatter.format(_totalExpense),
                icon: Icons.trending_down,
                color: Colors.red,
                backgroundColor: Colors.red.shade50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          title: 'Saldo Saat Ini',
          amount: formatter.format(balance),
          icon: Icons.account_balance_wallet_outlined,
          color: Colors.blue.shade800,
          backgroundColor: Colors.blue.shade50,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaksi Terbaru',
              style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            TextButton(
              // PERBAIKAN: Memanggil callback yang sudah disediakan
              onPressed: widget.onViewAllPressed,
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTransactionsList(),
      ],
    );
  }

  Widget _buildTransactionsList() {
    if (_allTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 2, blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Belum ada transaksi minggu ini', style: GoogleFonts.manrope(color: Colors.grey[600])),
          ],
        ),
      );
    }
    
    // Data sudah diurutkan dari yang terbaru, jadi cukup ambil 3 teratas
    final recentTransactions = _allTransactions.take(3).toList();
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 2, blurRadius: 10)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: recentTransactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 68, endIndent: 16),
        itemBuilder: (context, index) {
          final transaction = recentTransactions[index];
          final isIncome = transaction.type == 'income';
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(isIncome ? Icons.arrow_upward : Icons.arrow_downward, color: isIncome ? Colors.green : Colors.red, size: 20),
            ),
            title: Text(
              transaction.category,
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            subtitle: Text(
              DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(transaction.date),
              style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}