/// Model jadwal obat sesuai skema SKPL
class ScheduleModel {
  final int? id;
  final int medId;           // foreign key ke medications.id
  final String timeIntake;   // format "HH:mm", contoh "08:00"
  final double dosage;       // jumlah dosis per konsumsi
  final String dosageUnit;   // "mg", "ml", "tablet", "kapsul"
  final String frequencyType;  // "daily" atau "every_n_hours"
  final int frequencyValue;    // 1 = sekali sehari, 8 = tiap 8 jam
  final String status;       // "active" atau "expired"
  final String? notes;       // Catatan tambahan
  final DateTime? createdAt;

  ScheduleModel({
    this.id,
    required this.medId,
    required this.timeIntake,
    required this.dosage,
    required this.dosageUnit,
    required this.frequencyType,
    required this.frequencyValue,
    this.status = 'active',
    this.notes,
    this.createdAt,
  });

  /// Buat dari Map (dari SQLite query result)
  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] as int?,
      medId: map['med_id'] as int,
      timeIntake: map['time_intake'] as String,
      dosage: (map['dosage'] as num).toDouble(),
      dosageUnit: map['dosage_unit'] as String,
      frequencyType: map['frequency_type'] as String,
      frequencyValue: map['frequency_value'] as int,
      status: map['status'] as String? ?? 'active',
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  /// Konversi ke Map (untuk SQLite insert/update)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'med_id': medId,
      'time_intake': timeIntake,
      'dosage': dosage,
      'dosage_unit': dosageUnit,
      'frequency_type': frequencyType,
      'frequency_value': frequencyValue,
      'status': status,
      'notes': notes,
    };
  }

  /// Copy with modified fields
  ScheduleModel copyWith({
    int? id,
    int? medId,
    String? timeIntake,
    double? dosage,
    String? dosageUnit,
    String? frequencyType,
    int? frequencyValue,
    String? status,
    String? notes,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      medId: medId ?? this.medId,
      timeIntake: timeIntake ?? this.timeIntake,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyValue: frequencyValue ?? this.frequencyValue,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  /// Deskripsi frekuensi yang human-readable
  String get frequencyDescription {
    if (frequencyType == 'daily') {
      return 'Sekali sehari';
    } else {
      if (frequencyValue == 12) {
        return '2x sehari';
      } else if (frequencyValue == 8) {
        return '3x sehari';
      } else if (frequencyValue == 6) {
        return '4x sehari';
      } else {
        return 'Setiap $frequencyValue jam';
      }
    }
  }

  @override
  String toString() => 'ScheduleModel(id: $id, medId: $medId, time: $timeIntake, dosage: $dosage $dosageUnit)';
}
