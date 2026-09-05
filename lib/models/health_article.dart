class HealthArticle {
  const HealthArticle({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    this.description,
  });

  final int id;
  final String title;
  final String youtubeUrl;
  final String thumbnailUrl;
  final String? description;

  factory HealthArticle.fromJson(Map<String, dynamic> json) {
    return HealthArticle(
      id: json['id'] as int,
      title: json['title'] as String,
      youtubeUrl: json['youtube_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      description: json['description'] as String?,
    );
  }
}
