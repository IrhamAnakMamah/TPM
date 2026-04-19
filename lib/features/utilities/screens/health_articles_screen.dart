import 'package:flutter/material.dart';

class HealthArticlesScreen extends StatelessWidget {
  const HealthArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Tips & Artikel Kesehatan'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFeaturedArticle(
            context,
            'https://images.unsplash.com/photo-1505751172107-5739a007351e?q=80&w=500&auto=format&fit=crop',
            '5 Tips Menjaga Imunitas di Musim Pancaroba',
            'Kesehatan Umum',
          ),
          const SizedBox(height: 25),
          const Text(
            'Artikel Terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildArticleTile(
            'Pentingnya Minum Air Putih 8 Gelas Sehari',
            'Nutrisi',
            '2 jam yang lalu',
            Icons.water_drop,
            Colors.blue,
          ),
          _buildArticleTile(
            'Bahaya Konsumsi Gula Berlebih bagi Jantung',
            'Jantung',
            '5 jam yang lalu',
            Icons.favorite,
            Colors.red,
          ),
          _buildArticleTile(
            'Cara Mengatasi Insomnia tanpa Obat',
            'Gaya Hidup',
            'Kemarin',
            Icons.bedtime,
            Colors.purple,
          ),
          _buildArticleTile(
            'Mengenal Jenis-jenis Antibiotik Umum',
            'Farmasi',
            '2 hari lalu',
            Icons.medication,
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedArticle(BuildContext context, String imgUrl, String title, String category) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8)),
              child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleTile(String title, String category, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ],
      ),
    );
  }
}