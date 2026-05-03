/// Utilitas konversi mata uang.
///
/// Menggunakan kurs statis (offline) untuk demo.
/// Untuk produksi, integrasikan dengan API kurs real-time.
class CurrencyConverter {
  // Kurs terhadap IDR (base: 1 unit mata uang asing = X IDR)
  static const Map<String, double> _ratesInIDR = {
    'IDR': 1.0,
    'USD': 16250.0,
    'EUR': 17800.0,
    'GBP': 20500.0,
  };

  /// Konversi dari [fromCurrency] ke [toCurrency].
  /// Mengembalikan nilai hasil konversi.
  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;

    final fromRate = _ratesInIDR[fromCurrency] ?? 1.0;
    final toRate = _ratesInIDR[toCurrency] ?? 1.0;

    // Konversi ke IDR dulu, lalu ke mata uang tujuan
    final amountInIDR = amount * fromRate;
    return amountInIDR / toRate;
  }

  /// Format angka ke string dengan 2 desimal + simbol mata uang.
  static String formatResult(double value, String currency) {
    final symbols = {
      'IDR': 'Rp',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
    };
    final symbol = symbols[currency] ?? currency;

    if (currency == 'IDR') {
      return '$symbol ${value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          )}';
    }
    return '$symbol ${value.toStringAsFixed(2)}';
  }

  /// Daftar mata uang yang tersedia.
  static List<String> get availableCurrencies => _ratesInIDR.keys.toList();
}
