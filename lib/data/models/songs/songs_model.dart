class SongModel {
  final String id;
  final String title;
  final String artist;
  final String urlSongsbase; // The path/name stored in your bucket
  final String imageUrl; // The path/name stored in your bucket
  final String duration;
  final String lyrics;
  final DateTime releaseDate;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.urlSongsbase,
    required this.imageUrl,
    required this.duration,
    required this.releaseDate,
    required this.lyrics,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'].toString(),
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      urlSongsbase:
          json['urlbase'], // This should be the filename or path in Storage
      imageUrl:
          json['imageUrl'], // This should be the filename or path in Storage
      duration: json['duration']?.toString() ?? '0:00',
      releaseDate: DateTime.parse(json['releaseDate']),
      lyrics: '${json['lyrics'] ?? ''}',
    );
  }
}
