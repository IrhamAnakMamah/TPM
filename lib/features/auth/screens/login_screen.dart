import 'package:flutter/material.dart';
import '../../../core/services/biometric_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _biometricService = BiometricService();
  bool _isBiometricAvailable = false;
  String _biometricType = 'Biometrik';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final canCheck = await _biometricService.canCheckBiometrics();
    final isSupported = await _biometricService.isDeviceSupported();
    final typeName = await _biometricService.getBiometricTypeName();
    
    if (mounted) {
      setState(() {
        _isBiometricAvailable = canCheck && isSupported;
        _biometricType = typeName;
      });
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Masuk ke PillPal-AI dengan $_biometricType',
    );

    if (mounted) {
      if (authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autentikasi berhasil!'), backgroundColor: Colors.green),
        );
        // Navigasi ke halaman utama
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autentikasi batal/gagal.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.local_pharmacy, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text('Selamat Datang', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 16),
              TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              // --- QUICK ACCESS BIOMETRIK ---
              if (_isBiometricAvailable) ...[
                const SizedBox(height: 40),
                Center(child: Text('Akses Cepat', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500))),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: _authenticateWithBiometric,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 65, height: 65,
                        decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle, border: Border.all(color: Colors.teal, width: 2)),
                        child: Icon(_biometricType == 'Face ID' ? Icons.face : Icons.fingerprint, color: Colors.teal, size: 35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(child: Text(_biometricType, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}