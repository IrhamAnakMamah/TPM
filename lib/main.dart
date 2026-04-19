import 'package:flutter/material.dart';
// Import tema kustom agar UI terlihat premium
import 'core/constants/app_theme.dart';
// Import semua screen utama
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/main_screen.dart';

void main() {
  // Memastikan binding Flutter terinisialisasi sebelum menjalankan app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TugasAkhirApp());
}

class TugasAkhirApp extends StatelessWidget {
  const TugasAkhirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedRemind Pro',
      
      // MENGGUNAKAN TEMA PREMIUM
      // Pastikan file app_theme.dart sudah kamu buat dengan class AppTheme
      theme: AppTheme.lightTheme,
      
      // SISTEM NAVIGASI (ROUTES)
      // initialRoute '/' akan membuka LoginScreen pertama kali
      initialRoute: '/',
      routes: {
        // Halaman Login
        '/': (context) => const LoginScreen(),
        
        // Halaman Dashboard Utama (Gunakan MainScreen tanpa const karena ada Timer)
        '/home': (context) => MainScreen(),
      },
      
      // Fallback jika terjadi kesalahan navigasi
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }
}