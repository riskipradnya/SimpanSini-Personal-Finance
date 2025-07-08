import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/transaction_service.dart';
import '../models/transaction_model.dart';
// import 'pemasukan_screen.dart';
// import 'pengeluaran_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Gung Riski';
  bool _isLoading = true;
  List<Transaction> _allTransactions = [];

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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadUserData();
    await _loadTransactions();
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
      final transactions = await TransactionService().getAllTransactions();
      transactions.sort((a, b) => a.date.compareTo(b.date));
      if (mounted) {
        setState(() {
          _allTransactions = transactions;
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
      if (mounted)
        setState(() {
          _allTransactions = [];
        });
    }
  }

  List<FlSpot> _getChartData(String type) {
    if (_allTransactions.isEmpty) {
      return type == 'income' ? _dummyIncomeSpots : _dummyExpenseSpots;
    }
    final filteredTransactions = _allTransactions
        .where((t) => t.type == type)
        .toList();
    if (filteredTransactions.length < 2) {
      return type == 'income' ? _dummyIncomeSpots : _dummyExpenseSpots;
    }
    return List.generate(filteredTransactions.length, (index) {
      final transaction = filteredTransactions[index];
      final yValue = transaction.amount / 100000;
      return FlSpot(index.toDouble(), yValue);
    });
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
                          Text(
                            'Minim dolor in amet nulla laboris enim dolore consequatt.',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildChartLegend(),
                          const SizedBox(height: 24),
                          _buildActionGrid(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Add transaction tapped");
        },
        backgroundColor: const Color(0xFF3A4276),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
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
          const CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?u=gungriski',
            ),
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
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: LineChart(
            // Cukup panggil method _mainChartData()
            _mainChartData(),
          ),
        ),
      ],
    );
  }

  LineChartData _mainChartData() {
    return LineChartData(
      // Animation duration is not a valid parameter here
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 38,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 10,
      minY: 0,
      maxY: 6,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (FlSpot spot) => Colors.black,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final amount = (spot.y * 100000).toInt();
              final formatter = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp',
                decimalDigits: 0,
              );
              return LineTooltipItem(
                'Rata-Rata\n${formatter.format(amount)}',
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

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = GoogleFonts.manrope(
      color: Colors.grey[700],
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0K';
        break;
      case 1:
        text = '100K';
        break;
      case 3:
        text = '300K';
        break;
      case 5:
        text = '500K';
        break;
      default:
        return Container();
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

  Widget _buildActionGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _actionButton(
          icon: Icons.send_rounded,
          title: 'Send money',
          subtitle: 'Take acc to acc',
          onTap: () {
            print('Send Money Tapped');
          },
        ),
        _actionButton(
          icon: Icons.receipt_long_rounded,
          title: 'Pay the bill',
          subtitle: 'Lorem ipsum',
          onTap: () {
            print('Pay Bill Tapped');
          },
        ),
        _actionButton(
          icon: Icons.arrow_downward_rounded,
          title: 'Request',
          subtitle: 'Lorem ipsum',
          onTap: () {
            print('Request Tapped');
          },
        ),
        _actionButton(
          icon: Icons.people_alt_rounded,
          title: 'Contact',
          subtitle: 'Lorem ipsum',
          onTap: () {
            print('Contact Tapped');
          },
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF3A4276)),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.home_filled, 'Home', true, () {}),
            _navItem(Icons.bar_chart_rounded, 'Statistic', false, () {}),
            const SizedBox(width: 40), // Space for FAB
            _navItem(Icons.star_border_rounded, 'Wishlist', false, () {}),
            _navItem(Icons.person_outline_rounded, 'Profil', false, () {}),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    final color = isActive ? const Color(0xFF3A4276) : Colors.grey[400];
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
