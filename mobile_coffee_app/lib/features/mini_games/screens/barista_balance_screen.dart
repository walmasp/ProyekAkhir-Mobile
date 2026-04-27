import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class BaristaBalanceScreen extends StatefulWidget {
  const BaristaBalanceScreen({Key? key}) : super(key: key);

  @override
  State<BaristaBalanceScreen> createState() => _BaristaBalanceScreenState();
}

class _BaristaBalanceScreenState extends State<BaristaBalanceScreen> {
  // Variabel State Game
  int _timeLeft = 30;
  Timer? _timer;
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  bool _isPlaying = false;
  bool _isGameOver = false;

  // Variabel Sensor
  double _x = 0.0;
  double _y = 0.0;
  final double _threshold = 3.0; // Batas kemiringan sebelum kopi tumpah

  @override
  void dispose() {
    // WAJIB: Matikan timer dan sensor saat keluar layar agar tidak memory leak
    _timer?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _timeLeft = 30;
      _isPlaying = true;
      _isGameOver = false;
    });

    // 1. Mulai Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _winGame();
      }
    });

    // 2. Mulai Membaca Sensor Accelerometer
    _sensorSubscription = accelerometerEventStream().listen((event) {
      if (_isPlaying) {
        setState(() {
          _x = event.x;
          _y = event.y;
        });

        // 3. Logika Kopi Tumpah (Cek Threshold)
        if (_x > _threshold ||
            _x < -_threshold ||
            _y > _threshold ||
            _y < -_threshold) {
          _loseGame();
        }
      }
    });
  }

  void _loseGame() {
    _timer?.cancel();
    _sensorSubscription?.cancel();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
  }

  void _winGame() {
    _timer?.cancel();
    _sensorSubscription?.cancel();
    setState(() {
      _isPlaying = false;
    });
    _showPrizeDialog();
  }

  // 4. Pop-up Hadiah Visual
  void _showPrizeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("🎉 SELAMAT! 🎉", textAlign: TextAlign.center),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_cafe, size: 60, color: Colors.brown),
              SizedBox(height: 15),
              Text(
                "Kamu jago menyeimbangkan kopi!\n\nTunjukkan layar ini ke kasir saat check-in untuk klaim Gorengan Gratis / Diskon 10%.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Tutup & Klaim Nanti"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text("Barista Balance"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Teks
            Text(
              _isPlaying
                  ? "Tahan HP kamu tetap datar!"
                  : _isGameOver
                  ? "Yah, kopinya tumpah! 😭"
                  : "Siap jadi Barista?",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Timer Teks
            Text(
              "Waktu: $_timeLeft s",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: _timeLeft <= 10 ? Colors.red : Colors.brown,
              ),
            ),
            const SizedBox(height: 40),

            // Animasi Kopi Sederhana (Bergerak sesuai sumbu X dan Y)
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.brown[200],
                shape: BoxShape.circle,
              ),
              child: Transform.translate(
                // Membalikkan arah visual agar terasa seperti cairan
                offset: Offset(_x * -15, _y * 15),
                child: Icon(
                  _isGameOver ? Icons.water_drop : Icons.local_cafe,
                  size: 80,
                  color: _isGameOver ? Colors.blue : Colors.brown[800],
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Tombol Mulai / Main Lagi
            if (!_isPlaying)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _startGame,
                child: Text(
                  _isGameOver ? "Coba Lagi" : "Mulai Game",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
