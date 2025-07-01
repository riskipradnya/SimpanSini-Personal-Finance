import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Data dummy untuk gradien warna chart
  final List<Color> pemasukanGradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  final List<Color> pengeluaranGradientColors = [
    const Color(0xffec456a),
    const Color(0xfff56b9a),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed to white background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildChartSection(),
                const SizedBox(height: 20),
                _buildLegend(),
                const SizedBox(height: 30),
                _buildActionGrid(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(
          0xFF1A237E,
        ), // Changed to match app's primary color
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

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

  // Widget untuk bagian Chart
  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.show_chart,
              color: Colors.grey[800],
              size: 28,
            ), // Darker icon
            const SizedBox(width: 10),
            Text(
              'Pemasukan dan Pengeluaran',
              style: GoogleFonts.manrope(
                color: Colors.black87, // Changed to dark color
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
            child: LineChart(
              mainData(), // Memanggil data chart dari fungsi di bawah
            ),
          ),
        ),
      ],
    );
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
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
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

  // Konfigurasi utama untuk LineChart dari fl_chart
  LineChartData mainData() {
    return LineChartData(
      // Konfigurasi untuk touch/tooltip
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
      // Konfigurasi grid
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
      // Konfigurasi judul (sumbu X dan Y)
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
      // Konfigurasi border
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      // Data garis-garis pada chart
      lineBarsData: [
        // Garis Pemasukan (Biru)
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
          gradient: LinearGradient(colors: pemasukanGradientColors),
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
        // Garis Pengeluaran (Pink)
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
          gradient: LinearGradient(colors: pengeluaranGradientColors),
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
}
