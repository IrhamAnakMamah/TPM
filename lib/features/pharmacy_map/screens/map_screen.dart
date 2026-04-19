import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apotek Terdekat (LBS)')),
      // Menggunakan UI Stack sebagai mockup Peta
      body: Stack(
        children: [
          Container(
            color: Colors.blueGrey[100],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 100, color: Colors.grey),
                  Text('Integrasi Google Maps API\n(Tugas Irham)', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListTile(
                      leading: Icon(Icons.local_pharmacy, color: Colors.red, size: 40),
                      title: Text('Apotek Sehat Selalu', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Jarak: 500m\nBuka hingga 22:00 WIB'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Akan membuka rute navigasi...')),
                        );
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Arahkan ke Lokasi'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}