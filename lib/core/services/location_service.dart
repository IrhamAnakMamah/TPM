/// Service lokasi untuk fitur LBS (Location-Based Services).
///
/// Menyediakan data lokasi statik untuk mockup peta apotek.
/// Untuk integrasi nyata, gunakan package `geolocator` dan `google_maps_flutter`.
class LocationService {
  /// Daftar apotek terdekat (data mockup).
  /// Pada implementasi nyata, data ini diambil dari Google Maps API.
  static List<Map<String, dynamic>> getNearbyPharmacies() {
    return [
      {
        'name': 'Apotek Sehat Selalu',
        'distance': '500m',
        'address': 'Jl. Babarsari No. 44, Sleman',
        'openUntil': '22:00 WIB',
        'lat': -7.7797,
        'lng': 110.4145,
        'isOpen': true,
      },
      {
        'name': 'Apotek Kimia Farma',
        'distance': '1.2km',
        'address': 'Jl. Colombo No. 12, Yogyakarta',
        'openUntil': '21:00 WIB',
        'lat': -7.7713,
        'lng': 110.3876,
        'isOpen': true,
      },
      {
        'name': 'Apotek K-24',
        'distance': '2.0km',
        'address': 'Jl. Kaliurang Km 6, Sleman',
        'openUntil': '24 Jam',
        'lat': -7.7565,
        'lng': 110.3852,
        'isOpen': true,
      },
      {
        'name': 'Apotek Viva Generik',
        'distance': '3.5km',
        'address': 'Jl. Affandi No. 9, Yogyakarta',
        'openUntil': '20:00 WIB',
        'lat': -7.7732,
        'lng': 110.3905,
        'isOpen': false,
      },
    ];
  }

  /// Simulasi posisi user saat ini (UPN Veteran Yogyakarta).
  static Map<String, double> getCurrentLocation() {
    return {
      'lat': -7.7733,
      'lng': 110.4087,
    };
  }
}
