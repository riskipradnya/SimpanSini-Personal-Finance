import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Ganti URL ini saat Anda sudah hosting
  // Untuk tes lokal, ganti dengan IP Address komputer Anda
  final String _baseUrl = "http://localhost/api_keuangan"; // <-- GANTI DENGAN IP ANDA

  // Fungsi untuk Registrasi (CREATE)
  Future<Map<String, dynamic>> signUp(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register.php'),
      body: {
        'nama_lengkap': name,
        'email': email,
        'password': password,
      },
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
      body: {
        'email': email,
        'password': password,
      },
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'status': 'error', 'message': 'Gagal terhubung ke server.'};
    }
  }

  // Nanti Anda bisa menambahkan fungsi update dan delete di sini
  // Future<Map<String, dynamic>> updateUser(...) async { ... }
  // Future<Map<String, dynamic>> deleteUser(...) async { ... }
}