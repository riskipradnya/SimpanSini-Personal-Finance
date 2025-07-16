// main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // <-- IMPORT BARU
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'pemasukan_screen.dart';
import 'pengeluaran_screen.dart';
import 'statistik_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  // --- GANTI KEY DENGAN VALUE NOTIFIER INI ---
  final ValueNotifier<int> _refreshNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _refreshNotifier.dispose(); // <-- JANGAN LUPA DISPOSE
    super.dispose();
  }

  // --- FUNGSI _refreshPages() BISA DIHAPUS, KITA TIDAK MEMBUTUHKANNYA LAGI ---

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }
  
  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          // ... (kode dialog tidak berubah)
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ... (Judul dan tombol close tidak berubah)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pilih Jenis Transaksi', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold,),),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop(),),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A4276),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PemasukanScreen()),);
                    
                    // --- UBAH LOGIKA REFRESH DI SINI ---
                    if (result == true) {
                      // Cukup naikkan nilai notifier untuk memicu refresh di child
                      _refreshNotifier.value++;
                    }
                  },
                  child: Text('Pemasukan', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,),),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PengeluaranScreen()),);
                    
                    // --- UBAH LOGIKA REFRESH DI SINI JUGA ---
                    if (result == true) {
                      _refreshNotifier.value++;
                    }
                  },
                  child: Text('Pengeluaran', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87,),),
                ),
              ],
            ),
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
        // --- UBAH CARA KITA MEMBERIKAN WIDGET DI SINI ---
        children: <Widget>[
          HomeScreen(refreshNotifier: _refreshNotifier),
          StatistikScreen(refreshNotifier: _refreshNotifier),
          const Center(child: Text('Wishlist')),
          const Center(child: Text('Profile')),
        ],
      ),
      // ... (Sisa kode (BottomNavBar, FAB, dll) tidak perlu diubah) ...
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        backgroundColor: const Color(0xFF3A4276),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ... (Sisa kode _buildBottomNavBar dan _navItem tidak perlu diubah) ...
  Widget _buildBottomNavBar() {
    // Kode ini tetap sama
    return BottomAppBar(
      // shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.home_filled, 'Home', _selectedIndex == 0, () {
              _onItemTapped(0);
            }),
            _navItem(Icons.bar_chart_rounded, 'Statistic', _selectedIndex == 1,
                () {
              _onItemTapped(1);
            }),
            const SizedBox(width: 40),
            _navItem(Icons.star_border_rounded, 'Wishlist', _selectedIndex == 2,
                () {
              _onItemTapped(2);
            }),
            _navItem(
                Icons.person_outline_rounded, 'Profil', _selectedIndex == 3,
                () {
              _onItemTapped(3);
            }),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    // Kode ini tetap sama
    final color = isActive ? const Color(0xFF3A4276) : Colors.grey[400];
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}