class WolfXSpotifyAlbumModel {
  final String id;
  final String name;
  final String artistName;
  final String? imageUrl;
  final int? totalTracks;
  final String? releaseDate;

  const WolfXSpotifyAlbumModel({
    required this.id,
    required this.name,
    required this.artistName,
    this.imageUrl,
    this.totalTracks,
    this.releaseDate,
  });

  factory WolfXSpotifyAlbumModel.fromJson(Map<String, dynamic> json) {
    final artists = json['artists'] as List<dynamic>? ?? [];
    final images = json['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images.first['url']?.toString() : null;

    return WolfXSpotifyAlbumModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      artistName: artists.isNotEmpty ? artists.first['name']?.toString() ?? '' : '',
      imageUrl: imageUrl,
      totalTracks: json['total_tracks'] as int?,
      releaseDate: json['release_date']?.toString(),
    );
  }
}
