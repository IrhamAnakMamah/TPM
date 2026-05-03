import 'package:flutter/material.dart';
import '../../../core/services/session_manager.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/local/database_helper.dart';
import '../../dashboard/screens/schedule_choice_screen.dart';
import 'medication_detail_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  final _dbHelper = DatabaseHelper();
  final _session = SessionManager();
  final _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allSchedules = [];
  List<Map<String, dynamic>> _filteredSchedules = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // ══════════════════════════════════════════════════════════════
  // LOAD SCHEDULES FROM DATABASE
  // ══════════════════════════════════════════════════════════════
  
  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _session.currentUser?['id'];
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      // Ensure user exists
      await _dbHelper.ensureUserExists(
        userId: userId,
        username: _session.username,
        email: _session.userEmail,
        fullName: _session.userName,
      );
      
      // Get all active schedules with medication info
      final schedules = await _dbHelper.getActiveSchedulesWithMed(userId);
      
      setState(() {
        _allSchedules = schedules;
        _filteredSchedules = schedules;
        _isLoading = false;
      });
      
      print('✅ Loaded ${schedules.length} schedules');
    } catch (e) {
      print('❌ Error loading schedules: $e');
      setState(() => _isLoading = false);
    }
  }
  
  // ══════════════════════════════════════════════════════════════
  // SEARCH FUNCTIONALITY
  // ══════════════════════════════════════════════════════════════
  
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredSchedules = _allSchedules;
      } else {
        _filteredSchedules = _allSchedules.where((schedule) {
          final medName = (schedule['med_name'] as String).toLowerCase();
          return medName.contains(query);
        }).toList();
      }
    });
  }
  
  // ══════════════════════════════════════════════════════════════
  // DELETE SCHEDULE
  // ══════════════════════════════════════════════════════════════
  
  Future<void> _deleteSchedule(int scheduleId, String medName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Hapus Jadwal?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal "$medName"?\n\nJadwal yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    // Delete from database
    try {
      await _dbHelper.deleteSchedule(scheduleId);
      
      // Cancel notification
      await NotificationService().cancelNotification(scheduleId);
      print('✅ Notification cancelled for schedule: $scheduleId');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Jadwal "$medName" berhasil dihapus'),
            backgroundColor: const Color(0xFF0D9488),
          ),
        );
        
        // Reload schedules
        _loadSchedules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menghapus jadwal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // ══════════════════════════════════════════════════════════════
  // BUILD UI
  // ══════════════════════════════════════════════════════════════
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Daftar Jadwal Obat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Toggle search bar (optional enhancement)
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSchedules,
        child: Column(
          children: [
            // ─────────────────────────────────────────────────────────
            // SEARCH BAR
            // ─────────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari obat...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0D9488)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            
            // ─────────────────────────────────────────────────────────
            // SCHEDULE LIST
            // ─────────────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D9488),
                      ),
                    )
                  : _filteredSchedules.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSchedules.length,
                          itemBuilder: (context, index) {
                            final schedule = _filteredSchedules[index];
                            return _buildScheduleCard(schedule);
                          },
                        ),
            ),
          ],
        ),
      ),
      
      // ─────────────────────────────────────────────────────────────
      // FAB: TAMBAH JADWAL
      // ─────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScheduleChoiceScreen(),
            ),
          );
          _loadSchedules(); // Refresh after adding
        },
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Jadwal'),
      ),
    );
  }
  
  // ══════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ══════════════════════════════════════════════════════════════
  
  Widget _buildEmptyState() {
    final isSearching = _searchController.text.isNotEmpty;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              isSearching ? 'Obat Tidak Ditemukan' : 'Belum Ada Jadwal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isSearching
                  ? 'Coba kata kunci lain'
                  : 'Tap tombol + untuk menambahkan\njadwal obat pertama',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // ══════════════════════════════════════════════════════════════
  // SCHEDULE CARD
  // ══════════════════════════════════════════════════════════════
  
  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final scheduleId = schedule['id'] as int;
    final medName = schedule['med_name'] as String;
    final timeIntake = schedule['time_intake'] as String;
    final dosage = schedule['dosage'] as double;
    final dosageUnit = schedule['dosage_unit'] as String;
    final notes = schedule['notes'] as String?;
    final totalStock = schedule['total_stock'] as double;
    
    final displayName = '$medName ${dosage.toInt()}$dosageUnit';
    final displayTime = '$timeIntake WIB';
    final displayNote = notes ?? 'Sesuai aturan';
    final isLowStock = totalStock < 5;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLowStock ? Colors.orange.shade100 : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          // Navigate to detail screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicationDetailScreen(
                scheduleId: scheduleId,
              ),
            ),
          );
          
          // Reload if medication was deleted (stock = 0)
          if (result == true) {
            _loadSchedules();
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLowStock ? Colors.orange.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isLowStock ? Icons.warning_amber_rounded : Icons.medication,
                  color: isLowStock ? Colors.orange : Colors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$displayTime • $displayNote',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 14,
                          color: isLowStock ? Colors.orange.shade700 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLowStock
                              ? '⚠️ Stok tinggal ${totalStock.toInt()}'
                              : 'Stok: ${totalStock.toInt()} tablet',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isLowStock ? FontWeight.w600 : FontWeight.normal,
                            color: isLowStock ? Colors.orange.shade700 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade400,
                onPressed: () => _deleteSchedule(scheduleId, medName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
