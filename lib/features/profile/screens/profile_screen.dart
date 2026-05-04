import 'package:flutter/material.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/session_manager.dart';
import '../../../data/local/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _biometricService = BiometricService();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String _biometricType = 'Biometrik';

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final canCheck = await _biometricService.canCheckBiometrics();
    final isSupported = await _biometricService.isDeviceSupported();
    final typeName = await _biometricService.getBiometricTypeName();
    
    // Ganti angka 1 dengan ID User yang lagi aktif dari SessionManager lu
    const userId = 1; 
    final isEnabled = await DatabaseHelper().isBiometricEnabled(userId);
    
    if (mounted) {
      setState(() {
        _isBiometricAvailable = canCheck && isSupported;
        _isBiometricEnabled = isEnabled;
        _biometricType = typeName;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    const userId = 1; // Sesuaikan dengan User ID aktif

    if (value) {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Verifikasi untuk mengaktifkan $_biometricType',
      );

      if (authenticated) {
        await DatabaseHelper().setBiometricEnabled(userId, true);
        if (mounted) {
          setState(() => _isBiometricEnabled = true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$_biometricType diaktifkan'), backgroundColor: Colors.green));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Autentikasi gagal'), backgroundColor: Colors.red));
        }
      }
    } else {
      await DatabaseHelper().setBiometricEnabled(userId, false);
      if (mounted) {
        setState(() => _isBiometricEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$_biometricType dinonaktifkan'), backgroundColor: Colors.orange));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.teal, child: Icon(Icons.person, size: 50, color: Colors.white)),
          const SizedBox(height: 20),
          const Text('Yusuf Nur Ramadhan', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          
          // --- TOGGLE BIOMETRIK ---
          if (_isBiometricAvailable) ...[
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: ListTile(
                leading: Icon(_biometricType == 'Face ID' ? Icons.face : Icons.fingerprint, color: Colors.teal),
                title: Text('Login dengan $_biometricType', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_isBiometricEnabled ? 'Aktif' : 'Nonaktif', style: TextStyle(color: _isBiometricEnabled ? Colors.green : Colors.grey)),
                trailing: Switch(
                  value: _isBiometricEnabled,
                  onChanged: _toggleBiometric,
                  activeColor: Colors.teal,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          ElevatedButton(
            onPressed: () {}, // Fungsi Logout
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: const Text('Keluar Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}