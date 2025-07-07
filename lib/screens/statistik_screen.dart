import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  final Color incomeColor = const Color(0xFF6C63FF);
  final Color expenseColor = const Color(0xFF2C2C54);
  final double width = 12;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  @override
  void initState() {
    super.initState();
    // Data dummy untuk chart
    final barGroup1 = makeGroupData(0, 4, 1.8); // Jan
    final barGroup2 = makeGroupData(1, 6.5, 3); // Feb
    final barGroup3 = makeGroupData(2, 2.5, 3.5); // Mar
    final barGroup4 = makeGroupData(3, 4.5, 1.5); // Apr
    final barGroup5 = makeGroupData(4, 5.5, 3.2); // May

    final items = [barGroup1, barGroup2, barGroup3, barGroup4, barGroup5];
    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    // Format mata uang Rupiah
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Statistik',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header Tanggal dan Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'February 28 - March 28, 2020',
                style: TextStyle(color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'Monthly',
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: <String>['Monthly', 'Weekly', 'Yearly']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
                    onChanged: (String? newValue) {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bar Chart
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                maxY: 8, // Maksimal Y dalam Juta (JT)
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.grey,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: bottomTitles,
                      reservedSize: 42,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 1,
                      getTitlesWidget: leftTitles,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: showingBarGroups,
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Total Pemasukan & Pengeluaran
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  Icons.download,
                  'Pemasukan',
                  6000000,
                  currencyFormatter,
                  Colors.blue.shade100,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  Icons.upload,
                  'Pengeluaran',
                  2000000,
                  currencyFormatter,
                  Colors.purple.shade100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Riwayat Transaksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Semua Transaksi',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTransactionItem(
            'GAJI',
            'Pemasukan',
            4000000,
            currencyFormatter,
            true,
          ),
          const Divider(),
          _buildTransactionItem(
            'Makan Siang',
            'Pengeluaran',
            50000,
            currencyFormatter,
            false,
          ),
        ],
      ),
    );
  }

  // Widget untuk judul di sumbu Y (kiri)
  Widget leftTitles(double value, TitleMeta meta) {
    String text;
    if (value == 0) {
      text = '0';
    } else if (value == 1) {
      text = '1JT';
    } else if (value == 4) {
      text = '4JT';
    } else if (value == 8) {
      text = '8JT';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  // Widget untuk judul di sumbu X (bawah)
  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May'];
    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(color: Colors.grey, fontSize: 14),
    );
    return SideTitleWidget(axisSide: meta.axisSide, space: 16, child: text);
  }

  // Fungsi untuk membuat data grup bar
  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: incomeColor,
          width: width,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: y2,
          color: expenseColor,
          width: width,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  // Widget untuk card ringkasan (Pemasukan/Pengeluaran)
  Widget _buildSummaryCard(
    IconData icon,
    String title,
    double amount,
    NumberFormat formatter,
    Color iconBgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade800),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatter.format(amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk item riwayat transaksi
  Widget _buildTransactionItem(
    String category,
    String type,
    double amount,
    NumberFormat formatter,
    bool isIncome,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(type, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(
            (isIncome ? '+' : '-') + formatter.format(amount),
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
