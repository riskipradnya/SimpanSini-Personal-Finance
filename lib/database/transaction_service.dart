import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  // Base URL untuk API
  final String _baseUrl =
      "http://localhost/api_keuangan"; // Ganti dengan URL API Anda

  // Mendapatkan user ID dari shared preferences
  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  // Mendapatkan semua transaksi untuk pengguna
  Future<List<Transaction>> getAllTransactions() async {
    final userId = await _getUserId();
    final response = await http.get(
      Uri.parse('$_baseUrl/transactions.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      try {
        // Cek apakah response body diawali dengan karakter '{' (JSON) atau tidak
        if (response.body.trim().startsWith('{')) {
          final data = json.decode(response.body);
          if (data is Map<String, dynamic> && data['status'] == 'success') {
            return (data['data'] as List)
                .map((item) => Transaction.fromJson(item))
                .toList();
          } else {
            return [];
          }
        } else {
          print('Unexpected response format in getAllTransactions:');
          print('Response body: ${response.body}');
          return [];
        }
      } on FormatException catch (e) {
        // Ini akan menangkap error jika respon bukan JSON yang valid
        print('Error parsing JSON from getAllTransactions: $e');
        print(
          'Response body: ${response.body}',
        ); // Tampilkan respon asli dari server
        return []; // Kembalikan list kosong agar aplikasi tidak crash
      }
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  // Menambah transaksi baru
  Future<Map<String, dynamic>> addTransaction(Transaction transaction) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/add_transaction.php'),
      body: transaction.toJson().map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );
    if (response.statusCode == 200) {
      try {
        if (response.body.trim().startsWith('{')) {
          return json.decode(response.body);
        } else {
          print('Unexpected response format in addTransaction:');
          print('Response body: ${response.body}');
          return {'status': 'error', 'message': 'Invalid response from server'};
        }
      } on FormatException catch (e) {
        print('Error parsing JSON from addTransaction: $e');
        print('Response body: ${response.body}');
        return {'status': 'error', 'message': 'Invalid response from server'};
      }
    } else {
      return {'status': 'error', 'message': 'Failed to connect to the server'};
    }
  }

  // Mendapatkan transaksi berdasarkan tipe (pemasukan atau pengeluaran)
  Future<List<Transaction>> getTransactionsByType(String type) async {
    final userId = await _getUserId();
    final response = await http.get(
      Uri.parse('$_baseUrl/transactions.php?user_id=$userId&type=$type'),
    );

    if (response.statusCode == 200) {
      try {
        if (response.body.trim().startsWith('{')) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            return (data['data'] as List)
                .map((item) => Transaction.fromJson(item))
                .toList();
          } else {
            return [];
          }
        } else {
          print('Unexpected response format in getTransactionsByType:');
          print('Response body: ${response.body}');
          return [];
        }
      } on FormatException catch (e) {
        print('Error parsing JSON from getTransactionsByType: $e');
        print('Response body: ${response.body}');
        return [];
      }
    } else {
      throw Exception('Failed to load transactions');
    }
    // Ensure a return value for all code paths
    return [];
  }

  // Mendapatkan transaksi berdasarkan rentang tanggal
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final userId = await _getUserId();
    final startDate = start.toIso8601String().split('T')[0];
    final endDate = end.toIso8601String().split('T')[0];

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/transactions.php?user_id=$userId&start_date=$startDate&end_date=$endDate',
      ),
    );

    if (response.statusCode == 200) {
      try {
        if (response.body.trim().startsWith('{')) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            return (data['data'] as List)
                .map((item) => Transaction.fromJson(item))
                .toList();
          } else {
            return [];
          }
        } else {
          print('Unexpected response format in getTransactionsByDateRange:');
          print('Response body: ${response.body}');
          return [];
        }
      } on FormatException catch (e) {
        print('Error parsing JSON from getTransactionsByDateRange: $e');
        print('Response body: ${response.body}');
        return [];
      }
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  // Mendapatkan ringkasan transaksi (untuk grafik)
  Future<Map<String, dynamic>> getTransactionSummary() async {
    final userId = await _getUserId();
    final response = await http.get(
      Uri.parse('$_baseUrl/transaction_summary.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } on FormatException catch (e) {
        print('Error parsing JSON from getTransactionSummary: $e');
        print('Response body: ${response.body}');
        throw Exception('Invalid summary data from server');
      }
    } else {
      throw Exception('Failed to load transaction summary');
    }
  }
}
