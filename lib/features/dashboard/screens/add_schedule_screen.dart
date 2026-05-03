import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/session_manager.dart';
import '../../../data/local/database_helper.dart';

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
  
  // Instance untuk database dan session
  final _dbHelper = DatabaseHelper();
  final _session = SessionManager();
  bool _isSaving = false;

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

  // ══════════════════════════════════════════════════════════════
  // VALIDASI FORM
  // ══════════════════════════════════════════════════════════════

  String? _validateForm() {
    // Validasi nama obat
    if (_nameController.text.trim().isEmpty) {
      return 'Nama obat belum diisi!';
    }
    
    // Validasi dosis (OPSIONAL - hanya validasi jika diisi)
    if (_dosageController.text.trim().isNotEmpty) {
      final dosage = int.tryParse(_dosageController.text.trim());
      if (dosage == null || dosage <= 0) {
        return 'Dosis harus berupa angka positif!';
      }
    }
    
    // Validasi stok
    if (_stockController.text.trim().isEmpty) {
      return 'Stok obat belum diisi!';
    }
    
    final stock = int.tryParse(_stockController.text.trim());
    if (stock == null || stock < 0) {
      return 'Stok harus berupa angka (minimal 0)!';
    }
    
    // Validasi jam
    if (_timeController.text.trim().isEmpty) {
      return 'Jam pertama minum belum diisi!';
    }
    
    // Validasi format jam (HH:mm)
    final timePattern = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timePattern.hasMatch(_timeController.text.trim())) {
      return 'Format jam tidak valid! Gunakan format HH:mm (contoh: 08:00)';
    }
    
    // Validasi frequency value untuk every_n_hours
    if (_frequencyType == 'every_n_hours') {
      final freqValue = int.tryParse(_freqValueController.text.trim());
      if (freqValue == null || freqValue <= 0 || freqValue > 24) {
        return 'Jarak minum harus antara 1-24 jam!';
      }
    }
    
    return null; // Semua validasi lolos
  }

  // ══════════════════════════════════════════════════════════════
  // SIMPAN JADWAL KE DATABASE
  // ══════════════════════════════════════════════════════════════

  Future<void> _saveSchedule() async {
    // ─────────────────────────────────────────────────────────────
    // 1. VALIDASI FORM
    // ─────────────────────────────────────────────────────────────
    final errorMessage = _validateForm();
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // ─────────────────────────────────────────────────────────────
    // 2. AMBIL USER ID DARI SESSION
    // ─────────────────────────────────────────────────────────────
    final userId = _session.currentUser?['id'];
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Sesi login tidak valid. Silakan login ulang.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // ─────────────────────────────────────────────────────────────
    // 3. PASTIKAN USER ADA DI DATABASE LOKAL
    // ─────────────────────────────────────────────────────────────
    await _dbHelper.ensureUserExists(
      userId: userId,
      username: _session.username,
      email: _session.userEmail,
      fullName: _session.userName,
    );
    
    // ─────────────────────────────────────────────────────────────
    // 4. SET LOADING STATE
    // ─────────────────────────────────────────────────────────────
    setState(() => _isSaving = true);
    
    try {
      // ─────────────────────────────────────────────────────────────
      // 5. CHECK: APAKAH OBAT SUDAH ADA? (DUPLICATE DETECTION)
      // ─────────────────────────────────────────────────────────────
      final medicationName = _nameController.text.trim();
      final existingMed = await _dbHelper.findMedicationByNameAndDose(
        userId: userId,
        name: medicationName,
      );
      
      int medicationId;
      
      if (existingMed != null) {
        // ═══════════════════════════════════════════════════════════
        // OBAT SUDAH ADA - TANYA USER
        // ═══════════════════════════════════════════════════════════
        setState(() => _isSaving = false);
        
        final newStock = double.parse(_stockController.text.trim());
        final choice = await _showDuplicateMedicationDialog(
          existingMed: existingMed,
          newStock: newStock,
        );
        
        if (choice == null) {
          // User cancel
          return;
        }
        
        setState(() => _isSaving = true);
        
        if (choice == 'add_to_existing') {
          // ─────────────────────────────────────────────────────────
          // USER PILIH: TAMBAH KE OBAT LAMA
          // ─────────────────────────────────────────────────────────
          medicationId = existingMed['id'] as int;
          
          // Tambah stok ke medication yang sudah ada
          await _dbHelper.addMedicationStock(medicationId, newStock);
          
          print('✅ Stock added to existing medication: $medicationId');
          
          // Update schedule yang sudah ada (jangan buat baru)
          // Ambil schedule_id dari existing medication
          final existingSchedules = await _dbHelper.getSchedulesByMedicationId(medicationId);
          
          if (existingSchedules.isNotEmpty) {
            // Update schedule pertama yang ditemukan
            final scheduleId = existingSchedules.first['id'] as int;
            
            // Parse dosis (default 1 jika kosong)
            final dosage = _dosageController.text.trim().isEmpty 
                ? 1.0 
                : double.parse(_dosageController.text.trim());
            
            await _dbHelper.updateSchedule(
              scheduleId: scheduleId,
              timeIntake: _timeController.text.trim(),
              dosage: dosage,
              dosageUnit: _dosageUnit,
              frequencyType: _frequencyType,
              frequencyValue: _frequencyType == 'every_n_hours' 
                  ? int.parse(_freqValueController.text.trim()) 
                  : 1,
            );
            
            print('✅ Schedule updated: $scheduleId');
            
            // Skip schedule creation (langsung ke success message)
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '✅ Stok $medicationName berhasil ditambahkan!',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF0D9488),
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
            
            // CRITICAL: Return OUTSIDE if (mounted) to prevent schedule creation
            return;
          }
          
        } else {
          // ─────────────────────────────────────────────────────────
          // USER PILIH: BUAT OBAT BARU
          // ─────────────────────────────────────────────────────────
          medicationId = await _dbHelper.insertMedication(
            userId: userId,
            name: medicationName,
            drugType: 'prescription',
            totalStock: newStock,
            description: null,
            rxCui: null,
          );
          
          print('✅ New medication created: $medicationId');
        }
        
      } else {
        // ═══════════════════════════════════════════════════════════
        // OBAT BARU - LANGSUNG INSERT
        // ═══════════════════════════════════════════════════════════
        medicationId = await _dbHelper.insertMedication(
          userId: userId,
          name: medicationName,
          drugType: 'prescription',
          totalStock: double.parse(_stockController.text.trim()),
          description: null,
          rxCui: null,
        );
        
        print('✅ New medication created: $medicationId');
      }
      
      if (medicationId <= 0) {
        throw Exception('Gagal menyimpan data obat ke database');
      }
      
      // ─────────────────────────────────────────────────────────────
      // 6. INSERT KE TABEL SCHEDULES
      // ─────────────────────────────────────────────────────────────
      // Parse dosis (default 1 jika kosong)
      final dosage = _dosageController.text.trim().isEmpty 
          ? 1.0 
          : double.parse(_dosageController.text.trim());
      
      final scheduleId = await _dbHelper.insertSchedule(
        medId: medicationId,
        timeIntake: _timeController.text.trim(),
        dosage: dosage,
        dosageUnit: _dosageUnit,
        frequencyType: _frequencyType,
        frequencyValue: _frequencyType == 'every_n_hours' 
            ? int.parse(_freqValueController.text.trim()) 
            : 1, // Default 1 untuk daily
        notes: null,
      );
      
      if (scheduleId <= 0) {
        throw Exception('Gagal menyimpan jadwal ke database');
      }
      
      // ─────────────────────────────────────────────────────────────
      // 7. TAMPILKAN SUCCESS MESSAGE
      // ─────────────────────────────────────────────────────────────
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '✅ Jadwal $medicationName berhasil disimpan!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0D9488), // Teal
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // ─────────────────────────────────────────────────────────────
        // 8. KEMBALI KE HOME SCREEN
        // ─────────────────────────────────────────────────────────────
        // Pop 2x: keluar dari AddScheduleScreen dan ScheduleChoiceScreen
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
      
    } catch (e) {
      // ─────────────────────────────────────────────────────────────
      // 9. HANDLE ERROR
      // ─────────────────────────────────────────────────────────────
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menyimpan jadwal: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // ─────────────────────────────────────────────────────────────
      // 10. RESET LOADING STATE
      // ─────────────────────────────────────────────────────────────
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ══════════════════════════════════════════════════════════════
  // DUPLICATE MEDICATION DIALOG
  // ══════════════════════════════════════════════════════════════

  /// Show dialog saat detect obat duplikat
  /// Return: 'add_to_existing' | 'create_new' | null (cancel)
  Future<String?> _showDuplicateMedicationDialog({
    required Map<String, dynamic> existingMed,
    required double newStock,
  }) async {
    final currentStock = existingMed['total_stock'] as double;
    final totalStock = currentStock + newStock;
    final medName = existingMed['name'] as String;
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.medication,
                color: Color(0xFF0D9488),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Obat Sudah Ada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama obat
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medication_outlined, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      medName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Info stok
            _buildStockInfo('Stok saat ini', currentStock),
            _buildStockInfo('Stok baru', newStock),
            const Divider(height: 24),
            _buildStockInfo('Total stok', totalStock, isTotal: true),
            const SizedBox(height: 16),
            
            // Info message
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tambahkan ke obat yang sudah ada?',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Tombol BATAL
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('BATAL'),
          ),
          
          // Tombol BUAT BARU
          TextButton(
            onPressed: () => Navigator.pop(context, 'create_new'),
            child: const Text(
              'BUAT BARU',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          
          // Tombol TAMBAH (Primary)
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'add_to_existing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('TAMBAH'),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  /// Helper widget untuk menampilkan info stok
  Widget _buildStockInfo(String label, double stock, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 15 : 14,
            ),
          ),
          Text(
            '${stock.toInt()} tablet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 17 : 15,
              color: isTotal ? const Color(0xFF0D9488) : Colors.black87,
            ),
          ),
        ],
      ),
    );
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
            GestureDetector(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF0D9488), // Teal
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Color(0xFF1E293B),
                        ),
                        dialogBackgroundColor: Colors.white,
                      ),
                      child: child!,
                    );
                  },
                );
                
                if (picked != null) {
                  // Format jam ke HH:mm (24 jam)
                  final hour = picked.hour.toString().padLeft(2, '0');
                  final minute = picked.minute.toString().padLeft(2, '0');
                  setState(() {
                    _timeController.text = '$hour:$minute';
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _timeController,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Ketuk untuk pilih jam',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal, width: 2)),
                    prefixIcon: const Icon(Icons.access_time),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
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
                onPressed: _isSaving ? null : _saveSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'SIMPAN JADWAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
