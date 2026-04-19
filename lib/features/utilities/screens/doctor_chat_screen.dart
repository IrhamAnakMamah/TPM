import 'package:flutter/material.dart';

class DoctorChatScreen extends StatelessWidget {
  const DoctorChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Konsultasi Dokter'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari spesialis atau nama dokter...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- DAFTAR DOKTER ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildDoctorCard(
                  context,
                  'Dr. Andi Pratama',
                  'Spesialis Penyakit Dalam',
                  'Online',
                  'https://ui-avatars.com/api/?name=Andi+Pratama&background=0D9488&color=fff',
                  true,
                ),
                _buildDoctorCard(
                  context,
                  'Dr. Siti Aminah',
                  'Dokter Umum',
                  'Online',
                  'https://ui-avatars.com/api/?name=Siti+Aminah&background=0D9488&color=fff',
                  true,
                ),
                _buildDoctorCard(
                  context,
                  'Dr. Budi Santoso',
                  'Spesialis Anak',
                  'Sibuk',
                  'https://ui-avatars.com/api/?name=Budi+Santoso&background=0D9488&color=fff',
                  false,
                ),
                _buildDoctorCard(
                  context,
                  'Dr. Rina Wijaya',
                  'Spesialis Farmakologi',
                  'Offline',
                  'https://ui-avatars.com/api/?name=Rina+Wijaya&background=0D9488&color=fff',
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, String name, String specialist, String status, String imgUrl, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(imgUrl)),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(specialist, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 5),
                Text(status, style: TextStyle(color: isAvailable ? Colors.green : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Menghubungkan ke $name...'))
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAvailable ? const Color(0xFF0D9488) : Colors.grey.shade300,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Chat', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}