import 'package:flutter/material.dart';

class MedicationHistoryScreen extends StatelessWidget {
  const MedicationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Riwayat Konsumsi Obat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // --- RINGKASAN DATA ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Obat', '12', Colors.teal),
                _buildStatItem('Kepatuhan', '85%', Colors.blue),
                _buildStatItem('Status', 'Sehat', Colors.orange),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Log Konsumsi Terakhir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // --- LIST TIMELINE RIWAYAT ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildHistoryCard(
                  date: 'Hari ini, 18 April',
                  medicine: 'Paracetamol 500mg',
                  dose: '1 Pil',
                  frequency: '3x Sehari',
                  status: 'Diminum (Tepat Waktu)',
                  note: 'Demam sudah mulai turun, tidak ada pusing.',
                  isEffective: true,
                ),
                _buildHistoryCard(
                  date: 'Kemarin, 17 April',
                  medicine: 'Amoxicillin',
                  dose: '1 Pil',
                  frequency: '2x Sehari',
                  status: 'Diminum (Telat 1 Jam)',
                  note: 'Perut agak kembung setelah minum.',
                  isEffective: false,
                ),
                _buildHistoryCard(
                  date: '16 April 2026',
                  medicine: 'Vitamin C 1000mg',
                  dose: '1 Tablet',
                  frequency: '1x Sehari',
                  status: 'Diminum',
                  note: 'Badan terasa lebih segar.',
                  isEffective: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String medicine,
    required String dose,
    required String frequency,
    required String status,
    required String note,
    required bool isEffective,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.teal)),
              Icon(
                isEffective ? Icons.trending_up : Icons.trending_flat,
                color: isEffective ? Colors.green : Colors.orange,
                size: 18,
              ),
            ],
          ),
          const Divider(height: 20),
          Text(medicine, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBadge(Icons.medication, '$dose / $frequency'),
              const SizedBox(width: 8),
              _buildBadge(Icons.check_circle, status),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Catatan & Efek:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text(note, style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.teal),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}