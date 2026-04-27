import 'package:flutter/material.dart';
// Pastikan path import ini sesuai dengan lokasi file barista_balance_screen.dart milikmu
import 'features/mini_games/screens/barista_balance_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cafe Aggregator',
      // Home langsung kita arahkan ke game untuk diuji coba
      home: BaristaBalanceScreen(),
    );
  }
}
