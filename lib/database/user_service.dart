// lib/database/user_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'dart:io'; // Import ini untuk File

class UserService {
  // Ganti dengan URL dasar API PHP Anda
  static const String _baseUrl = 'http://10.0.2.2/api_keuangan'; // UNTUK EMULATOR ANDROID: Gunakan 10.0.2.2
                                                                // UNTUK REAL DEVICE: Gunakan IP lokal komputer Anda (misal: http://192.168.1.x/api_keuangan)
                                                                // UNTUK WEB/DESKTOP: http://localhost/api_keuangan

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      final int id = prefs.getInt('user_id') ?? 0;
      final String name = prefs.getString('user_name') ?? 'Guest';
      final String email = prefs.getString('user_email') ?? 'guest@example.com';
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
  Future<User?> updateUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    // TODO: Tambahkan panggilan API untuk memperbarui nama dan email di database
    // Contoh:
    // final response = await http.post(Uri.parse('$_baseUrl/update_profile.php'), body: {...});
    await prefs.setString('user_name', updatedUser.name);
    await prefs.setString('user_email', updatedUser.email);
    return updatedUser;
  }

  // --- MODIFIKASI FUNGSI INI UNTUK MENGUPDATE GAMBAR PROFIL KE SERVER ---
  Future<User?> updateUserProfileImage(int userId, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = await getCurrentUser();

    if (currentUser != null && currentUser.id == userId) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/update_profile_image.php'),
        );
        request.fields['user_id'] = userId.toString();
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image', // Nama field di PHP untuk file
          imagePath,
        ));

        var response = await request.send();
        final respStr = await response.stream.bytesToString();
        final Map<String, dynamic> responseData = jsonDecode(respStr);

        if (response.statusCode == 200 && responseData['status'] == 'success') {
          final String imageUrl = responseData['profile_image_url'];

          // Simpan URL gambar yang baru ke SharedPreferences
          await prefs.setString('user_profile_image', imageUrl);
          
          // Hapus gambar lama dari penyimpanan lokal jika ada dan itu bukan URL
          // Ini adalah langkah opsional, tergantung apakah Anda ingin menghapus cache lokal
          // agar selalu fetch dari URL, atau tetap simpan cache lokal.
          // Untuk kasus ini, karena kita menyimpan URL dari server, kita tidak perlu
          // lagi menyimpan file di path_provider secara persisten,
          // cukup URLnya saja untuk ditampilkan menggunakan NetworkImage.
          // Jadi, kita bisa hapus logika path_provider sebelumnya di ProfileViewScreen
          // dan langsung gunakan URL dari server.

          return currentUser.copyWith(profileImage: imageUrl);
        } else {
          print('Failed to update profile image on server: ${responseData['message']}');
          return null;
        }
      } catch (e) {
        print('Exception during profile image update: $e');
        return null;
      }
    }
    return null; // Gagal mengupdate jika user tidak ditemukan atau tidak login
  }
  // --- AKHIR MODIFIKASI FUNGSI INI ---

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