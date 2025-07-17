// lib/screens/profil_screen.dart
import 'package:flutter/material.dart';
// import 'dart:io'; // Hapus import ini karena sudah Image.network
import '../models/user_model.dart';
import '../database/user_service.dart';
import 'change_password_screen.dart';
import 'sign_in_screen.dart';
import 'profile_view_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await UserService().getCurrentUser();
      user ??= await UserService().createDefaultUser();

      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToProfileView() async {
    if (_currentUser == null) {
      _showSnackBar('User data not loaded yet.');
      return;
    }

    final bool? profileUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileViewScreen(user: _currentUser!),
      ),
    );

    if (profileUpdated == true) {
      _loadUserData();
    }
  }

  Future<void> _navigateToChangePassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }

  void _handleLogout() async {
    try {
      await UserService().logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // Fungsi _showForgotPasswordDialog ini tidak akan pernah terpanggil jika menu dihilangkan,
  // tapi tidak ada salahnya membiarkannya atau bisa dihapus juga jika mau.
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text('This feature will help you reset your password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Forgot Password feature coming soon');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 50,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          color: Colors.white,
          child: Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _currentUser?.profileImage != null && _currentUser!.profileImage!.isNotEmpty
                                      ? Image.network( // Sudah Image.network
                                          _currentUser!.profileImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.person,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _currentUser?.name ?? 'Loading...',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          _buildSectionHeader('Personal Info'),
                          const SizedBox(height: 16),
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: 'Your Profile',
                            onTap: _navigateToProfileView,
                          ),
                          const SizedBox(height: 8),
                          // Hapus atau komentari blok di bawah ini untuk menghilangkan "History Transaction"
                          /*
                          _buildMenuItem(
                            icon: Icons.history,
                            title: 'History Transaction',
                            onTap: () {
                              _showSnackBar('History Transaction clicked');
                            },
                          ),
                          */
                          // Sesuaikan SizedBox jika diperlukan setelah penghapusan
                          // const SizedBox(height: 32), // Jika Anda hanya menghapus satu, ini mungkin tidak perlu diubah

                          _buildSectionHeader('Security'),
                          const SizedBox(height: 16),
                          _buildMenuItem(
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            onTap: _navigateToChangePassword,
                          ),
                          const SizedBox(height: 8),
                          // Hapus atau komentari blok di bawah ini untuk menghilangkan "Forgot Password"
                          /*
                          _buildMenuItem(
                            icon: Icons.lock_outline,
                            title: 'Forgot Password',
                            onTap: _showForgotPasswordDialog,
                          ),
                          */
                          // Sesuaikan SizedBox jika diperlukan setelah penghapusan
                          // const SizedBox(height: 60), // Jika Anda hanya menghapus satu, ini mungkin tidak perlu diubah

                          GestureDetector(
                            onTap: _showLogoutDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}