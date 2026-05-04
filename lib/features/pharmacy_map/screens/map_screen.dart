import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  // Map controller
  final MapController _mapController = MapController();
  
  // User location
  Position? _currentPosition;
  bool _isLoading = true;
  String _searchQuery = '';

  // Default location (UPN Yogyakarta)
  static const LatLng _defaultLocation = LatLng(-7.761005, 110.409156);

  // Data Apotek (Area Yogyakarta - Real Coordinates)
  final List<Pharmacy> _allPharmacies = [
    Pharmacy(
      id: '1',
      name: 'Apotek K-24 Seturan',
      lat: -7.7547,
      lng: 110.4089,
      address: 'Jl. Seturan Raya, Caturtunggal, Depok, Sleman',
      phone: '0274-485024',
      openHours: '24 Jam',
    ),
    Pharmacy(
      id: '2',
      name: 'Apotek Kimia Farma Condongcatur',
      lat: -7.7589,
      lng: 110.4103,
      address: 'Jl. Ring Road Utara, Condongcatur, Depok, Sleman',
      phone: '0274-882829',
      openHours: '08:00 - 22:00',
    ),
    Pharmacy(
      id: '3',
      name: 'Apotek Sehat Farma',
      lat: -7.7634,
      lng: 110.4067,
      address: 'Jl. Kaliurang KM 5, Caturtunggal, Depok, Sleman',
      phone: '0274-561234',
      openHours: '07:00 - 21:00',
    ),
    Pharmacy(
      id: '4',
      name: 'Apotek Medika Utama',
      lat: -7.7682,
      lng: 110.4125,
      address: 'Jl. Palagan Tentara Pelajar, Sleman',
      phone: '0274-867890',
      openHours: '08:00 - 20:00',
    ),
    Pharmacy(
      id: '5',
      name: 'Apotek Sleman Farma',
      lat: -7.7512,
      lng: 110.4156,
      address: 'Jl. Affandi, Caturtunggal, Depok, Sleman',
      phone: '0274-512345',
      openHours: '08:00 - 21:00',
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
    _mapController.dispose();
    super.dispose();
  }

  // Get Current Location
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
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          14.5,
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

  // Calculate Distance
  double _calculateDistance(double lat, double lng) {
    if (_currentPosition == null) {
      // Use default location (UPN Yogyakarta)
      return Geolocator.distanceBetween(
        _defaultLocation.latitude,
        _defaultLocation.longitude,
        lat,
        lng,
      ) / 1000; // Convert to km
    }

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    ) / 1000; // Convert to km
  }

  // Update Pharmacy Distances & Sort
  void _updatePharmacyDistances() {
    for (var pharmacy in _allPharmacies) {
      pharmacy.distance = _calculateDistance(pharmacy.lat, pharmacy.lng);
    }

    // Sort by distance (nearest first)
    _allPharmacies.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));

    // Filter by search query
    _filterPharmacies();
  }

  // Filter Pharmacies by Search
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

  // Go to My Location
  Future<void> _goToMyLocation() async {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    } else {
      await _initializeLocation();
    }
  }

  // Open in Google Maps
  Future<void> _openInGoogleMaps(Pharmacy pharmacy) async {
    // Try multiple URL schemes for better compatibility
    final urls = [
      // 1. Google Maps app (geo: scheme)
      Uri.parse('geo:0,0?q=${pharmacy.lat},${pharmacy.lng}(${Uri.encodeComponent(pharmacy.name)})'),
      
      // 2. Google Maps web (fallback)
      Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=${pharmacy.lat},${pharmacy.lng}'
        '&travelmode=driving',
      ),
    ];

    bool launched = false;
    String? errorMessage;

    for (var url in urls) {
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        errorMessage = e.toString();
        print('Error launching $url: $e');
        continue;
      }
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage != null 
              ? 'Error: $errorMessage'
              : 'Tidak dapat membuka Google Maps. Pastikan Google Maps terinstall.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. FLUTTER MAP (OpenStreetMap)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : _defaultLocation,
              initialZoom: 14.5,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              // Tile Layer (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tugas_akhir_tpm',
                maxZoom: 19,
              ),
              
              // Marker Layer (Pharmacies)
              MarkerLayer(
                markers: [
                  // User location marker (blue)
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 3),
                        ),
                        child: const Icon(Icons.person, color: Colors.blue, size: 20),
                      ),
                    ),
                  
                  // Pharmacy markers
                  ..._pharmacies.map((pharmacy) {
                    return Marker(
                      point: LatLng(pharmacy.lat, pharmacy.lng),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          // Zoom to pharmacy
                          _mapController.move(
                            LatLng(pharmacy.lat, pharmacy.lng),
                            16.0,
                          );
                          
                          // Show info
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${pharmacy.name}\n${pharmacy.distance?.toStringAsFixed(1)} km • ${pharmacy.isOpen ? "Buka" : "Tutup"}',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: pharmacy.isOpen ? Colors.green : Colors.red,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.local_pharmacy,
                          color: pharmacy.isOpen ? Colors.green : Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
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
            bottom: 20,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 130,
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
                            _mapController.move(
                              LatLng(pharmacy.lat, pharmacy.lng),
                              16.0,
                            );
                          },
                          child: Container(
                            width: 300,
                            margin: const EdgeInsets.only(right: 15),
                            padding: const EdgeInsets.all(12),
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
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.local_pharmacy, color: Colors.teal, size: 26),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pharmacy.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            "${pharmacy.distance?.toStringAsFixed(1)} km • ${pharmacy.isOpen ? 'Buka' : 'Tutup'}",
                                            style: TextStyle(
                                              color: pharmacy.isOpen ? Colors.green : Colors.red,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pharmacy.address,
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pharmacy.openHours,
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _openInGoogleMaps(pharmacy),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Navigasi',
                                        style: TextStyle(fontSize: 11, color: Colors.white),
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
