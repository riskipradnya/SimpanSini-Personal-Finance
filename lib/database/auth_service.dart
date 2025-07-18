import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  // Ganti URL ini saat Anda sudah hosting
  // Untuk tes lokal, ganti dengan IP Address komputer Anda
  final String _baseUrl =
      "http://localhost/api_keuangan"; // <-- GANTI DENGAN IP ANDA

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

      // If login is successful, save user data to SharedPreferences
      if (data['status'] == 'success') {
        await _saveUserData(data['data']);
      }

      return data;
    } else {
      return {'status': 'error', 'message': 'Gagal terhubung ke server.'};
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', int.parse(userData['id'].toString()));
    await prefs.setString('user_name', userData['nama_lengkap']);
    await prefs.setString('user_email', userData['email']);
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

class UserService {
  final String _baseUrl = "http://localhost/api_keuangan";

  // Get current user from SharedPreferences
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final userName = prefs.getString('user_name');
    final userEmail = prefs.getString('user_email');
    final profileImage = prefs.getString('profile_image');

    if (userId != null && userName != null && userEmail != null) {
      return User(
        id: userId,
        namaLengkap: userName,
        email: userEmail,
        profileImage: profileImage,
      );
    }
    return null;
  }

  // Create default user if none exists
  Future<User> createDefaultUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = User(
      id: prefs.getInt('user_id') ?? 1,
      namaLengkap: prefs.getString('user_name') ?? 'User',
      email: prefs.getString('user_email') ?? 'user@example.com',
      profileImage: null,
    );
    return user;
  }

  // Update user profile
  Future<User?> updateUser(User user) async {
    try {
      // For now, we'll save to SharedPreferences
      // In a real app, you would send this to your server
      final prefs = await SharedPreferences.getInstance();

      // Save to local storage
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      if (user.profileImage != null) {
        await prefs.setString('profile_image', user.profileImage!);
      }

      // Simulate server call (uncomment when you have the server endpoint)
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/update_profile.php'),
        body: {
          'id': user.id.toString(),
          'nama_lengkap': user.name,
          'email': user.email,
          'profile_image': user.profileImage ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return user;
        }
      }
      */

      return user; // Return updated user for now
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  // Change password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      // Simulate server call (uncomment when you have the server endpoint)
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/change_password.php'),
        body: {
          'user_id': userId.toString(),
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      }
      */

      // For now, return true (simulate success)
      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }
}
