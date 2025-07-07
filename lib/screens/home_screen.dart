import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pemasukan_screen.dart';
import 'pengeluaran_screen.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

// 3. Pindahkan deklarasi list warna ke dalam class atau sebagai konstanta global
const List<Color> pemasukanGradientColors = [
  Color(0xff23b6e6),
  Color(0xff02d39a),
];

const List<Color> pengeluaranGradientColors = [
  Color(0xffec456a),
  Color(0xffff8e53),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch transactions when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: transactionProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildBalanceCard(transactionProvider, formatter),
                    const SizedBox(height: 30),
                    _buildChartSection(transactionProvider),
                    const SizedBox(height: 20),
                    _buildLegend(),
                    const SizedBox(height: 30),
                    _buildRecentTransactions(transactionProvider, formatter),
                    const SizedBox(height: 20),
                    _buildActionGrid(),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        backgroundColor: const Color(0xFF1A237E),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  // New method to show transaction dialog
  void _showAddTransactionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.green),
                title: const Text('Tambah Pemasukan'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PemasukanScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.red),
                title: const Text('Tambah Pengeluaran'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PengeluaranScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // New method to show balance card
  Widget _buildBalanceCard(
    TransactionProvider provider,
    NumberFormat formatter,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(provider.balance),
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _balanceItem(
                Icons.arrow_downward,
                'Income',
                formatter.format(provider.totalIncome),
                Colors.green.shade300,
              ),
              _balanceItem(
                Icons.arrow_upward,
                'Expense',
                formatter.format(provider.totalExpense),
                Colors.red.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceItem(IconData icon, String label, String amount, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Update chart section to use real data
  Widget _buildChartSection(TransactionProvider provider) {
    // Get chart data from provider
    final chartData = provider.getChartData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.show_chart, color: Colors.grey[800], size: 28),
            const SizedBox(width: 10),
            Text(
              'Pemasukan dan Pengeluaran',
              style: GoogleFonts.manrope(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 200,
            child: LineChart(mainDataWithRealData(chartData)),
          ),
        ),
      ],
    );
  }

  // New method to create chart data from real data
  LineChartData mainDataWithRealData(List<Map<String, dynamic>> chartData) {
    // Create spots for income and expense lines
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    // Maximum value for Y axis scaling
    double maxY = 0;

    // Fill the spots
    for (int i = 0; i < chartData.length; i++) {
      final income = chartData[i]['income'] / 100000; // Convert to 100K units
      final expense = chartData[i]['expense'] / 100000;

      incomeSpots.add(FlSpot(i.toDouble(), income));
      expenseSpots.add(FlSpot(i.toDouble(), expense));

      maxY = [
        maxY,
        income,
        expense,
      ].reduce((curr, next) => curr > next ? curr : next);
    }

    // Add some buffer to max Y
    maxY = (maxY * 1.2).ceilToDouble();
    if (maxY < 5) maxY = 5; // Minimum max Y

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              return LineTooltipItem(
                barSpot.barIndex == 0 ? 'Pemasukan\n' : 'Pengeluaran\n',
                GoogleFonts.manrope(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text:
                        'Rp${NumberFormat('#,###').format(barSpot.y * 100000)}',
                    style: GoogleFonts.manrope(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Colors.grey[300]!, strokeWidth: 0);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value < 0 || value >= chartData.length)
                return const SizedBox();

              final months = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
              ];
              final monthIndex = chartData[value.toInt()]['month'] - 1;

              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8,
                child: Text(
                  months[monthIndex],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              );
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 5,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              if (value == 0) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: const Text(
                    '0',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                );
              }

              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8,
                child: Text(
                  '${(value).toInt()}00K',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      minX: 0,
      maxX: chartData.length - 1.0,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: incomeSpots,
          isCurved: true,
          gradient: const LinearGradient(colors: pemasukanGradientColors),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: pemasukanGradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
        LineChartBarData(
          spots: expenseSpots,
          isCurved: true,
          gradient: const LinearGradient(colors: pengeluaranGradientColors),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: pengeluaranGradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // New method to show recent transactions
  Widget _buildRecentTransactions(
    TransactionProvider provider,
    NumberFormat formatter,
  ) {
    final recentTransactions = provider.getRecentTransactions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to transactions list view
              },
              child: Text(
                'See All',
                style: GoogleFonts.manrope(color: const Color(0xFF1A237E)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (recentTransactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'No transactions yet',
                style: GoogleFonts.manrope(color: Colors.grey),
              ),
            ),
          )
        else
          ...recentTransactions.map(
            (transaction) => _buildTransactionItem(transaction, formatter),
          ),
      ],
    );
  }

  // New method to build transaction item
  Widget _buildTransactionItem(
    Transaction transaction,
    NumberFormat formatter,
  ) {
    final isIncome = transaction.type == 'income';
    final date = DateFormat('dd MMM').format(transaction.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  transaction.description.isNotEmpty
                      ? transaction.description
                      : isIncome
                      ? 'Income'
                      : 'Expense',
                  style: GoogleFonts.manrope(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                style: GoogleFonts.manrope(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.manrope(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 👇 SEMUA METODE HELPER DIBAWAH INI DIPINDAHKAN KE DALAM KELAS HomeScreen 👇

  // Widget untuk Header (Avatar, Nama, Notifikasi)
  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(
            'https://i.pravatar.cc/150?u=gungriski',
          ), // Avatar placeholder
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: GoogleFonts.manrope(color: Colors.grey[600], fontSize: 14),
            ),
            Text(
              'Gung Riski',
              style: GoogleFonts.manrope(
                color: Colors
                    .black87, // Changed to dark color for white background
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Lighter background for white theme
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications, // DIGANTI: dari CupertinoIcons.bell_fill
            color: Colors.grey[800], // Darker icon for white background
            size: 24,
          ),
        ),
      ],
    );
  }

  // Konfigurasi utama untuk LineChart dari fl_chart
  LineChartData mainData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              return LineTooltipItem(
                'Rata-Rata\n',
                GoogleFonts.manrope(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${(barSpot.y * 100).toInt()}K',
                    style: GoogleFonts.manrope(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Colors.grey[300]!, strokeWidth: 0);
        },
      ),
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
            interval: 1.5,
            reservedSize: 42,
            getTitlesWidget: leftTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          gradient: const LinearGradient(colors: pemasukanGradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: pemasukanGradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
        LineChartBarData(
          spots: const [
            FlSpot(0, 1.5),
            FlSpot(2.6, 2.5),
            FlSpot(4.9, 2),
            FlSpot(6.8, 2.8),
            FlSpot(8, 2.2),
            FlSpot(9.5, 2.5),
            FlSpot(11, 2.0),
          ],
          isCurved: true,
          gradient: const LinearGradient(colors: pengeluaranGradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: pengeluaranGradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Widget kustom untuk judul sumbu Y (kiri)
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    var style = GoogleFonts.manrope(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.grey[600], // Changed to darker color
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '50K';
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

  // Widget untuk legenda chart
  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minim dolor in amet nulla laboris enim dolore consequatt.',
          style: GoogleFonts.manrope(
            color: Colors.grey[600],
            fontSize: 14,
          ), // Lighter gray
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _legendItem(const Color(0xff23b6e6), 'Pemasukan'),
            const SizedBox(width: 20),
            _legendItem(const Color(0xffec456a), 'Pengeluaran'),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.manrope(
            color: Colors.black87, // Changed to dark color
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Widget untuk Grid Tombol Aksi
  Widget _buildActionGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.2,
      children: [
        // KARTU-KARTU TELAH DIGANTI SESUAI PERMINTAAN
        _actionCard(
          Icons.account_balance_wallet_outlined,
          'Budgeting',
          'Alokasi dana bulanan',
        ),
        _actionCard(Icons.analytics_outlined, 'Laporan', 'Laporan keuangan'),
        _actionCard(
          Icons.category_outlined,
          'Kategori',
          'Atur kategori transaksi',
        ),
        _actionCard(Icons.star_outline, 'Wishlist', 'Daftar keinginan'),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100], // Lighter background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!), // Visible border
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF1A237E),
            size: 28,
          ), // Primary app color
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.manrope(
              color: Colors.black87, // Dark text
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.manrope(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Widget untuk Bottom Navigation Bar Kustom
  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: Colors.white, // Changed to white
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomAppBarItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: true,
            ),
            _bottomAppBarItem(icon: Icons.bar_chart, label: 'Statistik'),
            const SizedBox(width: 40), // Ruang untuk FAB
            _bottomAppBarItem(icon: Icons.credit_card, label: 'Kartu'),
            _bottomAppBarItem(icon: Icons.person, label: 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _bottomAppBarItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Column(
      mainAxisSize:
          MainAxisSize.min, // Membuat Column hanya memakan ruang seperlunya
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF1A237E) : Colors.grey[400],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: isSelected ? const Color(0xFF1A237E) : Colors.grey[400],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
} // <-- Kurung kurawal penutup untuk kelas HomeScreen
