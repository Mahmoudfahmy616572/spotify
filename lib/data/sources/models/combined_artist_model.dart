class CombinedArtistModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String? bannerUrl;
  final String? biography;
  final List<String> genres;
  final String? country;
  final int? followers;
  final int? listeners;
  final int? popularity;
  final List<String> topTrackNames;
  final List<String> similarArtistNames;

  const CombinedArtistModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.bannerUrl,
    this.biography,
    this.genres = const [],
    this.country,
    this.followers,
    this.listeners,
    this.popularity,
    this.topTrackNames = const [],
    this.similarArtistNames = const [],
  });
}
