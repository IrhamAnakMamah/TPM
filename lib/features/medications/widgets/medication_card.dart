import 'package:flutter/material.dart';
import 'schedule_badge.dart';

class MedicationCard extends StatelessWidget {
  final Map<String, dynamic> scheduleData;
  final VoidCallback onTap;

  const MedicationCard({super.key, required this.scheduleData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isActive = scheduleData['status'] == 'active';
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.teal.shade100 : Colors.grey.shade300, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isActive ? Colors.teal.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isActive ? Icons.medication : Icons.medication_outlined,
                color: isActive ? Colors.teal : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheduleData['med_name'] ?? 'Obat',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF1E293B) : Colors.grey,
                      decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ScheduleBadge(icon: Icons.access_time, label: scheduleData['time_intake'] ?? '--:--', color: isActive ? Colors.orange : Colors.grey),
                      const SizedBox(width: 8),
                      ScheduleBadge(icon: Icons.science, label: '${scheduleData['dosage']} ${scheduleData['dosage_unit']}', color: isActive ? Colors.blue : Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}