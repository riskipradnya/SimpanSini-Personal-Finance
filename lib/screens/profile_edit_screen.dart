// // lib/screens/profile_edit_screen.dart
// import 'package:flutter/material.dart';
// import 'dart:io'; // <-- TAMBAHKAN INI UNTUK File
// import '../models/user_model.dart';
// import '../database/user_service.dart';

// class ProfileEditScreen extends StatefulWidget {
//   final User user;

//   const ProfileEditScreen({super.key, required this.user});

//   @override
//   State<ProfileEditScreen> createState() => _ProfileEditScreenState();
// }

// class _ProfileEditScreenState extends State<ProfileEditScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.user.name);
//     _emailController = TextEditingController(text: widget.user.email);
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final updatedUser = widget.user.copyWith(
//         name: _nameController.text.trim(),
//         email: _emailController.text.trim(),
//         // profileImage tidak diupdate di sini, karena ada fungsi terpisah
//       );

//       final result = await UserService().updateUser(updatedUser);

//       if (mounted) {
//         if (result != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Profile updated successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           Navigator.pop(context, result); // Mengirimkan user yang telah diupdate
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Failed to update profile'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error updating profile: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           // Custom App Bar
//           Container(
//             padding: const EdgeInsets.only(
//               top: 50,
//               left: 16,
//               right: 16,
//               bottom: 16,
//             ),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//                   onPressed: () => Navigator.pop(context, widget.user), // Kembali dengan user original jika tidak ada update
//                 ),
//                 const Expanded(
//                   child: Text(
//                     'Edit Profile',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 48),
//               ],
//             ),
//           ),
//           // Main Content
//           Expanded(
//             child: Container(
//               color: Colors.white,
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 20),
//                         // Profile Image
//                         Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.grey.shade300,
//                               width: 2,
//                             ),
//                           ),
//                           child: ClipOval(
//                             child: widget.user.profileImage != null && widget.user.profileImage!.isNotEmpty
//                                 ? Image.file( // UBAH DARI Image.asset KE Image.file
//                                     File(widget.user.profileImage!), // Menggunakan File dari path
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Container(
//                                         color: Colors.grey.shade200,
//                                         child: const Icon(
//                                           Icons.person,
//                                           size: 50,
//                                           color: Colors.grey,
//                                         ),
//                                       );
//                                     },
//                                   )
//                                 : Container(
//                                     color: Colors.grey.shade200,
//                                     child: const Icon(
//                                       Icons.person,
//                                       size: 50,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         TextButton(
//                           onPressed: () {
//                             // Untuk saat ini, biarkan ini menampilkan snackbar atau Anda bisa mengarahkan ke ProfileViewScreen untuk ganti foto
//                             // Atau implementasikan _pickImage di sini juga
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Change photo feature available in Your Profile page'),
//                               ),
//                             );
//                           },
//                           child: const Text('Change Photo'),
//                         ),
//                         const SizedBox(height: 32),
//                         // Name Field
//                         TextFormField(
//                           controller: _nameController,
//                           decoration: const InputDecoration(
//                             labelText: 'Full Name',
//                             border: OutlineInputBorder(),
//                             prefixIcon: Icon(Icons.person_outline),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Please enter your name';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         // Email Field
//                         TextFormField(
//                           controller: _emailController,
//                           decoration: const InputDecoration(
//                             labelText: 'Email',
//                             border: OutlineInputBorder(),
//                             prefixIcon: Icon(Icons.email_outlined),
//                           ),
//                           keyboardType: TextInputType.emailAddress,
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Please enter your email';
//                             }
//                             if (!value.contains('@')) {
//                               return 'Please enter a valid email';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 32),
//                         // Save Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _saveProfile,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF6C63FF),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: _isLoading
//                                 ? const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   )
//                                 : const Text(
//                                     'Save Changes',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }