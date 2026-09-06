class MedicineReminder {
  const MedicineReminder({
    required this.id,
    required this.medicineName,
    this.dosageNote,
    required this.times,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  final int id;
  final String medicineName;
  final String? dosageNote;
  final List<String> times; // "HH:mm" strings, e.g. ["09:00", "21:00"]
  final DateTime startDate;
  final DateTime? endDate; // null = ongoing/indefinite course
  final bool isActive;

  factory MedicineReminder.fromJson(Map<String, dynamic> json) {
    final timesJson = json['times'] as List<dynamic>? ?? [];
    return MedicineReminder(
      id: json['id'] as int,
      medicineName: json['medicine_name'] as String,
      dosageNote: json['dosage_note'] as String?,
      times: timesJson.map((e) => e.toString()).toList(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
