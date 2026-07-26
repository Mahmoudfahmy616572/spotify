class WolfXSpotifyTrackModel {
  final String id;
  final String name;
  final String artistName;
  final String artistId;
  final String? albumName;
  final String? albumId;
  final String? imageUrl;
  final int? durationMs;
  final String? previewUrl;
  final int? popularity;
  final List<String> genres;
  final String? isrc;

  const WolfXSpotifyTrackModel({
    required this.id,
    required this.name,
    required this.artistName,
    required this.artistId,
    this.albumName,
    this.albumId,
    this.imageUrl,
    this.durationMs,
    this.previewUrl,
    this.popularity,
    this.genres = const [],
    this.isrc,
  });

  factory WolfXSpotifyTrackModel.fromJson(Map<String, dynamic> json) {
    final artists = json['artists'] as List<dynamic>? ?? [];
    final album = json['album'] as Map<String, dynamic>?;
    final images = album?['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images.first['url']?.toString() : null;

    return WolfXSpotifyTrackModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      artistName: artists.isNotEmpty ? artists.first['name']?.toString() ?? '' : '',
      artistId: artists.isNotEmpty ? artists.first['id']?.toString() ?? '' : '',
      albumName: album?['name']?.toString(),
      albumId: album?['id']?.toString(),
      imageUrl: imageUrl,
      durationMs: json['duration_ms'] as int?,
      previewUrl: json['preview_url']?.toString(),
      popularity: json['popularity'] as int?,
      isrc: json['external_ids']?['isrc']?.toString(),
    );
  }
}
