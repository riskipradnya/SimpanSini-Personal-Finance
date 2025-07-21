import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../database/auth_service.dart'; // Ganti 'auth_service' dengan nama file service Anda
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditScreen extends StatefulWidget {
  final User user;

  const ProfileEditScreen({super.key, required this.user});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    // Jika ada gambar profil yang sudah ada, inisialisasi _imageFile dengan path tersebut
    if (widget.user.profileImage != null && widget.user.profileImage!.isNotEmpty) {
      _imageFile = File(widget.user.profileImage!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        // LANGSUNG SIMPAN FOTO SETELAH DIPILIH
        await _saveProfile(isImageOnly: true); // Panggil _saveProfile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saat memilih gambar: $e')),
        );
      }
    }
  }

  // Tambahkan parameter opsional untuk menandakan jika hanya gambar yang disimpan
  Future<void> _saveProfile({bool isImageOnly = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? profileImagePath = widget.user.profileImage;
      if (_imageFile != null) {
        profileImagePath = _imageFile!.path;
        print('Selected image path: $profileImagePath'); // Debug log
      }

      final updatedUser = widget.user.copyWith(
        // Nama dan email tetap dari data user lama karena readOnly
        profileImage: profileImagePath,
        updatedAt: DateTime.now(),
      );

      print('Updating user: ${updatedUser.toJson()}'); // Debug log

      final result = await UserService().updateUser(updatedUser); // Panggil fungsi update

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui'), // Pesan lebih spesifik
            backgroundColor: Colors.green,
          ),
        );
        
        // Force refresh of SharedPreferences
        await _saveToSharedPreferences(result);
        
        // Jika hanya mengubah gambar, tetap di halaman ini.
        // Jika ada perubahan lain dan Anda ingin kembali, baru panggil pop.
        // Dalam kasus ini, karena hanya gambar yang bisa diubah dan langsung disimpan,
        // kita tidak perlu pop otomatis. Biarkan user kembali secara manual.
        // Navigator.pop(context, result); // DIHAPUS agar tidak langsung keluar halaman
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui foto profil'), // Pesan lebih spesifik
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in _saveProfile: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memperbarui foto profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveToSharedPreferences(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      if (user.profileImage != null) {
        await prefs.setString('profile_image', user.profileImage!);
      }
      print('Saved to SharedPreferences: ${user.name}, ${user.profileImage}'); // Debug log
    } catch (e) {
      print('Error saving to SharedPreferences: $e');
    }
  }

  Widget _buildProfileImage() {
    // Jika ada file gambar baru yang dipilih dari galeri
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    }
    // Jika ada gambar profil dari data user (dari SharedPrefs)
    if (widget.user.profileImage != null &&
        widget.user.profileImage!.isNotEmpty) {
      // PENTING: Jika profileImage adalah URL dari internet, gunakan Image.network.
      // Jika ini adalah path file lokal, gunakan Image.file.
      // Asumsi saat ini adalah path lokal.
      // Cek apakah file benar-benar ada sebelum mencoba memuatnya
      if (File(widget.user.profileImage!).existsSync()) {
        return Image.file(
          File(widget.user.profileImage!),
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            // Fallback jika ada error saat memuat file
            return _buildDefaultAvatar();
          },
        );
      }
    }
    // Jika tidak ada gambar sama sekali atau file tidak ditemukan
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading // Tampilkan loading indicator di tengah halaman jika sedang memuat
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage, // Ini tetap bisa diklik untuk ganti foto
                        child: ClipOval(child: _buildProfileImage()),
                      ),
                      TextButton(
                        onPressed: _pickImage, // Tombol "Ganti Foto"
                        child: const Text('Ganti Foto'),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 60), // Beri sedikit padding bawah
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}