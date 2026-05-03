import 'package:flutter/material.dart';
import '../../../data/local/database_helper.dart';

class MedicationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> scheduleData;

  const MedicationDetailScreen({super.key, required this.scheduleData});

  void _confirmIntake(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    double currentStock = scheduleData['total_stock'];
    double dosage = scheduleData['dosage'];
    double newStock = currentStock - dosage;
    
    await db.update('medications', {'total_stock': newStock}, where: 'id = ?', whereArgs: [scheduleData['med_id']]);
    await dbHelper.logIntake(scheduleData['id'], 'on-time');

    if (newStock <= 0) {
      await dbHelper.updateScheduleStatus(scheduleData['id'], 'expired');
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Obat berhasil diminum! Stok terupdate.')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Detail Jadwal'), backgroundColor: Colors.white, foregroundColor: const Color(0xFF1E293B), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30), width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
              child: Column(
                children: [
                  const Icon(Icons.medication, size: 80, color: Colors.teal),
                  const SizedBox(height: 20),
                  Text(scheduleData['med_name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 20), const Divider(), const SizedBox(height: 20),
                  _buildDetailRow('Waktu Minum', scheduleData['time_intake'], Icons.access_time),
                  _buildDetailRow('Dosis', '${scheduleData['dosage']} ${scheduleData['dosage_unit']}', Icons.science),
                  _buildDetailRow('Sisa Stok', '${scheduleData['total_stock']} unit', Icons.inventory_2),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton.icon(
                onPressed: () => _confirmIntake(context),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text('KONFIRMASI SUDAH MINUM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(icon, color: Colors.grey, size: 20), const SizedBox(width: 10), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16))]),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}