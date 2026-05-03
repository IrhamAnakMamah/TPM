import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Titik koordinat awal (Contoh: Area sekitar UPN Yogyakarta)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-7.761005, 110.409156),
    zoom: 14.5,
  );

  GoogleMapController? _mapController;

  // Data Dummy Apotek buat UI
  final List<Map<String, dynamic>> _pharmacies = [
    {'name': 'Apotek K-24 Seturan', 'dist': '0.5 km', 'open': true, 'lat': -7.763, 'lng': 110.408},
    {'name': 'Apotek Kimia Farma', 'dist': '1.2 km', 'open': true, 'lat': -7.759, 'lng': 110.412},
    {'name': 'Apotek UPN', 'dist': '1.5 km', 'open': false, 'lat': -7.765, 'lng': 110.415},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Peta dibuat full screen menabrak status bar
      body: Stack(
        children: [
          // 1. WIDGET GOOGLE MAPS
          GoogleMap(
            initialCameraPosition: _initialPosition,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            markers: _pharmacies.map((apotek) {
              return Marker(
                markerId: MarkerId(apotek['name']),
                position: LatLng(apotek['lat'], apotek['lng']),
                infoWindow: InfoWindow(title: apotek['name']),
              );
            }).toSet(),
          ),

          // 2. FLOATING SEARCH BAR (ATAS)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari Apotek Terdekat...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(Icons.search, color: Colors.teal),
                ],
              ),
            ),
          ),

          // 3. HORIZONTAL CARD SLIDER (BAWAH)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: _pharmacies.length,
                itemBuilder: (context, index) {
                  final apotek = _pharmacies[index];
                  return GestureDetector(
                    onTap: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(LatLng(apotek['lat'], apotek['lng'])),
                      );
                    },
                    child: Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.local_pharmacy, color: Colors.teal, size: 30),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(apotek['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 5),
                                Text("${apotek['dist']} • ${apotek['open'] ? 'Buka' : 'Tutup'}", 
                                  style: TextStyle(color: apotek['open'] ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}