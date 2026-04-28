class ScheduleModel {
  final int? id;
  final int medId;
  final String timeIntake;
  final double dosage;
  final String dosageUnit;
  final String frequencyType;
  final int frequencyValue;
  final String status;

  ScheduleModel({
    this.id,
    required this.medId,
    required this.timeIntake,
    required this.dosage,
    required this.dosageUnit,
    required this.frequencyType,
    required this.frequencyValue,
    this.status = 'active',
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'],
      medId: map['med_id'],
      timeIntake: map['time_intake'],
      dosage: map['dosage'],
      dosageUnit: map['dosage_unit'],
      frequencyType: map['frequency_type'],
      frequencyValue: map['frequency_value'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'med_id': medId,
      'time_intake': timeIntake,
      'dosage': dosage,
      'dosage_unit': dosageUnit,
      'frequency_type': frequencyType,
      'frequency_value': frequencyValue,
      'status': status,
    };
  }

  ScheduleModel copyWith({
    int? id, int? medId, String? timeIntake, double? dosage,
    String? dosageUnit, String? frequencyType, int? frequencyValue, String? status,
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
    );
  }
}