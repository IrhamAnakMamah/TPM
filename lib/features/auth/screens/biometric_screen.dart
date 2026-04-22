import 'package:flutter/material.dart';

/// Halaman biometric/fingerprint (mockup).
///
/// Simulasi login dengan sidik jari untuk demo fitur sensor.
class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isScanning = false;
  String _statusText = 'Letakkan jari Anda pada sensor';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _statusText = 'Memindai sidik jari...';
    });
    _animController.repeat(reverse: true);

    // Simulasi proses scan selama 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      _animController.stop();
      _animController.reset();
      if (mounted) {
        setState(() {
          _isScanning = false;
          _statusText = 'Sidik jari dikenali! ✓';
        });

        // Navigate ke home setelah berhasil
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.teal.shade400, Colors.teal.shade900],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Autentikasi Biometrik',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Gunakan sidik jari untuk masuk',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Fingerprint Icon dengan animasi
                  GestureDetector(
                    onTap: _isScanning ? null : _startScan,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isScanning
                                ? Colors.tealAccent
                                : Colors.white.withValues(alpha: 0.5),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.fingerprint,
                          size: 60,
                          color: _isScanning ? Colors.tealAccent : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    _statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Tombol kembali ke login normal
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Gunakan Username & Password',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
