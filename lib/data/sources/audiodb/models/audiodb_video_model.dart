class AudioDbVideoModel {
  final String id;
  final String track;
  final String artist;
  final String? album;
  final String? description;
  final String? videoUrl;

  const AudioDbVideoModel({
    required this.id,
    required this.track,
    required this.artist,
    this.album,
    this.description,
    this.videoUrl,
  });

  factory AudioDbVideoModel.fromJson(Map<String, dynamic> json) {
    return AudioDbVideoModel(
      id: json['idTrack']?.toString() ?? '',
      track: json['strTrack']?.toString() ?? '',
      artist: json['strArtist']?.toString() ?? '',
      album: json['strAlbum']?.toString(),
      description: json['strDescriptionEN']?.toString(),
      videoUrl: json['strMusicVid']?.toString(),
    );
  }

  String? get youtubeId {
    if (videoUrl == null) return null;
    final uri = Uri.tryParse(videoUrl!);
    if (uri == null) return null;
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return null;
  }
}
