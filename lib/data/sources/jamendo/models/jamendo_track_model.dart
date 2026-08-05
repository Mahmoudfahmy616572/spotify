class JamendoTrackModel {
  final int id;
  final String name;
  final String artistName;
  final int artistId;
  final String? albumName;
  final int? albumId;
  final String audioUrl;
  final String? downloadUrl;
  final String imageUrl;
  final Duration duration;
  final String? licenseUrl;
  final String? audioFormat;

  JamendoTrackModel({
    required this.id,
    required this.name,
    required this.artistName,
    required this.artistId,
    this.albumName,
    this.albumId,
    required this.audioUrl,
    this.downloadUrl,
    required this.imageUrl,
    required this.duration,
    this.licenseUrl,
    this.audioFormat,
  });

  factory JamendoTrackModel.fromJson(Map<String, dynamic> json) {
    return JamendoTrackModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      artistName: json['artist_name'] ?? '',
      artistId: json['artist_id'] ?? 0,
      albumName: json['album_name'],
      albumId: json['album_id'],
      audioUrl: json['audio'] ?? '',
      downloadUrl: json['audiodownload'],
      imageUrl: json['image'] ?? json['album_image'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
      licenseUrl: json['license_url'],
      audioFormat: json['audiodlformat'],
    );
  }
}
