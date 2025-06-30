// lib/main.dart

import 'package:flutter/material.dart';
import 'login.dart'; // Import file login.dart yang baru dibuat

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sign In Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins', // Pastikan Anda memiliki font ini atau ganti
      ),
      // Panggil screen dari file login.dart
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
