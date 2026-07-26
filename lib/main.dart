import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/core/config/theme/app_theme.dart';
import 'package:spotify/presentation/DownloadedSongs/cubit/download_songs_for_offline_cubit.dart';
import 'package:spotify/presentation/Home/cubit/recently_played/recently_played_cubit.dart';
import 'package:spotify/presentation/MainWrapper/cubit/cubit/navigation_cubit.dart';
import 'package:spotify/presentation/SearchPage/cubit/cubit/search_songs_cubit.dart';
import 'package:spotify/presentation/songsPlayPage/cubit/lyrics/lyrics_cubit.dart';
import 'package:spotify/presentation/songsPlayPage/cubit/song_player_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/LikedSongs/cubit/favourite_songs_cubit.dart'
    show FavouriteSongsCubit;
import 'presentation/splash/splash_screen.dart';
import 'serviece_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Hive.initFlutter();
  await Hive.openBox('offline_songs');
  await Hive.openBox('songs_metadata');
  await Hive.openBox('user_session');
  await Hive.openBox('recently_played');

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  await intializedDependences();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<SongPlayerCubit>()),
        BlocProvider.value(value: getIt<FavouriteSongsCubit>()),
        BlocProvider.value(value: getIt<DownloadSongsForOfflineCubit>()),
        BlocProvider.value(value: getIt<NavigationCubit>()),
        BlocProvider.value(value: getIt<SearchSongsCubit>()),
        BlocProvider.value(value: getIt<LyricsCubit>()),
        BlocProvider.value(value: getIt<RecentlyPlayedCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
