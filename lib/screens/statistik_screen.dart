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
      final transactions = await TransactionService()
          .getTransactionsByDateRange(_startDate, _endDate);

      final incomeTransactions = transactions
          .where((t) => t.type == 'pemasukan') // Diubah dari 'income'
          .toList();
      final expenseTransactions = transactions
          .where((t) => t.type == 'pengeluaran') // Diubah dari 'expense'
          .toList();

      final totalIncome = incomeTransactions.fold<double>(
        0,
        (sum, item) => sum + item.amount,
      );
      final totalExpense = expenseTransactions.fold<double>(
        0,
        (sum, item) => sum + item.amount,
      );

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
    final Map<int, Map<String, double>> monthlyData = {};

    for (var transaction in transactions) {
      final month = transaction.date.month - 1;
      monthlyData.putIfAbsent(month, () => {'income': 0, 'expense': 0});

      // --- PERBAIKAN 1: Menggunakan 'pemasukan' ---
      if (transaction.type == 'pemasukan') {
        // Diubah dari 'income'
        monthlyData[month]!['income'] =
            (monthlyData[month]!['income'] ?? 0) + transaction.amount;
      } else {
        monthlyData[month]!['expense'] =
            (monthlyData[month]!['expense'] ?? 0) + transaction.amount;
      }
    }

    double maxAmount = 0;
    monthlyData.forEach((_, data) {
      if ((data['income'] ?? 0) > maxAmount) maxAmount = data['income']!;
      if ((data['expense'] ?? 0) > maxAmount) maxAmount = data['expense']!;
    });

    final scale = maxAmount > 0 ? 6 / maxAmount : 1;
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
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    );
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
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      maxY: 8,
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Teks 'Semua Transaksi' dihapus karena daftar di bawah sudah mewakili
                  ],
                ),
                const SizedBox(height: 16),
                if (_transactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Tidak ada transaksi pada rentang waktu ini.',
                      ),
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
                            // --- PERBAIKAN 2: Menggunakan 'description' bukan 'category' ---
                            transaction.description,
                            transaction.type == 'pemasukan'
                                ? 'Pemasukan'
                                : 'Pengeluaran',
                            transaction.amount,
                            currencyFormatter,
                            // --- PERBAIKAN 1: Cek 'pemasukan' bukan 'income' ---
                            transaction.type == 'pemasukan',
                          ),
                          if (index < _transactions.length - 1 && index < 4)
                            const Divider(),
                        ],
                      );
                    },
                  ),
              ],
            ),
    );
  }

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

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May'];
    if (value.toInt() >= titles.length) return Container();
    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(color: Colors.grey, fontSize: 14),
    );
    return SideTitleWidget(axisSide: meta.axisSide, space: 16, child: text);
  }

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
                  category, // Nama parameter tetap 'category' untuk menjaga struktur
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
