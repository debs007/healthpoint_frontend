class Vital {
  const Vital({
    required this.id,
    this.heartRateBpm,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.spo2Percentage,
    this.temperatureFahrenheit,
    required this.recordedAt,
  });

  final int id;
  final int? heartRateBpm;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? spo2Percentage;
  final double? temperatureFahrenheit;
  final DateTime recordedAt;

  String? get bloodPressureLabel =>
      (bloodPressureSystolic != null && bloodPressureDiastolic != null)
          ? '$bloodPressureSystolic/$bloodPressureDiastolic'
          : null;

  factory Vital.fromJson(Map<String, dynamic> json) {
    return Vital(
      id: json['id'] as int,
      heartRateBpm: json['heart_rate_bpm'] as int?,
      bloodPressureSystolic: json['blood_pressure_systolic'] as int?,
      bloodPressureDiastolic: json['blood_pressure_diastolic'] as int?,
      spo2Percentage: json['spo2_percentage'] as int?,
      temperatureFahrenheit: json['temperature_fahrenheit'] != null
          ? double.tryParse(json['temperature_fahrenheit'].toString())
          : null,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }
}
