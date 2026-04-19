import 'package:flutter/material.dart';
import 'conversion_screen.dart';
import 'mini_game_screen.dart';
import 'history_screen.dart';
import 'doctor_chat_screen.dart';
import 'health_articles_screen.dart';

class ToolsMenuScreen extends StatelessWidget {
  const ToolsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildModernTool(
            context, 'Konversi\nMata Uang', Icons.currency_exchange, const Color(0xFF0D9488),
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConversionScreen(initialIndex: 0))),
          ),
          _buildModernTool(
            context, 'Konversi\nWaktu', Icons.schedule, const Color(0xFF3B82F6),
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConversionScreen(initialIndex: 1))),
          ),
          _buildModernTool(
            context, 'Mini Game\nMed-Match', Icons.sports_esports, const Color(0xFFEC4899),
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MiniGameScreen())),
          ),
          _buildModernTool(
            context, 'Riwayat\nKonsumsi Obat', Icons.history_edu, const Color(0xFF8B5CF6),
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicationHistoryScreen())),
          ),
          _buildModernTool(
            context, 'Chat\nDokter', Icons.chat_bubble_outline, const Color(0xFF14B8A6),
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorChatScreen())),
          ),
          _buildModernTool(
            context, 'Tips\nKesehatan', Icons.article_outlined, const Color(0xFFF59E0B),
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthArticlesScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTool(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 14),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, height: 1.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}