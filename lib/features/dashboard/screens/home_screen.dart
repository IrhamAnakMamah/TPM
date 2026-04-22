import 'package:flutter/material.dart';
import '../../../core/services/session_manager.dart';
import '../../pharmacy_map/screens/map_screen.dart';
import '../../scanner_ai/screens/camera_view_screen.dart'; // IMPORT SCANNER DI SINI

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionManager();
    final displayName = session.userName;
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, $displayName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    Text(session.userEmail.isNotEmpty ? session.userEmail : 'Informatika UPN "Veteran" Yogyakarta', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.teal.shade100, width: 2)),
                child: CircleAvatar(radius: 25, backgroundColor: Colors.teal, child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ],
          ),
          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF0D9488).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kepatuhan Obat', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    SizedBox(height: 4),
                    Text('Sudah Minum 2/4', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircularProgressIndicator(value: 0.5, backgroundColor: Colors.white24, color: Colors.white, strokeWidth: 6),
                    const Icon(Icons.check, color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          const Text('Layanan Utama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildQuickAction(
                context: context, icon: Icons.map_rounded, label: 'Cari Apotek', color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen())),
              ),
              const SizedBox(width: 15),
              // --- TOMBOL SCAN OBAT SEKARANG BUKA KAMERA ---
              _buildQuickAction(
                context: context, icon: Icons.qr_code_scanner, label: 'Scan Obat', color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CameraViewScreen())),
              ),
            ],
          ),
          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jadwal Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('Lihat Semua')),
            ],
          ),
          const SizedBox(height: 10),
          _buildProMedCard('Paracetamol 500mg', '08:00 WIB', 'Sesudah Makan', true),
          _buildProMedCard('Amoxicillin', '13:00 WIB', 'Sebelum Makan', false),
        ],
      ),
    );
  }

  Widget _buildQuickAction({required BuildContext context, required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color)),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProMedCard(String name, String time, String note, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: isDone ? Colors.teal.shade100 : Colors.transparent), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isDone ? Colors.teal.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(12)), child: Icon(isDone ? Icons.check_circle : Icons.pending_actions, color: isDone ? Colors.teal : Colors.orange)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text('$time • $note', style: TextStyle(color: Colors.grey.shade600, fontSize: 12))])),
          if (!isDone) const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}