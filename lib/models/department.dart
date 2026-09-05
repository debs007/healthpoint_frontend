class Department {
  const Department({required this.id, required this.name});

  final int id;
  final String name;

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(id: json['id'] as int, name: json['name'] as String);
  }
}
