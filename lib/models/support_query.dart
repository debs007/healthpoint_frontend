class SupportQuery {
  const SupportQuery({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  final int id;
  final String subject;
  final String message;
  final String status; // open | resolved
  final DateTime createdAt;
  final DateTime? resolvedAt;

  factory SupportQuery.fromJson(Map<String, dynamic> json) {
    return SupportQuery(
      id: json['id'] as int,
      subject: json['subject'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at'] as String) : null,
    );
  }
}
