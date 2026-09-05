class HealthRecordItem {
  const HealthRecordItem({
    required this.id,
    required this.type,
    required this.title,
    required this.hasFile,
    required this.recordDate,
    this.notes,
  });

  final String id;
  final String type; // lab_report, medical_document, vaccination, checkup, prescription
  final String title;
  final bool hasFile;
  final DateTime recordDate;
  final String? notes;

  /// True for a composite "prescription-N" entry, never a real
  /// HealthRecord row - these come from a separate model entirely and
  /// aren't deletable through the health-records delete endpoint.
  bool get isPrescription => id.startsWith('prescription-');

  factory HealthRecordItem.fromJson(Map<String, dynamic> json) {
    return HealthRecordItem(
      // Backend sends either an int (health_records) or a prefixed string
      // (prescription-N) - normalized to String here either way, so the
      // rest of the app never needs to know which table a given item
      // actually came from.
      id: json['id'].toString(),
      type: json['type'] as String,
      title: json['title'] as String,
      hasFile: json['has_file'] as bool? ?? false,
      recordDate: DateTime.parse(json['record_date'] as String),
      notes: json['notes'] as String?,
    );
  }
}
