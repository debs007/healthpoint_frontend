import 'doctor_hospital_affiliation.dart';

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.degree,
    this.department,
    this.yearsOfExperience,
    this.bio,
    this.photoUrl,
    this.hospitals = const [],
  });

  final int id;
  final String name;
  final String degree;
  final String? department;
  final int? yearsOfExperience;
  final String? bio;
  final String? photoUrl;
  final List<DoctorHospitalAffiliation> hospitals;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final hospitalsJson = json['hospitals'] as List<dynamic>? ?? [];
    return Doctor(
      id: json['id'] as int,
      name: json['name'] as String,
      degree: json['degree'] as String,
      department: json['department'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      bio: json['bio'] as String?,
      photoUrl: json['photo_url'] as String?,
      hospitals: hospitalsJson.map((e) => DoctorHospitalAffiliation.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
