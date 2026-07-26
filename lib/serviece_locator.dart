import 'package:get_it/get_it.dart';
import 'package:spotify/data/repositories/auth/auth_repo_impl.dart';
import 'package:spotify/data/repositories/otp/otp_repo_impl.dart';
import 'package:spotify/data/sources/auth/auth_supabase_servieces.dart';
import 'package:spotify/data/sources/audd/audd_data_source.dart';
import 'package:spotify/data/sources/audiodb/audiodb_data_source.dart';
import 'package:spotify/data/sources/chosic/chosic_data_source.dart';
import 'package:spotify/data/sources/deezer/deezer_data_source.dart';
import 'package:spotify/data/sources/lastfm/lastfm_data_source.dart';
import 'package:spotify/data/sources/lyrics/lyrics_data_source.dart';
import 'package:spotify/data/sources/music_iwant/music_iwant_data_source.dart';
import 'package:spotify/data/sources/musicbrainz/musicbrainz_data_source.dart';
import 'package:spotify/data/sources/verome/verome_data_source.dart';
import 'package:spotify/data/sources/wolfxspotify/wolfxspotify_data_source.dart';
import 'package:spotify/domain/repositories/auth/auth_repo.dart';
import 'package:spotify/domain/repositories/lyrics/lyrics_repo.dart';
import 'package:spotify/domain/repositories/otp/otp_repo.dart';
import 'package:spotify/domain/usecase/auth/sighnup_usecase.dart';
import 'package:spotify/domain/usecase/otp/otp_usecase.dart';
import 'package:spotify/domain/usecase/songs/get_charts_usecase.dart';
import 'package:spotify/domain/usecase/songs/get_songs_usecase.dart';
import 'package:spotify/domain/usecase/songs/search_songs_usecase.dart';
import 'package:spotify/presentation/DownloadedSongs/cubit/download_songs_for_offline_cubit.dart';
import 'package:spotify/presentation/Home/cubit/charts/charts_cubit.dart';
import 'package:spotify/presentation/Home/cubit/recently_played/recently_played_cubit.dart';
import 'package:spotify/presentation/LikedSongs/cubit/favourite_songs_cubit.dart';
import 'package:spotify/presentation/MainWrapper/cubit/cubit/navigation_cubit.dart';
import 'package:spotify/presentation/SearchPage/cubit/cubit/search_songs_cubit.dart';
import 'package:spotify/presentation/songsPlayPage/cubit/lyrics/lyrics_cubit.dart';
import 'package:spotify/presentation/songsPlayPage/cubit/song_player_cubit.dart';

import 'data/sources/songs/get_songs_supabase_servieces.dart';
import 'domain/usecase/auth/signin_usecase.dart';

final getIt = GetIt.instance;
Future<void> intializedDependences() async {
  // Auth
  getIt.registerSingleton<AuthSupabaseServieces>(AuthSupabaseServiecesImpl());
  getIt.registerSingleton<AuthRepo>(AuthRepoImpl());
  getIt.registerSingleton<SighnupUsecase>(SighnupUsecase());
  getIt.registerSingleton<SigninUsecase>(SigninUsecase());

  // OTP
  getIt.registerSingleton<OtpRepository>(OtpRepositoryImpl());
  getIt.registerSingleton<SendOtpUsecase>(SendOtpUsecase());
  getIt.registerSingleton<VerifyOtpUsecase>(VerifyOtpUsecase());

  // Songs (legacy)
  getIt.registerSingleton<SongsSupabaseServieces>(SongsSupabaseServiecesimpl());
  getIt.registerSingleton<GetSongsUsecase>(GetSongsUsecase());

  // Lyrics
  getIt.registerSingleton<LyricsDataSource>(LyricsDataSourceImpl());
  getIt.registerSingleton<LyricsRepository>(LyricsRepositoryImpl());

  // Deezer
  getIt.registerSingleton<DeezerDataSource>(DeezerDataSourceImpl());
  getIt.registerSingleton<SearchSongsUsecase>(SearchSongsUsecase());
  getIt.registerSingleton<GetChartsUsecase>(GetChartsUsecase());

  // TheAudioDB
  getIt.registerSingleton<AudioDbDataSource>(AudioDbDataSourceImpl());

  // wolfXspotify
  getIt.registerSingleton<WolfXSpotifyDataSource>(WolfXSpotifyDataSourceImpl());

  // Last.fm
  getIt.registerSingleton<LastFmDataSource>(LastFmDataSourceImpl());

  // Music I Want
  getIt.registerSingleton<MusicIWantDataSource>(MusicIWantDataSourceImpl());

  // AudD
  getIt.registerSingleton<AuddDataSource>(AuddDataSourceImpl());

  // Verome
  getIt.registerSingleton<VeromeDataSource>(VeromeDataSourceImpl());

  // Chosic
  getIt.registerSingleton<ChosicDataSource>(ChosicDataSourceImpl());

  // MusicBrainz
  getIt.registerSingleton<MusicBrainzDataSource>(MusicBrainzDataSourceImpl());

  // Cubits
  getIt.registerLazySingleton<SongPlayerCubit>(() => SongPlayerCubit());
  getIt.registerLazySingleton<FavouriteSongsCubit>(() => FavouriteSongsCubit()..fetchFavourites());
  getIt.registerLazySingleton<DownloadSongsForOfflineCubit>(() => DownloadSongsForOfflineCubit());
  getIt.registerLazySingleton<NavigationCubit>(() => NavigationCubit());
  getIt.registerLazySingleton<SearchSongsCubit>(() => SearchSongsCubit());
  getIt.registerLazySingleton<LyricsCubit>(() => LyricsCubit());
  getIt.registerLazySingleton<RecentlyPlayedCubit>(() => RecentlyPlayedCubit());
  getIt.registerLazySingleton<ChartsCubit>(() => ChartsCubit());

  getIt<SongPlayerCubit>().onSongPlayed = (song) => getIt<RecentlyPlayedCubit>().addSong(song);
}
