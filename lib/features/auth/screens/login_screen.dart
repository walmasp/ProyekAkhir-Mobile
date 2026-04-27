import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../shared/layout/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  // Fungsi Login Biometrik yang sudah diperbaiki
  Future<void> _handleBiometricLogin() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Gunakan sidik jari untuk masuk ke Cafe App',
        // Bagian options dihapus agar menyesuaikan dengan versi package kamu
      );

      if (authenticated) {
        // Jika berhasil, pindah ke Navigasi Utama
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      print("Error Biometrik: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_cafe, size: 100, color: Colors.brown),
            const SizedBox(height: 20),
            const Text(
              "Cafe Agregator",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Input Login Manual (Hanya UI dulu)
            const TextField(
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.brown,
              ),
              onPressed: () {
                // Login manual nanti disambungkan ke API Backend-mu
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainNavigationScreen(),
                  ),
                );
              },
              child: const Text("LOGIN", style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 20),
            const Text("Atau masuk dengan"),
            IconButton(
              icon: const Icon(
                Icons.fingerprint,
                size: 50,
                color: Colors.brown,
              ),
              onPressed: _handleBiometricLogin,
            ),
          ],
        ),
      ),
    );
  }
}
