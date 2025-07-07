import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionService {
  // Use the same base URL as AuthService
  final String _baseUrl = "http://172.16.3.142/api_keuangan";

  // Get user ID from SharedPreferences
  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  // Add a new transaction
  Future<Map<String, dynamic>> addTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transactions/add.php'),
        body: transaction.toJson(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to add transaction. Server error.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to add transaction: ${e.toString()}',
      };
    }
  }

  // Get all transactions for the current user
  Future<Map<String, dynamic>> getTransactions() async {
    try {
      final userId = await _getUserId();
      final response = await http.get(
        Uri.parse('$_baseUrl/transactions/get_all.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          // Convert each transaction JSON to Transaction object
          final List<Transaction> transactions = (jsonData['data'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList();

          return {'status': 'success', 'data': transactions};
        } else {
          return jsonData;
        }
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch transactions. Server error.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to fetch transactions: ${e.toString()}',
      };
    }
  }

  // Get transaction summary (for statistics)
  Future<Map<String, dynamic>> getTransactionSummary() async {
    try {
      final userId = await _getUserId();
      final response = await http.get(
        Uri.parse('$_baseUrl/transactions/get_summary.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch transaction summary. Server error.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to fetch transaction summary: ${e.toString()}',
      };
    }
  }

  // Delete a transaction
  Future<Map<String, dynamic>> deleteTransaction(int transactionId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transactions/delete.php'),
        body: {'id': transactionId.toString()},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to delete transaction. Server error.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to delete transaction: ${e.toString()}',
      };
    }
  }
}
