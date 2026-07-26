class LastFmArtistModel {
  final String name;
  final String? imageUrl;
  final String? bannerUrl;
  final String? biography;
  final int? listeners;
  final int? playcount;
  final List<String> tags;

  const LastFmArtistModel({
    required this.name,
    this.imageUrl,
    this.bannerUrl,
    this.biography,
    this.listeners,
    this.playcount,
    this.tags = const [],
  });

  factory LastFmArtistModel.fromJson(Map<String, dynamic> json) {
    final images = json['image'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images.last['#text']?.toString() : null;
    final bio = json['bio'] as Map<String, dynamic>?;
    final tagsData = json['tags']?['tag'] as List<dynamic>? ?? [];
    final tags = tagsData.map((t) => t['name']?.toString() ?? '').where((t) => t.isNotEmpty).toList();

    return LastFmArtistModel(
      name: json['name']?.toString() ?? '',
      imageUrl: imageUrl,
      biography: bio?['summary']?.toString(),
      listeners: int.tryParse(json['stats']?['listeners']?.toString() ?? ''),
      playcount: int.tryParse(json['stats']?['playcount']?.toString() ?? ''),
      tags: tags,
    );
  }
}
