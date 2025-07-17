// lib/database/user_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Import http package
import '../models/user_model.dart';
// import 'dart:io'; // Tidak perlu jika hanya menyimpan path string

class UserService {
  // Ganti dengan URL dasar API PHP Anda
  static const String _baseUrl = 'http://localhost/api_keuangan'; // PASTIKAN SUDAH SEPERTI INI

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      final int id = prefs.getInt('user_id') ?? 0;
      final String name = prefs.getString('user_name') ?? 'Guest';
      final String email = prefs.getString('user_email') ?? 'guest@example.com';
      // Password tidak perlu diambil dari shared_preferences jika Anda akan verifikasi di backend
      final String? profileImage = prefs.getString('user_profile_image');

      return User(
        id: id,
        name: name,
        email: email,
        password: '', // Password sebaiknya tidak disimpan di lokal atau dikembalikan
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
  // Ini juga harus memanggil API jika Anda ingin memperbarui di database
  Future<User?> updateUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    // TODO: Tambahkan panggilan API untuk memperbarui nama dan email di database
    // Contoh:
    // final response = await http.post(Uri.parse('$_baseUrl/update_profile.php'), body: {...});
    await prefs.setString('user_name', updatedUser.name);
    await prefs.setString('user_email', updatedUser.email);
    return updatedUser;
  }

  // >>> TAMBAHKAN KEMBALI FUNGSI INI UNTUK MENGUPDATE GAMBAR PROFIL <<<
  Future<User?> updateUserProfileImage(int userId, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = await getCurrentUser();

    if (currentUser != null && currentUser.id == userId) {
      // TODO: Anda juga perlu menambahkan panggilan API di sini
      // jika Anda ingin menyimpan path gambar profil ke database melalui API PHP.
      // Contoh:
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/update_profile_image.php'),
      //   headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      //   body: jsonEncode({'user_id': userId, 'profile_image_path': imagePath}),
      // );
      //
      // if (response.statusCode == 200 && jsonDecode(response.body)['success']) {
      //   await prefs.setString('user_profile_image', imagePath);
      //   return currentUser.copyWith(profileImage: imagePath);
      // } else {
      //   print('Failed to update profile image on server.');
      //   return null;
      // }

      // Untuk saat ini, jika Anda hanya menyimpan di shared_preferences:
      await prefs.setString('user_profile_image', imagePath);
      // Mengembalikan User dengan gambar profil yang diperbarui
      return currentUser.copyWith(profileImage: imagePath);
    }
    return null; // Gagal mengupdate jika user tidak ditemukan atau tidak login
  }
  // <<< AKHIR FUNGSI BARU TAMBAHAN >>>

  // Metode untuk mengubah password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id'); // Ambil ID pengguna yang sedang login

    if (userId == null) {
      // Tidak ada pengguna yang login
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/change_password.php'), // <<< GANTI NAMA FILE PHP ANDA
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success']) {
          // Jika perubahan password berhasil di backend,
          // Anda bisa memilih untuk mengupdate shared_preferences juga,
          // atau mengabaikannya jika password tidak disimpan di lokal.
          // Saat ini, saya merekomendasikan untuk TIDAK menyimpan password di shared_preferences
          // setelah password di-hash di database.
          
          return true;
        } else {
          print('Failed to change password: ${responseData['message']}');
          return false;
        }
      } else {
        print('Server error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception during password change: $e');
      return false;
    }
  }

  // Metode untuk logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}