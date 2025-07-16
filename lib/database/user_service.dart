// lib/database/user_service.dart

import 'dart:convert'; // Tambahkan ini jika Anda akan menggunakan JSON parsing
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart'; // Import user_model.dart

// Jika Anda memiliki API backend untuk update profil dan ganti password,
// Anda perlu menambahkan logika HTTP request di sini.
// Untuk saat ini, kita akan simulasikan dengan SharedPreferences.

class UserService {
  // Metode untuk mendapatkan data pengguna saat ini
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      final int id = prefs.getInt('user_id') ?? 0;
      final String name = prefs.getString('user_name') ?? 'Guest';
      final String email = prefs.getString('user_email') ?? 'guest@example.com';
      final String password = prefs.getString('user_password') ?? 'defaultpass'; // Ambil password (untuk simulasi change password)
      final String? profileImage = prefs.getString('user_profile_image'); // Ambil path gambar profil

      // Perlu diingat: menyimpan password di SharedPreferences itu TIDAK AMAN
      // Ini hanya untuk simulasi jika Anda tidak punya backend.
      // Di produksi, password tidak boleh disimpan di client.

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
    // Ini mungkin tidak diperlukan jika alur Anda selalu melewati login/register
    // Tapi jika diperlukan, pastikan logikanya sesuai dengan AuthService Anda
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('is_logged_in') ?? false)) {
      final defaultUser = User(
        id: 99, // ID dummy
        name: 'Guest User',
        email: 'guest@example.com',
        password: 'guestpassword',
        profileImage: null,
      );
      await prefs.setInt('user_id', defaultUser.id);
      await prefs.setString('user_name', defaultUser.name);
      await prefs.setString('user_email', defaultUser.email);
      await prefs.setString('user_password', defaultUser.password);
      await prefs.setBool('is_logged_in', true); // Anggap sebagai login
      return defaultUser;
    }
    return await getCurrentUser();
  }

  // Metode untuk memperbarui data pengguna
  Future<User?> updateUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', updatedUser.name);
    await prefs.setString('user_email', updatedUser.email);
    // Jika ada update gambar profil
    if (updatedUser.profileImage != null) {
      await prefs.setString('user_profile_image', updatedUser.profileImage!);
    }
    // Tidak mengupdate password di sini, hanya nama dan email
    return updatedUser;
  }

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

  // Metode untuk logout (akan memanggil logout dari AuthService atau mengosongkan SharedPreferences)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data di SharedPreferences
    // Jika Anda menggunakan AuthService untuk logout ke backend, panggil di sini
    // await AuthService().logout();
  }
}