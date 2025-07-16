// lib/database/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl =
      "http://localhost/api_keuangan"; // <-- GANTI DENGAN IP ANDA

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

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login.php'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        // PENTING: Pastikan data['data'] mengandung 'password' dan 'profile_image'
        // Jika API Anda tidak mengembalikan password, Anda tidak bisa menyimpannya.
        // Jika API Anda tidak mengembalikan profile_image, Anda bisa mengosongkannya.
        await _saveUserData(data['data'], password); // Kirim password ke _saveUserData
      }

      return data;
    } else {
      return {'status': 'error', 'message': 'Gagal terhubung ke server.'};
    }
  }

  // Save user data to SharedPreferences
  // Tambahkan parameter password untuk disimpan di SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> userData, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', int.parse(userData['id'].toString()));
    await prefs.setString('user_name', userData['nama_lengkap']);
    await prefs.setString('user_email', userData['email']);
    await prefs.setString('user_password', password); // Simpan password yang dimasukkan
    await prefs.setString('user_profile_image', userData['profile_image'] ?? ''); // Simpan profile_image jika ada
    await prefs.setBool('is_logged_in', true);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}