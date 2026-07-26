class LastFmTrackModel {
  final String name;
  final String artist;
  final String? imageUrl;
  final String? url;
  final int? playcount;

  const LastFmTrackModel({
    required this.name,
    required this.artist,
    this.imageUrl,
    this.url,
    this.playcount,
  });

  factory LastFmTrackModel.fromJson(Map<String, dynamic> json) {
    final images = json['image'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images.last['#text']?.toString() : null;
    final artistData = json['artist'] as Map<String, dynamic>?;

    return LastFmTrackModel(
      name: json['name']?.toString() ?? '',
      artist: artistData?['name']?.toString() ?? json['artist']?.toString() ?? '',
      imageUrl: imageUrl,
      url: json['url']?.toString(),
      playcount: int.tryParse(json['playcount']?.toString() ?? ''),
    );
  }
}
