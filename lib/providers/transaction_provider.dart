import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../database/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String _errorMessage = '';
  double _totalIncome = 0;
  double _totalExpense = 0;
  Map<String, double> _monthlyIncome = {};
  Map<String, double> _monthlyExpense = {};

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _totalIncome - _totalExpense;
  Map<String, double> get monthlyIncome => _monthlyIncome;
  Map<String, double> get monthlyExpense => _monthlyExpense;

  final TransactionService _transactionService = TransactionService();

  // Fetch all transactions
  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _transactionService.getTransactions();

      if (result['status'] == 'success') {
        _transactions = result['data'];
        _calculateSummary();
        _errorMessage = '';
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch transactions: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new transaction
  Future<bool> addTransaction(Transaction transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _transactionService.addTransaction(transaction);

      if (result['status'] == 'success') {
        await fetchTransactions(); // Refresh the list
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to add transaction: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a transaction
  Future<bool> deleteTransaction(int transactionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _transactionService.deleteTransaction(transactionId);

      if (result['status'] == 'success') {
        await fetchTransactions(); // Refresh the list
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to delete transaction: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Calculate summary data
  void _calculateSummary() {
    _totalIncome = 0;
    _totalExpense = 0;
    _monthlyIncome = {};
    _monthlyExpense = {};

    for (var transaction in _transactions) {
      // Calculate totals
      if (transaction.type == 'income') {
        _totalIncome += transaction.amount;
      } else {
        _totalExpense += transaction.amount;
      }

      // Calculate monthly data for charts
      final monthYear =
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';

      if (transaction.type == 'income') {
        _monthlyIncome[monthYear] =
            (_monthlyIncome[monthYear] ?? 0) + transaction.amount;
      } else {
        _monthlyExpense[monthYear] =
            (_monthlyExpense[monthYear] ?? 0) + transaction.amount;
      }
    }
  }

  // Get recent transactions
  List<Transaction> getRecentTransactions({int limit = 5}) {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return sorted.take(limit).toList();
  }

  // Get transactions by type
  List<Transaction> getTransactionsByType(String type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // Get chart data for last 6 months
  List<Map<String, dynamic>> getChartData() {
    final List<Map<String, dynamic>> chartData = [];
    final now = DateTime.now();

    // Generate data for the last 6 months
    for (int i = 5; i >= 0; i--) {
      final month = now.month - i <= 0 ? now.month - i + 12 : now.month - i;

      final year = now.month - i <= 0 ? now.year - 1 : now.year;

      final monthYear = '$year-${month.toString().padLeft(2, '0')}';

      chartData.add({
        'month': month,
        'income': _monthlyIncome[monthYear] ?? 0,
        'expense': _monthlyExpense[monthYear] ?? 0,
      });
    }

    return chartData;
  }

  // Clear all data (e.g., for logout)
  void clear() {
    _transactions = [];
    _totalIncome = 0;
    _totalExpense = 0;
    _monthlyIncome = {};
    _monthlyExpense = {};
    _errorMessage = '';
    notifyListeners();
  }
}
