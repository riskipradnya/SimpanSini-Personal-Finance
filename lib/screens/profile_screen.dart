import 'package:flutter/material.dart';
import 'dart:io'; 
import '../models/user_model.dart';
import '../database/auth_service.dart';
import 'main_screen.dart'; 
import 'sign_in_screen.dart';
import 'profile_edit_screen.dart'; 
import 'change_password_screen.dart'; 

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
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    if (_currentUser == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditScreenWrapper(user: _currentUser!),
      ),
    );

    if (result is User) {
      setState(() {
        _currentUser = result;
      });
      // Trigger refresh of home screen to update profile image
      _triggerHomeScreenRefresh();
    }
  }

  void _triggerHomeScreenRefresh() {
    // Simple refresh mechanism without finding ancestor state
    try {

      print('Profile updated - home screen refresh triggered');
    } catch (e) {
      print('Error triggering refresh: $e');
    }
  }

  Future<void> _navigateToChangePassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreenWrapper(),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_currentUser?.profileImage != null &&
        _currentUser!.profileImage!.isNotEmpty) {
      return Image.file(
        File(_currentUser!.profileImage!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
          );
        },
      );
    } else {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.person, size: 40, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom App Bar
        Container(
          padding: const EdgeInsets.only(
            top: 50,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          color: Colors.white,
          child: const Row(
            children: [
              SizedBox(width: 48),
              Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 48),
            ],
          ),
        ),
        // Main Content
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
                          // Profile Image and Name
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
                                child: ClipOval(child: _buildProfileImage()),
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

                          // Personal Info Section
                          _buildSectionHeader('Info Pribadi'),
                          const SizedBox(height: 16),
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: 'Your Profile',
                            onTap: _navigateToEditProfile,
                          ),
 
                          const SizedBox(height: 32),

                          // Security Section
                          _buildSectionHeader('Keamanan'),
                          const SizedBox(height: 16),
                          _buildMenuItem(
                            icon: Icons.lock_outline,
                            title: 'Ubah Password',
                            onTap: _navigateToChangePassword,
                          ),
                          // const SizedBox(height: 8), // DIHAPUS
                          // _buildMenuItem( // DIHAPUS
                          //   icon: Icons.lock_outline, // DIHAPUS
                          //   title: 'Forgot Password', // DIHAPUS
                          //   onTap: () { // DIHAPUS
                          //     // Navigate to forgot password // DIHAPUS
                          //     _showForgotPasswordDialog(); // DIHAPUS
                          //   }, // DIHAPUS
                          // ), // DIHAPUS
                          const SizedBox(height: 60),

                          // Logout Button
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }


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
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement logout logic here
              _handleLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    try {
      await AuthService().logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error during logout: $e')));
      }
    }
  }
}