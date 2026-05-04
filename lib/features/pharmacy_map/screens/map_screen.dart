import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class Pharmacy {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String address;
  final String phone;
  final String openHours;
  double? distance; // in km

  Pharmacy({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required this.phone,
    required this.openHours,
    this.distance,
  });

  bool get isOpen {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Parse jam buka (format: "HH:MM - HH:MM" atau "24 Jam")
    if (openHours == "24 Jam") return true;
    
    try {
      final parts = openHours.split(' - ');
      if (parts.length != 2) return false;
      
      final openTime = int.parse(parts[0].split(':')[0]);
      final closeTime = int.parse(parts[1].split(':')[0]);
      
      return hour >= openTime && hour < closeTime;
    } catch (e) {
      return false;
    }
  }
}

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
  Position? _currentPosition;
  bool _isLoading = true;
  String _searchQuery = '';

  // Data Apotek (Area Yogyakarta)
  final List<Pharmacy> _allPharmacies = [
    Pharmacy(
      id: '1',
      name: 'Apotek K-24 Seturan',
      lat: -7.763,
      lng: 110.408,
      address: 'Jl. Seturan Raya No. 1',
      phone: '0274-123456',
      openHours: '24 Jam',
    ),
    Pharmacy(
      id: '2',
      name: 'Apotek Kimia Farma Condongcatur',
      lat: -7.759,
      lng: 110.412,
      address: 'Jl. Ring Road Utara',
      phone: '0274-234567',
      openHours: '08:00 - 22:00',
    ),
    Pharmacy(
      id: '3',
      name: 'Apotek UPN Veteran',
      lat: -7.765,
      lng: 110.415,
      address: 'Kampus UPN Veteran Yogyakarta',
      phone: '0274-345678',
      openHours: '08:00 - 16:00',
    ),
    Pharmacy(
      id: '4',
      name: 'Apotek Sehat Farma',
      lat: -7.760,
      lng: 110.405,
      address: 'Jl. Kaliurang KM 5',
      phone: '0274-456789',
      openHours: '07:00 - 21:00',
    ),
    Pharmacy(
      id: '5',
      name: 'Apotek Medika Utama',
      lat: -7.768,
      lng: 110.410,
      address: 'Jl. Palagan Tentara Pelajar',
      phone: '0274-567890',
      openHours: '08:00 - 20:00',
    ),
  ];

  List<Pharmacy> _pharmacies = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // FASE 2.1: Get Current Location
  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);

    try {
      // Request location permission
      final permission = await Permission.location.request();
      
      if (permission.isGranted) {
        // Get current position
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _currentPosition = position;
        });

        // Calculate distances and sort
        _updatePharmacyDistances();

        // Move camera to user location
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      } else {
        // Permission denied, use default location
        _updatePharmacyDistances();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin lokasi ditolak. Menggunakan lokasi default.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error getting location: $e');
      _updatePharmacyDistances();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // FASE 2.2: Calculate Distance
  double _calculateDistance(double lat, double lng) {
    if (_currentPosition == null) {
      // Use default location (UPN Yogyakarta)
      return Geolocator.distanceBetween(
        -7.761005, 110.409156,
        lat, lng,
      ) / 1000; // Convert to km
    }

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    ) / 1000; // Convert to km
  }

  // FASE 2.3: Update Pharmacy Distances & Sort
  void _updatePharmacyDistances() {
    for (var pharmacy in _allPharmacies) {
      pharmacy.distance = _calculateDistance(pharmacy.lat, pharmacy.lng);
    }

    // Sort by distance (nearest first)
    _allPharmacies.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));

    // Filter by search query
    _filterPharmacies();
  }

  // FASE 2.4: Filter Pharmacies by Search
  void _filterPharmacies() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _pharmacies = List.from(_allPharmacies);
      } else {
        _pharmacies = _allPharmacies
            .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  // FASE 2.5: Go to My Location
  Future<void> _goToMyLocation() async {
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    } else {
      await _initializeLocation();
    }
  }

  // FASE 2.6: Open in Google Maps
  Future<void> _openInGoogleMaps(Pharmacy pharmacy) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${pharmacy.lat},${pharmacy.lng}'
      '&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka Google Maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error launching Google Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
            onMapCreated: (controller) {
              _mapController = controller;
              // Move to user location if available
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  ),
                );
              }
            },
            markers: _pharmacies.map((pharmacy) {
              return Marker(
                markerId: MarkerId(pharmacy.id),
                position: LatLng(pharmacy.lat, pharmacy.lng),
                infoWindow: InfoWindow(
                  title: pharmacy.name,
                  snippet: '${pharmacy.distance?.toStringAsFixed(1)} km • ${pharmacy.isOpen ? "Buka" : "Tutup"}',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  pharmacy.isOpen ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
                ),
              );
            }).toSet(),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              ),
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
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Cari Apotek Terdekat...",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        _filterPharmacies();
                      },
                    ),
                  ),
                  const Icon(Icons.search, color: Colors.teal),
                ],
              ),
            ),
          ),

          // 3. MY LOCATION BUTTON (KANAN ATAS)
          Positioned(
            top: 120,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location, color: Colors.teal),
            ),
          ),

          // 4. HORIZONTAL CARD SLIDER (BAWAH)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 140,
              child: _pharmacies.isEmpty
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: const Text(
                          'Tidak ada apotek ditemukan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: _pharmacies.length,
                      itemBuilder: (context, index) {
                        final pharmacy = _pharmacies[index];
                        return GestureDetector(
                          onTap: () {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(pharmacy.lat, pharmacy.lng),
                                16.0,
                              ),
                            );
                          },
                          child: Container(
                            width: 300,
                            margin: const EdgeInsets.only(right: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.local_pharmacy, color: Colors.teal, size: 28),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pharmacy.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${pharmacy.distance?.toStringAsFixed(1)} km • ${pharmacy.isOpen ? 'Buka' : 'Tutup'}",
                                            style: TextStyle(
                                              color: pharmacy.isOpen ? Colors.green : Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  pharmacy.address,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pharmacy.openHours,
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _openInGoogleMaps(pharmacy),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Navigasi',
                                        style: TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
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