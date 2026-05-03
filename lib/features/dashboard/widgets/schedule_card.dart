import 'package:flutter/material.dart';

/// Kartu jadwal obat yang digunakan di HomeScreen.
///
/// Menampilkan info obat, waktu minum, catatan, dan status.
class ScheduleCard extends StatelessWidget {
  final String medicineName;
  final String time;
  final String note;
  final bool isDone;
  final VoidCallback? onTap;

  const ScheduleCard({
    super.key,
    required this.medicineName,
    required this.time,
    required this.note,
    required this.isDone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDone ? Colors.teal.shade100 : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon status
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDone ? Colors.teal.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDone ? Icons.check_circle : Icons.pending_actions,
                color: isDone ? Colors.teal : Colors.orange,
              ),
            ),
            const SizedBox(width: 15),
            // Info obat
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicineName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '$time • $note',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow indicator jika belum selesai
            if (!isDone)
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
