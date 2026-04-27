import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Untuk tembak API
import 'dart:convert'; // Untuk encode JSON
import 'package:shared_preferences/shared_preferences.dart'; // Untuk simpan status biometrik
import 'login_screen.dart';
import '../../../api_config.dart'; // Keluar 3 folder: screens -> auth -> features -> lib

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _enableBiometric = false;
  bool _isLoading = false; // Untuk indikator loading

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- FUNGSI REGISTER CONNECT KE BACKEND ---
  Future<void> _handleRegister() async {
    // 1. Validasi lokal
    if (_namaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar("Semua kolom wajib diisi!");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Password dan Konfirmasi tidak cocok!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Kirim data ke API Backend
      // Endpoint: http://IP_LAPTOP:3000/api/register
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nama": _namaController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "role": "pelanggan", // Sesuai default di authController.js
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // --- REGISTRASI BERHASIL ---

        // 3. Simpan pilihan Biometrik ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('use_biometric', _enableBiometric);

        if (_enableBiometric) {
          // Simpan email juga untuk memudahkan login biometrik nantinya
          await prefs.setString('saved_email', _emailController.text);
        }

        if (!mounted) return;
        _showSnackBar(responseData['message'] ?? "Registrasi Berhasil!");

        // Pindah ke Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // --- REGISTRASI GAGAL (Misal email sudah ada) ---
        _showSnackBar(responseData['message'] ?? "Gagal Registrasi");
      }
    } catch (e) {
      // --- ERROR KONEKSI (Server mati / IP salah) ---
      _showSnackBar(
        "Error: Tidak dapat terhubung ke server. Periksa IP & koneksi!",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add_alt_1, size: 80, color: Colors.brown),
              const SizedBox(height: 20),
              const Text(
                "Daftar Akun",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: "Nama",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Konfirmasi Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SwitchListTile(
                title: const Text("Aktifkan Login Sidik Jari"),
                subtitle: const Text(
                  "Gunakan sidik jari untuk login lebih cepat nantinya",
                  style: TextStyle(fontSize: 12),
                ),
                value: _enableBiometric,
                activeColor: Colors.brown,
                contentPadding: EdgeInsets.zero,
                onChanged: (bool value) {
                  setState(() {
                    _enableBiometric = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator(color: Colors.brown)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.brown,
                      ),
                      onPressed: _handleRegister,
                      child: const Text(
                        "DAFTAR",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),

              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Sudah punya akun? Login di sini",
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
