import 'package:flutter/material.dart';

class CameraViewScreen extends StatelessWidget {
  const CameraViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam ala kamera
      body: Stack(
        children: [
          // --- MOCKUP KAMERA (TUGAS IRHAM) ---
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
                'Tampilan Kamera (Tugas Irham)',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),

          // --- TOMBOL BACK (PENYELAMAT NYAWA) ---
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
                    onPressed: () => Navigator.pop(context), // Ini fungsi buat baliknya
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sedang memproses gambar obat...'))
                  );
                },
                icon: const Icon(Icons.document_scanner, color: Colors.teal),
                label: const Text(
                  'Scan Obat Sekarang', 
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)
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