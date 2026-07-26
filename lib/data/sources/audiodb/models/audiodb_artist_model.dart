class AudioDbArtistModel {
  final String id;
  final String name;
  final String? thumbnail;
  final String? banner;
  final String? biography;
  final String? genre;
  final String? country;
  final String? formedYear;
  final String? website;

  const AudioDbArtistModel({
    required this.id,
    required this.name,
    this.thumbnail,
    this.banner,
    this.biography,
    this.genre,
    this.country,
    this.formedYear,
    this.website,
  });

  factory AudioDbArtistModel.fromJson(Map<String, dynamic> json) {
    return AudioDbArtistModel(
      id: json['idArtist']?.toString() ?? '',
      name: json['strArtist']?.toString() ?? '',
      thumbnail: json['strArtistThumb']?.toString(),
      banner: json['strArtistBanner']?.toString(),
      biography: json['strBiographyEN']?.toString(),
      genre: json['strGenre']?.toString(),
      country: json['strCountry']?.toString(),
      formedYear: json['intFormedYear']?.toString(),
      website: json['strWebsite']?.toString(),
    );
  }
}
