import 'package:flutter/material.dart';

/// Halaman yang menampilkan ringkasan hasil dari scanner AI.
/// 
/// Akan menampilkan nama obat, dosis, dan efek samping yang terdeteksi.
class ResultSummaryScreen extends StatelessWidget {
  final String scanResult;
  final String medicineName;
  final String dosageInfo;
  
  const ResultSummaryScreen({
    super.key,
    required this.scanResult,
    this.medicineName = 'Tidak Diketahui',
    this.dosageInfo = 'Silakan periksa kemasan untuk detail lebih lanjut',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Pemindaian', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, size: 80, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 30),
            
            // Nama Obat
            const Text('Nama Obat Terdeteksi:', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 5),
            Text(medicineName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 20),
            
            // Dosis Info
            const Text('Informasi Dosis:', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 5),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(dosageInfo, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            
            // Raw Result dari AI
            const Text('Analisis AI Lengkap:', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 5),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Text(scanResult, style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
            const SizedBox(height: 40),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Scan Ulang', style: TextStyle(color: Colors.teal)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Todo: Simpan ke database jadwal
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Obat ditambahkan ke jadwal')),
                      );
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Tambahkan', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
