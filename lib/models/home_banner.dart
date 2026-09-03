class HomeBanner {
  const HomeBanner({
    required this.id,
    required this.imageUrl,
    this.badgeText,
    this.headline,
    this.subtitle,
    this.buttonText,
  });

  final int id;
  final String imageUrl;
  final String? badgeText;
  final String? headline;
  final String? subtitle;
  final String? buttonText;

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
      badgeText: json['badge_text'] as String?,
      headline: json['headline'] as String?,
      subtitle: json['subtitle'] as String?,
      buttonText: json['button_text'] as String?,
    );
  }
}
