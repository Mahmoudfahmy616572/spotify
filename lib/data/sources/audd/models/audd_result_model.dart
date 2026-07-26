class AuddResultModel {
  final String title;
  final String artist;
  final String? album;
  final String? releaseDate;
  final String? artworkUrl;
  final String? spotifyUrl;
  final String? isrc;

  const AuddResultModel({
    required this.title,
    required this.artist,
    this.album,
    this.releaseDate,
    this.artworkUrl,
    this.spotifyUrl,
    this.isrc,
  });

  factory AuddResultModel.fromJson(Map<String, dynamic> json) {
    final spotify = json['spotify'] as Map<String, dynamic>?;
    final albumImages = spotify?['album']?['images'] as List<dynamic>? ?? [];
    final artwork = albumImages.isNotEmpty ? albumImages.first['url']?.toString() : null;

    return AuddResultModel(
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      album: json['album']?.toString(),
      releaseDate: json['release_date']?.toString(),
      artworkUrl: artwork ?? json['artwork']?.toString(),
      spotifyUrl: spotify?['external_urls']?['spotify']?.toString(),
      isrc: json['isrc']?.toString(),
    );
  }
}
