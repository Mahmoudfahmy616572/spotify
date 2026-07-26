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

    return VeromeTrackModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? json['channelTitle']?.toString() ?? '',
      thumbnail: thumbnail,
      durationMs: json['duration_ms'] as int?,
      streamUrl: json['streamUrl']?.toString(),
    );
  }
}
