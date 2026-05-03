import 'package:flutter/material.dart';
import '../../../core/services/session_manager.dart';
import '../../../data/local/database_helper.dart';
import '../../pharmacy_map/screens/map_screen.dart';
import '../../medications/screens/medication_list_screen.dart';
import '../../medications/screens/medication_detail_screen.dart';
import 'schedule_choice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dbHelper = DatabaseHelper();
  final _session = SessionManager();
  
  List<Map<String, dynamic>> _todaySchedules = [];
  bool _isLoading = true;
  int _takenCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTodaySchedules();
  }

  /// Load jadwal hari ini dari database
  Future<void> _loadTodaySchedules() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _session.currentUser?['id'];
      if (userId == null) {
        print('⚠️ User ID tidak ditemukan di session');
        setState(() => _isLoading = false);
        return;
      }

      // Pastikan user ada di database lokal
      await _dbHelper.ensureUserExists(
        userId: userId,
        username: _session.username,
        email: _session.userEmail,
        fullName: _session.userName,
      );

      // Ambil semua jadwal aktif dengan info obat (JOIN query)
      final schedules = await _dbHelper.getActiveSchedulesWithMed(userId);
      
      // Hitung statistik kepatuhan
      final stats = await _dbHelper.getAdherenceStats(userId, days: 1);
      final takenToday = stats['on-time'] ?? 0;
      
      setState(() {
        _todaySchedules = schedules;
        _totalCount = schedules.length;
        _takenCount = takenToday;
        _isLoading = false;
      });
      
      print('✅ Loaded ${schedules.length} schedules for user $userId');
    } catch (e) {
      print('❌ Error loading schedules: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _session.userName;
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return RefreshIndicator(
      onRefresh: _loadTodaySchedules,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Halo, $displayName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text(_session.userEmail.isNotEmpty ? _session.userEmail : 'Informatika UPN "Veteran" Yogyakarta', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.teal.shade100, width: 2)),
                  child: CircleAvatar(radius: 25, backgroundColor: Colors.teal, child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // ══════════════════════════════════════════════════════════
            // KEPATUHAN OBAT CARD (DATA REAL)
            // ══════════════════════════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: const Color(0xFF0D9488).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kepatuhan Obat', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        _isLoading 
                            ? 'Memuat...' 
                            : _totalCount == 0 
                                ? 'Belum ada jadwal' 
                                : 'Sudah Minum $_takenCount/$_totalCount',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _totalCount == 0 ? 0 : _takenCount / _totalCount,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        strokeWidth: 6,
                      ),
                      const Icon(Icons.check, color: Colors.white, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text('Layanan Utama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildQuickAction(
                  context: context, icon: Icons.map_rounded, label: 'Cari Apotek', color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen())),
                ),
                const SizedBox(width: 15),
                _buildQuickAction(
                  context: context, icon: Icons.add_alarm, label: 'Tambah Jadwal', color: Colors.blue,
                  onTap: () async {
                    // Navigate dan refresh saat kembali
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const ScheduleChoiceScreen()));
                    _loadTodaySchedules(); // Refresh data
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jadwal Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_todaySchedules.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MedicationListScreen(),
                        ),
                      );
                      // Refresh data setelah kembali dari MedicationListScreen
                      _loadTodaySchedules();
                    },
                    child: const Text('Lihat Semua'),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // ══════════════════════════════════════════════════════════
            // JADWAL HARI INI (DATA REAL DARI DATABASE)
            // ══════════════════════════════════════════════════════════
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                ),
              )
            else if (_todaySchedules.isEmpty)
              _buildEmptyState()
            else
              ..._todaySchedules.map((schedule) => _buildScheduleCard(schedule)).toList(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({required BuildContext context, required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color)),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  /// Build empty state saat belum ada jadwal
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Jadwal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Tambah Jadwal" untuk membuat jadwal minum obat pertama Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build schedule card dari data database
  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final scheduleId = schedule['id'] as int;
    final medName = schedule['med_name'] as String;
    final timeIntake = schedule['time_intake'] as String;
    final dosage = schedule['dosage'] as double;
    final dosageUnit = schedule['dosage_unit'] as String;
    final notes = schedule['notes'] as String?;
    final totalStock = schedule['total_stock'] as double;
    
    // Format display
    final displayName = '$medName ${dosage.toInt()} $dosageUnit';
    final displayTime = '$timeIntake WIB';
    final displayNote = notes ?? 'Sesuai aturan';
    
    // Status: cek apakah sudah diminum hari ini (TODO: implementasi pengecekan intake_logs)
    final isDone = false; // Placeholder - akan diimplementasi di Task 6
    
    // Warning jika stok menipis
    final isLowStock = totalStock < 5;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone 
              ? Colors.teal.shade100 
              : isLowStock 
                  ? Colors.orange.shade100 
                  : Colors.transparent,
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
          
          // Reload if medication was deleted
          if (result == true) {
            _loadTodaySchedules();
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDone 
                      ? Colors.teal.shade50 
                      : isLowStock 
                          ? Colors.orange.shade50 
                          : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDone 
                      ? Icons.check_circle 
                      : isLowStock 
                          ? Icons.warning_amber_rounded 
                          : Icons.pending_actions,
                  color: isDone 
                      ? Colors.teal 
                      : isLowStock 
                          ? Colors.orange 
                          : Colors.blue,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$displayTime • $displayNote',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                ),
                if (isLowStock) ...[
                  const SizedBox(height: 4),
                  Text(
                    '⚠️ Stok tinggal ${totalStock.toInt()}',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isDone)
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}