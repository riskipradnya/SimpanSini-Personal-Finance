// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = "http://localhost/api_keuangan";

  // Fungsi untuk Registrasi (CREATE)
  Future<Map<String, dynamic>> signUp(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register.php'),
      body: {'nama_lengkap': name, 'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'status': 'error', 'message': 'Gagal terhubung ke server.'};
    }
  }

  // Fungsi untuk Login (READ)
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login.php'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Jika login berhasil, simpan data pengguna ke SharedPreferences
      if (data['status'] == 'success') {
        await _saveUserData(data['data']);
      }

      return data;
    } else {
      return {'status': 'error', 'message': 'Gagal terhubung ke server.'};
    }
  }

  // Simpan data pengguna ke SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', int.parse(userData['id'].toString()));
    await prefs.setString('user_name', userData['nama_lengkap']);
    await prefs.setString('user_email', userData['email']);
    await prefs.setBool('is_logged_in', true);
  }

  // Cek apakah pengguna sudah login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // FUNGSI addIncome DAN addExpense DIHAPUS DARI SINI
}
