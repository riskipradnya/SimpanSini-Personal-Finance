import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
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
      backgroundColor: const Color(
        0xFF1C1C1E,
      ), // Background gelap sesuai desain
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
        backgroundColor: const Color(0xFF2C2C4E),
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
              style: GoogleFonts.manrope(color: Colors.grey[400], fontSize: 14),
            ),
            Text(
              'Gung Riski',
              style: GoogleFonts.manrope(
                color: Colors.white,
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
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.bell_fill,
            color: Colors.white,
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
            const Icon(Icons.show_chart, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(
              'Pemasukan dan Pengeluaran',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: LineChart(
            mainData(), // Memanggil data chart dari fungsi di bawah
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
          style: GoogleFonts.manrope(color: Colors.grey[400], fontSize: 14),
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
            color: Colors.white,
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
        _actionCard(
          CupertinoIcons.paperplane_fill,
          'Send money',
          'Take acc to acc',
        ),
        _actionCard(
          CupertinoIcons.creditcard_fill,
          'Pay the bill',
          'Lorem ipsum',
        ),
        _actionCard(
          CupertinoIcons.arrow_down_to_line_alt,
          'Request',
          'Lorem ipsum',
        ),
        _actionCard(CupertinoIcons.person_3_fill, 'Contact', 'Lorem ipsum'),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.manrope(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Widget untuk Bottom Navigation Bar Kustom
  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: const Color(0xFF2A2A2E),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomAppBarItem(
            icon: CupertinoIcons.home,
            label: 'Home',
            isSelected: true,
          ),
          _bottomAppBarItem(
            icon: CupertinoIcons.chart_bar_alt_fill,
            label: 'Statistic',
          ),
          const SizedBox(width: 40), // Ruang untuk FAB
          _bottomAppBarItem(icon: CupertinoIcons.creditcard, label: 'My card'),
          _bottomAppBarItem(icon: CupertinoIcons.person, label: 'Profil'),
        ],
      ),
    );
  }

  Widget _bottomAppBarItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? Colors.white : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${(barSpot.y * 100).toInt()}K',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
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
          return const FlLine(color: Color(0xff37434d), strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Color(0xff37434d), strokeWidth: 0);
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
        border: Border.all(color: const Color(0xff37434d), width: 1),
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
      color: Colors.grey[400],
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
