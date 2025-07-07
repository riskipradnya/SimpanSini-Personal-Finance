// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_screen.dart';
import 'screens/sign_in_screen.dart';
import 'providers/transaction_provider.dart';

// 1. Ubah main menjadi async dan gunakan await untuk inisialisasi
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TransactionProvider())],
      child: const MyApp(),
    ),
  );
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
      // 2. Tambahkan delegates untuk mendukung lokalisasi ID
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID')],
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false,
    ); // 3. Kode duplikat di bagian akhir sudah dihapus
  }
}
