class VeromeTrackModel {
  final String id;
  final String title;
  final String artist;
  final String? thumbnail;
  final int? durationMs;
  final String? streamUrl;

  const VeromeTrackModel({
    required this.id,
    required this.title,
    required this.artist,
    this.thumbnail,
    this.durationMs,
    this.streamUrl,
  });

  factory VeromeTrackModel.fromJson(Map<String, dynamic> json) {
    final thumbnails = json['thumbnails'] as List<dynamic>? ?? [];
    final thumbnail = thumbnails.isNotEmpty ? thumbnails.first['url']?.toString() : null;

    final artists = json['artists'] as List<dynamic>?;
    final artistName = artists != null && artists.isNotEmpty
        ? artists.first['name']?.toString()
        : json['artist']?.toString() ?? json['channelTitle']?.toString() ?? '';

    return VeromeTrackModel(
      id: json['videoId']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artist: artistName ?? '',
      thumbnail: thumbnail,
      durationMs: json['duration_ms'] as int?,
      streamUrl: json['streamUrl']?.toString(),
    );
  }
}
