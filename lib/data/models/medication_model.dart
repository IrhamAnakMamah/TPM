/// Model data obat untuk penyimpanan lokal (SQLite).
///
/// Digunakan oleh DatabaseHelper untuk CRUD operasi obat.
class MedicationModel {
  final int? id;
  final String name;
  final String dosage;
  final String frequency;
  final String time;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;

  MedicationModel({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.time,
    this.notes,
    this.isActive = true,
    this.createdAt,
  });

  /// Buat dari Map (dari SQLite query result).
  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      frequency: map['frequency'] as String? ?? '',
      time: map['time'] as String? ?? '',
      notes: map['notes'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  /// Konversi ke Map (untuk SQLite insert/update).
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'time': time,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
    };
  }

  /// Copy with modified fields.
  MedicationModel copyWith({
    int? id,
    String? name,
    String? dosage,
    String? frequency,
    String? time,
    String? notes,
    bool? isActive,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'MedicationModel(id: $id, name: $name, dosage: $dosage)';
}
