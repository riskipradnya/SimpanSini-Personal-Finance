// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart'; // <-- Path import diperbarui (tanpa ../)

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
        fontFamily: 'Poppins',
      ),
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}