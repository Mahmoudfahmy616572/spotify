class WolfXSpotifyArtistModel {
  final String id;
  final String name;
  final String? imageUrl;
  final int? followers;
  final int? popularity;
  final List<String> genres;

  const WolfXSpotifyArtistModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.followers,
    this.popularity,
    this.genres = const [],
  });

  factory WolfXSpotifyArtistModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images.first['url']?.toString() : null;
    final genres = (json['genres'] as List<dynamic>? ?? [])
        .map((g) => g.toString())
        .toList();

    return WolfXSpotifyArtistModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: imageUrl,
      followers: json['followers']?['total'] as int?,
      popularity: json['popularity'] as int?,
      genres: genres,
    );
  }
}
