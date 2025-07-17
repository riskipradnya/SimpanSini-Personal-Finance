import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/transaction_service.dart';
import '../models/transaction_model.dart';

// You need to define _MainScreenState or ensure it's accessible.
// For this rewrite, I'm assuming MainScreenState is a State class
// of a StatefulWidget named MainScreen, and we'll try to get its instance
// via context if it's an ancestor.
// If MainScreenState is not meant to be accessed this way,
// you might need to reconsider how navigation is handled.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  void navigateToScreen(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          // Assuming HomeScreen will be one of the pages
          HomeScreen(refreshNotifier: ValueNotifier(0)), // Dummy notifier
          // Other screens would go here
          Center(child: Text("Statistics Screen")),
          Center(child: Text("Another Screen")),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: navigateToScreen,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  // 1. Terima ValueNotifier dari parent widget (MainScreen)
  final ValueNotifier<int> refreshNotifier;
  // This should not directly refer to a State object as it can lead to issues.
  // Instead, rely on the ValueNotifier for updates or find the ancestor state if truly needed.
  // For navigation, the navigateToScreen callback is a better pattern.
  // final _MainScreenState? mainScreenState; // Removed this line

  const HomeScreen({
    super.key,
    required this.refreshNotifier,
    // this.mainScreenState, // Removed this line
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Gung Riski';
  bool _isLoading = true;
  List<Transaction> _allTransactions = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  // Data dummy tetap ada sebagai fallback
  final List<FlSpot> _dummyIncomeSpots = [
    const FlSpot(0, 3.1),
    const FlSpot(2, 4.5),
    const FlSpot(4, 3.8),
    const FlSpot(6, 5),
    const FlSpot(8, 3.5),
    const FlSpot(10, 4.2),
  ];
  final List<FlSpot> _dummyExpenseSpots = [
    const FlSpot(0, 2.2),
    const FlSpot(2, 2.8),
    const FlSpot(4, 2.1),
    const FlSpot(6, 3.4),
    const FlSpot(8, 2.5),
    const FlSpot(10, 3.0),
  ];

  @override
  void initState() {
    super.initState();
    // 2. Daftarkan fungsi _loadData untuk "mendengarkan" perubahan pada notifier
    widget.refreshNotifier.addListener(_loadData);

    // 3. Panggil _loadData() saat halaman pertama kali dibuat
    _loadData();
  }

  @override
  void dispose() {
    // 4. Hapus listener untuk mencegah memory leak saat halaman dihancurkan
    widget.refreshNotifier.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    // Tambahkan pengecekan 'mounted' untuk memastikan state masih ada
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    await _loadUserData();
    await _loadTransactions();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Gung Riski';
      });
    }
  }

  Future<void> _loadTransactions() async {
    try {
      // Get transactions for the last week
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));

      final allTransactions = await TransactionService().getAllTransactions();

      // Filter transactions for the last week
      final weeklyTransactions = allTransactions.where((transaction) {
        return transaction.date.isAfter(oneWeekAgo) &&
            transaction.date.isBefore(now.add(const Duration(days: 1)));
      }).toList();

      weeklyTransactions.sort((a, b) => a.date.compareTo(b.date));

      // Calculate totals for the week
      double totalIncome = 0.0;
      double totalExpense = 0.0;

      for (var transaction in weeklyTransactions) {
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else if (transaction.type == 'expense') {
          totalExpense += transaction.amount;
        }
      }

      if (mounted) {
        setState(() {
          _allTransactions = weeklyTransactions;
          _totalIncome = totalIncome;
          _totalExpense = totalExpense;
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
      if (mounted) {
        setState(() {
          _allTransactions = [];
          _totalIncome = 0.0;
          _totalExpense = 0.0;
        });
      }
    }
  }

  List<FlSpot> _getChartData(String type) {
    if (_allTransactions.isEmpty) {
      return type == 'income' ? _dummyIncomeSpots : _dummyExpenseSpots;
    }

    final filteredTransactions = _allTransactions
        .where((t) => t.type == type)
        .toList();

    if (filteredTransactions.isEmpty) {
      return type == 'income' ? _dummyIncomeSpots : _dummyExpenseSpots;
    }

    // Group transactions by day for the last week
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    Map<int, List<Transaction>> dailyTransactions = {};

    // Initialize all days in the week
    for (int i = 0; i < 7; i++) {
      dailyTransactions[i] = [];
    }

    for (var transaction in filteredTransactions) {
      final daysDifference = transaction.date.difference(oneWeekAgo).inDays;
      if (daysDifference >= 0 && daysDifference < 7) {
        dailyTransactions[daysDifference]!.add(transaction);
      }
    }

    List<FlSpot> spots = [];

    // Create spots for each day
    for (int i = 0; i < 7; i++) {
      List<Transaction> transactions = dailyTransactions[i]!;
      double totalAmount = transactions.fold(0.0, (sum, t) => sum + t.amount);
      // Scale down the amount for better chart visualization
      double scaledAmount =
          totalAmount / 100000; // Convert to hundred thousands
      spots.add(FlSpot(i.toDouble(), scaledAmount));
    }

    return spots;
  }

  String _getDateRangeText() {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    return '${DateFormat('d MMM', 'id_ID').format(oneWeekAgo)} - ${DateFormat('d MMM yyyy', 'id_ID').format(now)}';
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = GoogleFonts.manrope(
      color: Colors.grey[700],
      fontWeight: FontWeight.w500,
      fontSize: 10,
    );

    const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    final int index = value.toInt();
    if (index >= 0 && index < dayNames.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(dayNames[index], style: style),
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
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey[700], size: 30),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: Colors.grey[500],
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
          onPressed: () {
            print("Notification tapped");
          },
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

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart_rounded, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  "Pemasukan dan Pengeluaran",
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
        const SizedBox(height: 8),
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
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
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
            interval: maxY / 5, // Dynamic interval based on max value
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 48,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6, // 7 days (0-6)
      minY: 0,
      maxY: maxY,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (FlSpot spot) => Colors.black,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final amount = (spot.y * 100000)
                  .toInt(); // Convert back to actual amount
              final formatter = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              );

              // Get day name for tooltip
              const dayNames = [
                'Senin',
                'Selasa',
                'Rabu',
                'Kamis',
                'Jumat',
                'Sabtu',
                'Minggu',
              ];
              final dayIndex = spot.x.toInt();
              final dayName = dayIndex >= 0 && dayIndex < dayNames.length
                  ? dayNames[dayIndex]
                  : '';

              return LineTooltipItem(
                '$dayName\n${formatter.format(amount)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _getChartData('income'),
          isCurved: true,
          gradient: const LinearGradient(
            colors: [Color(0xff23b6e6), Color(0xff02d39a)],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xff23b6e6).withOpacity(0.3),
                const Color(0xff02d39a).withOpacity(0.3),
              ],
            ),
          ),
        ),
        LineChartBarData(
          spots: _getChartData('expense'),
          isCurved: true,
          gradient: const LinearGradient(
            colors: [Color(0xfff12711), Color(0xfff5af19)],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xfff12711).withOpacity(0.2),
                const Color(0xfff5af19).withOpacity(0.2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _getMaxYValue() {
    // Gather all y values from both income and expense spots
    final incomeSpots = _getChartData('income');
    final expenseSpots = _getChartData('expense');
    final allYValues = [
      ...incomeSpots,
      ...expenseSpots,
    ].map((spot) => spot.y).toList();

    if (allYValues.isEmpty) {
      return 5.0; // Default max Y if no data
    }

    double maxY = allYValues.reduce((a, b) => a > b ? a : b);
    // Add a little padding to the top
    return (maxY * 1.2).ceilToDouble().clamp(1.0, double.infinity);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = GoogleFonts.manrope(
      color: Colors.grey[700],
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    String text;
    if (value == 0) {
      text = '0';
    } else if (value < 10) {
      // Assuming a value of 1.0 represents 100K
      text = '${(value * 100).toInt()}K';
    } else {
      // Assuming a value of 10.0 represents 1M
      text = '${(value / 10).toInt()}M';
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

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
                title: 'Total Pemasukan',
                amount: formatter.format(_totalIncome),
                icon: Icons.trending_up,
                color: Colors.green,
                backgroundColor: Colors.green.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Pengeluaran',
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
          title: 'Saldo',
          amount: formatter.format(balance),
          icon: balance >= 0 ? Icons.account_balance_wallet : Icons.warning,
          color: balance >= 0 ? Colors.blue : Colors.orange,
          backgroundColor: balance >= 0
              ? Colors.blue.shade50
              : Colors.orange.shade50,
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // Find the parent MainScreenState and navigate
                final mainScreenContext = context
                    .findAncestorStateOfType<_MainScreenState>();
                if (mainScreenContext != null) {
                  mainScreenContext.navigateToScreen(
                    1,
                  ); // Assuming 1 is the index for the statistics screen
                }
              },
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: const Color(0xFF3A4276),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTransactionsList(),
      ],
    );
  }

  Widget _buildTransactionsList() {
    if (_allTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada transaksi minggu ini',
              style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    // Show last 3 transactions
    final recentTransactions = _allTransactions.reversed.take(3).toList();
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: recentTransactions.length,
        separatorBuilder: (context, index) => const Divider(height: 20),
        itemBuilder: (context, index) {
          final transaction = recentTransactions[index];
          final isIncome = transaction.type == 'income';

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isIncome ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'd MMM yyyy',
                        'id_ID',
                      ).format(transaction.date),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
