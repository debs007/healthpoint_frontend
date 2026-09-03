class HealthProfile {
  const HealthProfile({
    this.bloodGroup,
    this.heightCm,
    this.weightKg,
    this.dateOfBirth,
    this.age,
    this.gender,
  });

  final String? bloodGroup;
  final int? heightCm;
  final double? weightKg;
  final DateTime? dateOfBirth;
  final int? age;
  final String? gender;

  bool get isEmpty => bloodGroup == null && heightCm == null && weightKg == null && dateOfBirth == null;

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      bloodGroup: json['blood_group'] as String?,
      heightCm: json['height_cm'] as int?,
      weightKg: json['weight_kg'] != null ? double.tryParse(json['weight_kg'].toString()) : null,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth'] as String) : null,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
    );
  }
}
