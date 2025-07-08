import 'package:flutter/material.dart';
import 'home_screen.dart'; // Changed from package import to relative path
import 'pemasukan_screen.dart'; // Changed from package import to relative path
import 'pengeluaran_screen.dart'; // Changed from package import to relative path
import 'statistik_screen.dart'; // Changed from package import to relative path

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddTransactionDialog();
    } else {
      setState(() {
        _selectedIndex = index;
        _pageController.jumpToPage(index);
      });
    }
  }

  void _showAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.green),
                title: const Text('Tambah Pemasukan'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PemasukanScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.red),
                title: const Text('Tambah Pengeluaran'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PengeluaranScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const <Widget>[
          HomeScreen(),
          StatistikScreen(),
          Center(child: Text('Add Placeholder')), // Placeholder for index 2
          Center(child: Text('Profile')),
        ],
      ),
      // Bottom navigation bar removed as it's already in home_screen.dart
    );
  }
}
