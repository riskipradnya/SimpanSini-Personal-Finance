// lib/services/transaction_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart'; // Pastikan path ini benar
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  final String _baseUrl = "http://localhost/api_keuangan";

  // Mendapatkan user ID dari SharedPreferences
  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  // --- FUNGSI UNTUK MENAMBAH TRANSAKSI (PEMASUKAN & PENGELUARAN) ---
  /// Menambah transaksi baru (pemasukan atau pengeluaran).
  Future<Map<String, dynamic>> addTransaction(Transaction transaction) async {
    // Ambil user_id dan gabungkan dengan data transaksi
    final transactionData = transaction.toJson();
    transactionData['user_id'] = await _getUserId();

    // Mengirim data ke satu endpoint universal: add_transaction.php
    final response = await http.post(
      Uri.parse('$_baseUrl/add_transaction.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(transactionData),
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print('Error parsing JSON from addTransaction: $e');
        print('Response body: ${response.body}');
        return {'status': 'error', 'message': 'Invalid response from server'};
      }
    } else {
      return {'status': 'error', 'message': 'Failed to connect to the server'};
    }
  }

  // --- FUNGSI UNTUK MENGAMBIL DATA TRANSAKSI ---

  /// Mengambil dan memproses daftar transaksi dari URL yang diberikan.
  Future<List<Transaction>> _fetchAndParseTransactions(Uri uri) async {
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load transactions. Status code: ${response.statusCode}',
      );
    }

    try {
      if (response.body.trim().startsWith('{')) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final List<dynamic> transactionData = data['data'];
          return transactionData
              .map((item) => Transaction.fromJson(item))
              .toList();
        }
      }
      print('Unexpected or unsuccessful response format: ${response.body}');
      return [];
    } on FormatException catch (e) {
      print('Error parsing JSON: $e');
      print('Response body: ${response.body}');
      return [];
    }
  }

  /// Mendapatkan semua transaksi untuk pengguna.
  Future<List<Transaction>> getAllTransactions() async {
    final userId = await _getUserId();
    final uri = Uri.parse('$_baseUrl/transactions.php?user_id=$userId');
    return _fetchAndParseTransactions(uri);
  }

  /// Mendapatkan transaksi berdasarkan tipe (pemasukan atau pengeluaran).
  Future<List<Transaction>> getTransactionsByType(String type) async {
    final userId = await _getUserId();
    final uri = Uri.parse(
      '$_baseUrl/transactions.php?user_id=$userId&type=$type',
    );
    return _fetchAndParseTransactions(uri);
  }

  /// Mendapatkan transaksi berdasarkan rentang tanggal.
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final userId = await _getUserId();

    // Format dates to YYYY-MM-DD
    String formattedStartDate =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String formattedEndDate =
        "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    final uri = Uri.parse(
      '$_baseUrl/transactions.php?user_id=$userId&start_date=$formattedStartDate&end_date=$formattedEndDate',
    );

    // If the API endpoint doesn't support date filtering yet, we'll fetch all transactions
    // and filter them in the client side
    final allTransactions = await _fetchAndParseTransactions(uri);

    // Client-side filtering by date
    return allTransactions.where((transaction) {
      return transaction.date.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Fungsi lainnya tetap sama...
}
