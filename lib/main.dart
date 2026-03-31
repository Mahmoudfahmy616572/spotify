import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/core/config/theme/app_theme.dart';
import 'package:spotify/presentation/DownloadedSongs/cubit/download_songs_for_offline_cubit.dart';
import 'package:spotify/presentation/MainWrapper/cubit/cubit/navigation_cubit.dart';
import 'package:spotify/presentation/SearchPage/cubit/cubit/search_songs_cubit.dart';
import 'package:spotify/presentation/chooseMode/bloc/theme_cubit.dart';
import 'package:spotify/presentation/songsPlayPage/cubit/song_player_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/LikedSongs/cubit/favourite_songs_cubit.dart'
    show FavouriteSongsCubit;
import 'presentation/splash/splash_screen.dart';
import 'serviece_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('offline_songs');
  await Hive.openBox('songs_metadata');

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  await Supabase.initialize(
    url: 'https://nmwxcvzanmtlbfupraki.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5td3hjdnphbm10bGJmdXByYWtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjczNTIyMzEsImV4cCI6MjA4MjkyODIzMX0.TWKHC5BJdZh5YahxuekQjbt2lfUR4ogQSNj99SsSRK0',
  );

  await intializedDependences();
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => SongPlayerCubit()),
        BlocProvider(create: (_) => FavouriteSongsCubit()..fetchFavourits()),
        BlocProvider(create: (_) => DownloadSongsForOfflineCubit()),
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(create: (_) => SearchSongsCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, state) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: state,
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
