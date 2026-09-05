class VisitDay {
  const VisitDay({required this.dayOfWeek, required this.startTime, required this.endTime});

  final String dayOfWeek; // 'monday'..'sunday'
  final String startTime; // 'HH:mm'
  final String endTime;

  factory VisitDay.fromJson(Map<String, dynamic> json) {
    return VisitDay(
      dayOfWeek: json['day_of_week'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }
}

class DoctorHospitalAffiliation {
  const DoctorHospitalAffiliation({
    required this.affiliationId,
    required this.hospitalId,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.consultationCharge,
    required this.visitDays,
  });

  final int affiliationId;
  final int hospitalId;
  final String hospitalName;
  final String hospitalAddress;
  final double consultationCharge;
  final List<VisitDay> visitDays;

  /// Which days of the week this affiliation is bookable on - used to
  /// restrict the date picker to only valid days.
  Set<String> get visitDayNames => visitDays.map((d) => d.dayOfWeek).toSet();

  factory DoctorHospitalAffiliation.fromJson(Map<String, dynamic> json) {
    final daysJson = json['visit_days'] as List<dynamic>? ?? [];
    return DoctorHospitalAffiliation(
      affiliationId: json['affiliation_id'] as int,
      hospitalId: json['hospital_id'] as int,
      hospitalName: json['hospital_name'] as String,
      hospitalAddress: json['hospital_address'] as String,
      consultationCharge: double.tryParse(json['consultation_charge'].toString()) ?? 0,
      visitDays: daysJson.map((e) => VisitDay.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
