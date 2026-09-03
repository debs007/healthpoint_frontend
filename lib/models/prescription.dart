class Prescription {
  const Prescription({
    required this.id,
    this.orderId,
    required this.verificationStatus,
    this.rejectionReason,
    this.verifiedAt,
    required this.createdAt,
  });

  final int id;
  final int? orderId;
  final String verificationStatus; // pending, approved, rejected
  final String? rejectionReason;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as int,
      orderId: json['order_id'] as int?,
      verificationStatus: json['verification_status'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      verifiedAt: json['verified_at'] != null ? DateTime.tryParse(json['verified_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
