import 'package:flutter/material.dart';
import '../../features/mini_games/screens/barista_balance_screen.dart';
import '../../features/profile/screens/profile_screen.dart'; 

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Daftar halaman sesuai menu
  final List<Widget> _pages = [
    const CafeHomeScreen(), // Sekarang ngambil dari class di bawah
    const CafeMapsScreen(), // Sekarang ngambil dari class di bawah
    const BaristaBalanceScreen(), 
    const ProfileScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.coffee), label: 'Cafe'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: 'Game'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ====================================================================
// KITA TARUH HALAMAN DUMMY NYA DI SINI SEMENTARA BIAR TIDAK ERROR
// Nanti kalau API-nya sudah jalan, baru kita pisah lagi ke file sendiri
// ====================================================================

class CafeHomeScreen extends StatelessWidget {
  const CafeHomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Ini Halaman Daftar Cafe (Segera disambung ke API)", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

class CafeMapsScreen extends StatelessWidget {
  const CafeMapsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Ini Halaman Peta LBS", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}