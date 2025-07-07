import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  String _selectedPeriod = 'Monthly';
  final Color incomeColor = const Color(0xFF6C63FF);
  final Color expenseColor = const Color(0xFF2C2C54);
  final double width = 12;

  late List<BarChartGroupData> showingBarGroups;

  @override
  void initState() {
    super.initState();

    // Fetch data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactions();
    });
  }

  List<BarChartGroupData> _prepareBarChartData(TransactionProvider provider) {
    final chartData = provider.getChartData();
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < chartData.length; i++) {
      // Convert to millions for better display
      final incomeY = chartData[i]['income'] / 1000000;
      final expenseY = chartData[i]['expense'] / 1000000;

      barGroups.add(makeGroupData(i, incomeY, expenseY));
    }

    return barGroups;
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
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Prepare bar chart data
          showingBarGroups = _prepareBarChartData(provider);

          // Get date range text
          final now = DateTime.now();
          final startDate = DateTime(now.year, now.month - 5, 1);
          final endDate = DateTime(now.year, now.month + 1, 0);
          final dateRangeText =
              '${DateFormat('MMMM d').format(startDate)} - ${DateFormat('MMMM d, y').format(endDate)}';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Header Tanggal dan Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateRangeText,
                    style: const TextStyle(color: Colors.grey),
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
                        value: _selectedPeriod,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: <String>['Monthly', 'Weekly', 'Yearly']
                            .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            })
                            .toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedPeriod = newValue;
                            });
                          }
                        },
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
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rodIndex == 0 ? 'Pemasukan\n' : 'Pengeluaran\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: currencyFormatter.format(
                                  rod.toY * 1000000,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
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
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= showingBarGroups.length) {
                              return const SizedBox();
                            }

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
                            final currentMonth =
                                (now.month - 5 + value.toInt()) % 12;
                            final monthName =
                                months[currentMonth == 0
                                    ? 11
                                    : currentMonth - 1];

                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 16,
                              child: Text(
                                monthName,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
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
                      provider.totalIncome,
                      currencyFormatter,
                      Colors.blue.shade100,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      Icons.upload,
                      'Pengeluaran',
                      provider.totalExpense,
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

              // List of transactions
              ...provider.getRecentTransactions().map(
                (transaction) => _buildTransactionItem(
                  transaction.category,
                  transaction.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
                  transaction.amount,
                  currencyFormatter,
                  transaction.type == 'income',
                ),
              ),
            ],
          );
        },
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
