class LabTest {
  const LabTest({
    required this.id,
    this.category,
    required this.name,
    this.description,
    this.sampleType,
    this.preparationInstructions,
    required this.price,
    required this.requiresCenterVisit,
    this.durationMinutes,
  });

  final int id;
  final String? category;
  final String name;
  final String? description;
  final String? sampleType;
  final String? preparationInstructions;
  final double price;
  final bool requiresCenterVisit;
  final int? durationMinutes;

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: json['id'] as int,
      category: json['category'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      sampleType: json['sample_type'] as String?,
      preparationInstructions: json['preparation_instructions'] as String?,
      price: double.tryParse(json['price'].toString()) ?? 0,
      requiresCenterVisit: json['requires_center_visit'] as bool? ?? false,
      durationMinutes: json['duration_minutes'] as int?,
    );
  }
}
