import 'package:flutter/material.dart';

class ConversionScreen extends StatefulWidget {
  final int initialIndex;
  const ConversionScreen({super.key, this.initialIndex = 0});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  final TextEditingController _amountController = TextEditingController();
  
  // --- State Konversi Mata Uang (Min 3: IDR, USD, EUR, GBP) ---
  String _selectedCurrencyFrom = 'IDR';
  String _selectedCurrencyTo = 'USD';
  final List<String> _currencies = ['IDR', 'USD', 'EUR', 'GBP'];

  // --- State Konversi Waktu (Sesuai Syarat Mutlak PPT) ---
  String _selectedTimeFrom = 'WIB';
  String _selectedTimeTo = 'WITA'; 
  final List<String> _timezones = ['WIB', 'WIT', 'WITA', 'London'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kalkulator & Konversi'),
          bottom: const TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(icon: Icon(Icons.monetization_on), text: 'Mata Uang'),
              Tab(icon: Icon(Icons.access_time), text: 'Waktu Dunia'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCurrencyTab(),
            _buildTimeTab(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: KONVERSI MATA UANG (MIN 3 CURRENCIES)
  // ==========================================
  Widget _buildCurrencyTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(Icons.currency_exchange, size: 60, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Perbandingan Harga Obat Internasional', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Masukkan Nominal Harga',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calculate),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDropdown(
                value: _selectedCurrencyFrom, 
                items: _currencies,
                onChanged: (val) => setState(() => _selectedCurrencyFrom = val!),
              ),
              const Icon(Icons.arrow_forward, color: Colors.teal),
              _buildDropdown(
                value: _selectedCurrencyTo, 
                items: _currencies,
                onChanged: (val) => setState(() => _selectedCurrencyTo = val!),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logic hitung API kurs (Tugas Irham)')),
                );
              },
              child: const Text('Hitung Konversi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
          // Mockup Hasil dengan backslash dolar (\$) agar tidak error
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Estimasi: 0.00 \(\$\)', 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: KONVERSI WAKTU (WIB, WIT, WITA, London)
  // ==========================================
  Widget _buildTimeTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(Icons.public, size: 60, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Sinkronisasi Jadwal Minum Obat Global', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDropdown(
                value: _selectedTimeFrom, 
                items: _timezones,
                onChanged: (val) => setState(() => _selectedTimeFrom = val!),
              ),
              const Icon(Icons.arrow_forward, color: Colors.blue),
              _buildDropdown(
                value: _selectedTimeTo, 
                items: _timezones,
                onChanged: (val) => setState(() => _selectedTimeTo = val!),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logic selisih jam antar zona (Tugas Irham)')),
                );
              },
              child: const Text('Cek Selisih Waktu', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk dropdown
  Widget _buildDropdown({
    required String value, 
    required List<String> items, 
    required void Function(String?) onChanged
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}