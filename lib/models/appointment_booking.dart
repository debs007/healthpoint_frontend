class AppointmentBooking {
  const AppointmentBooking({
    required this.id,
    required this.orderId,
    required this.doctorName,
    required this.doctorDegree,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.scheduledDate,
    required this.status,
  });

  final int id;
  final int orderId;
  final String doctorName;
  final String doctorDegree;
  final String hospitalName;
  final String hospitalAddress;
  final DateTime scheduledDate;
  final String status; // pending, confirmed, completed, cancelled

  factory AppointmentBooking.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] as Map<String, dynamic>?;
    final hospital = json['hospital'] as Map<String, dynamic>?;

    return AppointmentBooking(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      doctorName: doctor?['name'] as String? ?? 'Doctor',
      doctorDegree: doctor?['degree'] as String? ?? '',
      hospitalName: hospital?['name'] as String? ?? 'Hospital',
      hospitalAddress: hospital?['address'] as String? ?? '',
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      status: json['status'] as String,
    );
  }
}
