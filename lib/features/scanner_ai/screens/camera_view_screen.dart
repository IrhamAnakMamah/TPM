import 'package:flutter/material.dart';
import 'result_summary.dart';

class CameraViewScreen extends StatefulWidget {
  const CameraViewScreen({super.key});

  @override
  State<CameraViewScreen> createState() => _CameraViewScreenState();
}

class _CameraViewScreenState extends State<CameraViewScreen> {
  bool _isScanning = false;

  void _simulateScan() {
    setState(() {
      _isScanning = true;
    });
    
    // Simulate API delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
      });
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResultSummaryScreen(
            medicineName: 'Amoxicillin 500mg',
            dosageInfo: 'Diminum 3x sehari setelah makan. Habiskan sesuai resep dokter.',
            scanResult: 'Berdasarkan analisis visual, gambar menunjukkan kemasan atau pil Amoxicillin. Ini adalah antibiotik penicillin yang digunakan untuk mengobati berbagai infeksi bakteri. Pastikan untuk selalu menghabiskan antibiotik sesuai resep meskipun Anda sudah merasa lebih baik.',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam ala kamera
      body: Stack(
        children: [
          // --- MOCKUP KAMERA ---
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.tealAccent, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Tampilan Kamera Mockup\n(Berjalan di Web/Desktop)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),

          // --- TOMBOL BACK ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Transparan estetik
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),

          // --- TOMBOL SCAN OBAT ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _simulateScan,
                icon: _isScanning 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal))
                  : const Icon(Icons.document_scanner, color: Colors.teal),
                label: Text(
                  _isScanning ? 'Menganalisis Gambar...' : 'Scan Obat Sekarang', 
                  style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}