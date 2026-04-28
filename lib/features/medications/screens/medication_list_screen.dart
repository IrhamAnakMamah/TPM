import 'package:flutter/material.dart';
import '../../../data/local/database_helper.dart';
import '../widgets/medication_card.dart';
import 'add_medication_screen.dart';
import 'medication_detail_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    final data = await dbHelper.getSchedulesWithMed(1);
    setState(() {
      _schedules = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Jadwal Obat Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, foregroundColor: const Color(0xFF1E293B), elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _schedules.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSchedules,
                  color: Colors.teal,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final item = _schedules[index];
                      return MedicationCard(
                        scheduleData: item,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => MedicationDetailScreen(scheduleData: item)));
                          _loadSchedules(); 
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMedicationScreen()));
          _loadSchedules(); 
        },
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Obat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_liquid, size: 80, color: Colors.teal.shade200),
          const SizedBox(height: 20),
          const Text('Belum Ada Jadwal Obat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),
          const Text('Klik tombol Tambah di bawah untuk memulai.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}