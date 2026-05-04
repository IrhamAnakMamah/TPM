import 'package:flutter/material.dart';
import '../../../data/local/database_helper.dart';
import '../../../core/services/session_manager.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _stockController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _dosageUnit = 'mg';
  String _frequencyType = 'daily';
  final _freqValueController = TextEditingController(text: '1');
  TimeOfDay _selectedTime = TimeOfDay.now();

  final _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = SessionManager().currentUser?['id'] ?? 1;
      
      // 1. Simpan Data Obat
      final medId = await _dbHelper.insertMedication(
        userId: userId,
        name: _nameController.text.trim(),
        totalStock: double.parse(_stockController.text.trim()),
      );

      // 2. Format Waktu
      final timeString = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      // 3. Simpan Jadwal (Menggunakan named parameters sesuai update terakhir)
      await _dbHelper.insertSchedule(
        medId: medId,
        timeIntake: timeString,
        dosage: double.parse(_dosageController.text.trim()),
        dosageUnit: _dosageUnit,
        frequencyType: _frequencyType,
        frequencyValue: _frequencyType == 'every_n_hours' 
            ? int.parse(_freqValueController.text.trim()) 
            : 1,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Obat berhasil ditambahkan!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Kembali dan bawa flag true
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Obat', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Field Nama Obat
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Obat',
                        prefixIcon: const Icon(Icons.medication),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),

                    // Baris Dosis & Satuan
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _dosageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Dosis',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _dosageUnit,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            items: ['mg', 'ml', 'tablet', 'kapsul', 'tetes']
                                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                .toList(),
                            onChanged: (value) => setState(() => _dosageUnit = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Frekuensi
                    DropdownButtonFormField<String>(
                      value: _frequencyType,
                      decoration: InputDecoration(
                        labelText: 'Frekuensi Minum',
                        prefixIcon: const Icon(Icons.repeat),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Sekali Sehari')),
                        DropdownMenuItem(value: 'every_n_hours', child: Text('Setiap N Jam')),
                      ],
                      onChanged: (value) => setState(() => _frequencyType = value!),
                    ),
                    const SizedBox(height: 20),

                    // Input N Jam (Hanya muncul jika pilih every_n_hours)
                    if (_frequencyType == 'every_n_hours') ...[
                      TextFormField(
                        controller: _freqValueController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Setiap Berapa Jam?',
                          prefixIcon: const Icon(Icons.timer),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Waktu Mulai
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      leading: const Icon(Icons.access_time, color: Colors.teal),
                      title: const Text('Waktu Minum Pertama'),
                      trailing: Text(
                        _selectedTime.format(context),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onTap: () => _selectTime(context),
                    ),
                    const SizedBox(height: 20),

                    // Stok
                    TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stok Awal Obat',
                        prefixIcon: const Icon(Icons.inventory),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),

                    // Catatan
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        alignLabelWithHint: true,
                        hintText: 'Misal: Sesudah makan...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Simpan
                    ElevatedButton(
                      onPressed: _saveMedication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Simpan Jadwal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}