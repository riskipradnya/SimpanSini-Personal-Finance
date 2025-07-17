// lib/database/user_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
// import 'dart:io'; // Tidak perlu jika hanya menyimpan path string

class UserService {
  // Metode untuk mendapatkan data pengguna saat ini
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      final int id = prefs.getInt('user_id') ?? 0;
      final String name = prefs.getString('user_name') ?? 'Guest';
      final String email = prefs.getString('user_email') ?? 'guest@example.com';
      final String password = prefs.getString('user_password') ?? 'defaultpass';
      final String? profileImage = prefs.getString('user_profile_image'); // Ambil path gambar profil

      return User(
        id: id,
        name: name,
        email: email,
        password: password,
        profileImage: profileImage,
      );
    }
    return null;
  }

  // Metode untuk membuat pengguna default (jika tidak ada yang login)
  Future<User?> createDefaultUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('is_logged_in') ?? false)) {
      final defaultUser = User(
        id: 99,
        name: 'Guest User',
        email: 'guest@example.com',
        password: 'guestpassword',
        profileImage: null,
      );
      await prefs.setInt('user_id', defaultUser.id);
      await prefs.setString('user_name', defaultUser.name);
      await prefs.setString('user_email', defaultUser.email);
      await prefs.setString('user_password', defaultUser.password);
      await prefs.setBool('is_logged_in', true);
      return defaultUser;
    }
    return await getCurrentUser();
  }

  // Metode untuk memperbarui data pengguna (nama dan email)
  Future<User?> updateUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', updatedUser.name);
    await prefs.setString('user_email', updatedUser.email);
    // Tidak mengupdate profileImage di sini karena ada fungsi terpisah untuk itu
    // dan tidak mengupdate password di sini
    return updatedUser;
  }

  // >>> TAMBAHKAN FUNGSI INI UNTUK MENGUPDATE GAMBAR PROFIL <<<
  Future<User?> updateUserProfileImage(int userId, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = await getCurrentUser();

    if (currentUser != null && currentUser.id == userId) {
      await prefs.setString('user_profile_image', imagePath);
      // Mengembalikan User dengan gambar profil yang diperbarui
      return currentUser.copyWith(profileImage: imagePath);
    }
    return null; // Gagal mengupdate jika user tidak ditemukan
  }
  // <<< AKHIR FUNGSI BARU >>>

  // Metode untuk mengubah password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedPassword = prefs.getString('user_password');

    if (storedPassword == currentPassword) {
      await prefs.setString('user_password', newPassword);
      return true;
    }
    return false;
  }

  // Metode untuk logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}