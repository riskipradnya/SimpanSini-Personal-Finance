// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/sign_in_screen.dart'; // Tetap impor SignInScreen sebagai halaman awal
import 'screens/main_screen.dart'; // Import MainScreen

// Kode ini sudah benar
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpanSini Personal Finance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID')],
      home: const SignInScreen(), // Tetap mulai dari SignInScreen
      debugShowCheckedModeBanner: false,
      // Tambahkan route jika Anda menggunakan named routes
      routes: {
        '/main': (context) => const MainScreen(),
        // Anda juga bisa menambahkan route untuk ProfileEditScreen dan ChangePasswordScreen
        // jika Anda ingin menavigasi ke sana dari luar ProfileScreen,
        // tetapi untuk kasus ini, navigasi langsung dari ProfileScreen sudah cukup.
      },
    );
  }
}