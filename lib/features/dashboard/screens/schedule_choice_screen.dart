import 'package:flutter/material.dart';
import 'add_schedule_screen.dart';

class ScheduleChoiceScreen extends StatelessWidget {
  const ScheduleChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Jadwal Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B), // Warna teks gelap seperti Kalkulator
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pilih Cara Mengisi Jadwal Obat',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // TOMBOL AI
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScheduleScreen(useAi: true)));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(24),
                backgroundColor: Colors.teal.shade50,
                foregroundColor: Colors.teal.shade900,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.teal.shade300, width: 2),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.auto_awesome, size: 48, color: Colors.teal),
                  SizedBox(height: 16),
                  Text('Tulis Cerita Bebas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  Text('Cukup ketik secara bebas (Contoh: "Minum obat batuk 3 kali sehari"), asisten pintar akan mengisikannya otomatis.', style: TextStyle(fontSize: 15, color: Colors.black54), textAlign: TextAlign.center),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // TOMBOL MANUAL
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScheduleScreen(useAi: false)));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(24),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.edit_note, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Isi Formulir Sendiri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  Text('Isi nama obat, dosis, dan waktu secara satu per satu dengan mengetik manual.', style: TextStyle(fontSize: 15, color: Colors.black54), textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
