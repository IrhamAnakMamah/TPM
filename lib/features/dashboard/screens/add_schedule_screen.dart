import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class AddScheduleScreen extends StatefulWidget {
  final bool useAi;
  const AddScheduleScreen({super.key, required this.useAi});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _aiController = TextEditingController();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _stockController = TextEditingController();
  final _timeController = TextEditingController();

  String _dosageUnit = 'mg';
  String _frequencyType = 'daily';
  final _freqValueController = TextEditingController(text: '1');

  bool _isLoadingAI = false;

  Future<void> _parseWithAI() async {
    final text = _aiController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cerita tidak boleh kosong ya.')),
      );
      return;
    }

    setState(() => _isLoadingAI = true);
    
    // Memanggil API backend Python
    final result = await ApiService().parseSchedule(text);
    
    setState(() => _isLoadingAI = false);

    if (result['status'] == 'ok') {
      final data = result['data'];
      setState(() {
        _nameController.text = data['name'] ?? '';
        _dosageController.text = data['dosage']?.toString() ?? '';
        
        final unit = data['dosage_unit']?.toString().toLowerCase() ?? 'mg';
        if (['mg', 'ml', 'tablet', 'kapsul'].contains(unit)) {
          _dosageUnit = unit;
        }

        _frequencyType = data['frequency_type'] ?? 'daily';
        _freqValueController.text = data['frequency_value']?.toString() ?? '1';
        _stockController.text = data['total_stock']?.toString() ?? '0';
        _timeController.text = data['time_intake'] ?? '08:00';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✨ Asisten berhasil mengisi formulir! Silakan periksa kembali di bawah.'),
          backgroundColor: Colors.teal.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Maaf, gagal memproses kata-kata.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _saveSchedule() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama obat belum diisi!'), backgroundColor: Colors.red),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jadwal Berhasil Disimpan (Masih Simulasi)'), backgroundColor: Colors.green),
    );
    // Kembali dua kali ke layar Home
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 20.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.useAi ? 'Tulis Jadwal Pintar' : 'Isi Jadwal Manual',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.useAi) ...[
              // Logo/Icon di tengah atas mirip Kalkulator
              const Center(
                child: Icon(Icons.auto_awesome, size: 64, color: Colors.teal),
              ),
              const SizedBox(height: 15),
              const Center(
                child: Text('Ceritakan Aturan Minum Obatnya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _aiController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: "Contoh:\nMinum obat Paracetamol 500 mg 3 kali sehari, sisa obat ada 10 butir.",
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade400)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.teal, width: 2)),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoadingAI ? null : _parseWithAI,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: _isLoadingAI 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('BANTU ISIKAN FORMULIR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(thickness: 1, color: Colors.black12),
              const SizedBox(height: 10),
              const Text('Hasil Pengisian (Bisa diubah jika salah):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
            ],

            if (!widget.useAi) ...[
               const Center(
                child: Icon(Icons.edit_note, size: 64, color: Colors.teal),
              ),
              const SizedBox(height: 15),
              const Center(
                child: Text('Isi Detail Obat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
              ),
              const SizedBox(height: 15),
            ],

            // ── BAGIAN FORMULIR ──
            _buildLabel('Nama Obat'),
            TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal, width: 2)),
                prefixIcon: const Icon(Icons.medication),
              ),
            ),

            _buildLabel('Dosis & Satuan'),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _dosageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal, width: 2)),
                      hintText: 'Contoh: 500',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _dosageUnit,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: ['mg', 'ml', 'tablet', 'kapsul'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _dosageUnit = val!),
                  ),
                ),
              ],
            ),

            _buildLabel('Aturan Minum'),
            DropdownButtonFormField<String>(
              value: _frequencyType,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal, width: 2)),
              ),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Sehari Sekali')),
                DropdownMenuItem(value: 'every_n_hours', child: Text('Lebih dari Sekali (Atur Jam)')),
              ],
              onChanged: (val) => setState(() => _frequencyType = val!),
            ),

            if (_frequencyType == 'every_n_hours') ...[
              _buildLabel('Jarak Minum (Setiap Berapa Jam?)'),
              TextField(
                controller: _freqValueController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal, width: 2)),
                  hintText: 'Contoh: 8 (untuk 3x sehari)',
                ),
              ),
            ],

            _buildLabel('Jam Pertama Minum Hari Ini'),
            TextField(
              controller: _timeController,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Contoh: 08:00',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal, width: 2)),
                prefixIcon: const Icon(Icons.access_time),
              ),
            ),

            _buildLabel('Total Stok Obat Tersisa'),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal, width: 2)),
                prefixIcon: const Icon(Icons.inventory_2),
              ),
            ),
            
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                onPressed: _saveSchedule,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('SIMPAN JADWAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
