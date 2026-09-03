class User {
  const User({
    required this.id,
    required this.name,
    required this.mobile,
    this.alternateMobile,
    this.email,
    this.profileImageUrl,
  });

  final int id;
  final String name;
  final String mobile;
  final String? alternateMobile;
  final String? email;
  final String? profileImageUrl;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      alternateMobile: json['alternate_mobile'] as String?,
      email: json['email'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }
}
