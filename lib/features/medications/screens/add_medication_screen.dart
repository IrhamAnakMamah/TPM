import 'package:flutter/material.dart';
import '../../../data/local/database_helper.dart';
import '../../../data/models/schedule_model.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper();

  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _freqValCtrl = TextEditingController();
  
  String _dosageUnit = 'tablet';
  String _freqType = 'daily';
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Jadwal Baru'),
        backgroundColor: Colors.white, foregroundColor: const Color(0xFF1E293B), elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber),
            tooltip: 'Isi dengan AI (Segera Hadir)',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur AI Parsing menyusul (Tugas Irham)'))),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(25),
          children: [
            _buildSectionTitle('Informasi Obat'),
            _buildTextField(label: 'Nama Obat', controller: _nameCtrl, icon: Icons.medication),
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Stok Awal', controller: _stockCtrl, isNumber: true, icon: Icons.inventory_2)),
                const SizedBox(width: 15),
                Expanded(child: _buildTextField(label: 'Dosis', controller: _doseCtrl, isNumber: true, icon: Icons.science)),
              ],
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _dosageUnit,
              decoration: _inputDeco('Satuan Dosis', Icons.scale),
              items: ['mg', 'ml', 'tablet', 'kapsul'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _dosageUnit = val!),
            ),
            
            const SizedBox(height: 30),
            _buildSectionTitle('Aturan Minum'),
            DropdownButtonFormField<String>(
              value: _freqType,
              decoration: _inputDeco('Tipe Frekuensi', Icons.repeat),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Sekali Sehari (Harian)')),
                DropdownMenuItem(value: 'every_n_hours', child: Text('Tiap N Jam (Berkala)')),
              ],
              onChanged: (val) => setState(() => _freqType = val!),
            ),
            if (_freqType == 'every_n_hours') ...[
              const SizedBox(height: 15),
              _buildTextField(label: 'Setiap berapa jam? (Nilai N)', controller: _freqValCtrl, isNumber: true, icon: Icons.hourglass_bottom),
            ],
            
            const SizedBox(height: 15),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
              leading: const Icon(Icons.access_time, color: Colors.teal),
              title: const Text('Waktu Minum Pertama'),
              trailing: Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _selectedTime);
                if (time != null) setState(() => _selectedTime = time);
              },
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('SIMPAN JADWAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))));
  }

  Widget _buildTextField({required String label, required TextEditingController controller, bool isNumber = false, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
        decoration: _inputDeco(label, icon),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label, prefixIcon: Icon(icon, color: Colors.grey),
      filled: true, fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      final db = await dbHelper.database;
      int medId = await db.insert('medications', {
        'name': _nameCtrl.text,
        'total_stock': double.parse(_stockCtrl.text),
      });

      final schedule = ScheduleModel(
        medId: medId,
        timeIntake: '${_selectedTime.hour.toString().padLeft(2,'0')}:${_selectedTime.minute.toString().padLeft(2,'0')}',
        dosage: double.parse(_doseCtrl.text),
        dosageUnit: _dosageUnit,
        frequencyType: _freqType,
        frequencyValue: _freqType == 'daily' ? 1 : int.parse(_freqValCtrl.text),
      );

      await dbHelper.insertSchedule(schedule);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal Berhasil Disimpan!')));
        Navigator.pop(context);
      }
    }
  }
}