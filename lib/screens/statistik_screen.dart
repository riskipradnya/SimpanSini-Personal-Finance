import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/transaction_service.dart';
import '../models/transaction_model.dart';

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

  List<Transaction> _transactions = [];
  List<Transaction> _incomeTransactions = [];
  List<Transaction> _expenseTransactions = [];
  bool _isLoading = true;
  String _selectedTimeFrame = 'Monthly';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  double _totalIncome = 0;
  double _totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load transactions from the selected date range
      final transactions = await TransactionService()
          .getTransactionsByDateRange(_startDate, _endDate);

      // Separate income and expense transactions
      final incomeTransactions = transactions
          .where((t) => t.type == 'income')
          .toList();
      final expenseTransactions = transactions
          .where((t) => t.type == 'expense')
          .toList();

      // Calculate totals
      final totalIncome = incomeTransactions.fold<double>(
        0,
        (sum, item) => sum + item.amount,
      );
      final totalExpense = expenseTransactions.fold<double>(
        0,
        (sum, item) => sum + item.amount,
      );

      // Create bar chart data based on real data
      final barGroups = _createBarGroups(transactions);

      setState(() {
        _transactions = transactions;
        _incomeTransactions = incomeTransactions;
        _expenseTransactions = expenseTransactions;
        _totalIncome = totalIncome;
        _totalExpense = totalExpense;
        rawBarGroups = barGroups;
        showingBarGroups = barGroups;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<BarChartGroupData> _createBarGroups(List<Transaction> transactions) {
    // Group transactions by month
    final Map<int, Map<String, double>> monthlyData = {};

    for (var transaction in transactions) {
      final month = transaction.date.month - 1; // 0-indexed for chart
      monthlyData.putIfAbsent(month, () => {'income': 0, 'expense': 0});

      if (transaction.type == 'income') {
        monthlyData[month]!['income'] =
            (monthlyData[month]!['income'] ?? 0) + transaction.amount;
      } else {
        monthlyData[month]!['expense'] =
            (monthlyData[month]!['expense'] ?? 0) + transaction.amount;
      }
    }

    // Find the maximum amount to scale the chart
    double maxAmount = 0;
    monthlyData.forEach((_, data) {
      if ((data['income'] ?? 0) > maxAmount) maxAmount = data['income']!;
      if ((data['expense'] ?? 0) > maxAmount) maxAmount = data['expense']!;
    });

    // Scale amounts to fit in 0-6 range for the chart
    final scale = maxAmount > 0 ? 6 / maxAmount : 1;

    // Create bar groups
    final List<BarChartGroupData> groups = [];

    for (int i = 0; i < 5; i++) {
      final income = monthlyData[i]?['income'] ?? 0;
      final expense = monthlyData[i]?['expense'] ?? 0;

      groups.add(makeGroupData(i, income * scale, expense * scale));
    }

    return groups;
  }

  void _updateTimeFrame(String timeFrame) {
    setState(() {
      _selectedTimeFrame = timeFrame;

      // Update date range based on selected time frame
      switch (timeFrame) {
        case 'Weekly':
          _startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case 'Monthly':
          _startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case 'Yearly':
          _startDate = DateTime.now().subtract(const Duration(days: 365));
          break;
      }

      _endDate = DateTime.now();
    });

    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    // Format mata uang Rupiah
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    );

    // Format tanggal range
    final dateFormatter = DateFormat('d MMM yyyy', 'id_ID');
    final dateRangeText =
        '${dateFormatter.format(_startDate)} - ${dateFormatter.format(_endDate)}';

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                          value: _selectedTimeFrame,
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
                              _updateTimeFrame(newValue);
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
                        _totalIncome,
                        currencyFormatter,
                        Colors.blue.shade100,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        Icons.upload,
                        'Pengeluaran',
                        _totalExpense,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Semua Transaksi',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Display recent transactions
                if (_transactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Tidak ada transaksi'),
                    ),
                  )
                else
                  ...List.generate(
                    _transactions.length > 5 ? 5 : _transactions.length,
                    (index) {
                      final transaction = _transactions[index];
                      return Column(
                        children: [
                          _buildTransactionItem(
                            transaction.category,
                            transaction.type == 'income'
                                ? 'Pemasukan'
                                : 'Pengeluaran',
                            transaction.amount,
                            currencyFormatter,
                            transaction.type == 'income',
                          ),
                          if (index < _transactions.length - 1) const Divider(),
                        ],
                      );
                    },
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
