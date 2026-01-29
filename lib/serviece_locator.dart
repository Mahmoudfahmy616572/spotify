import 'package:get_it/get_it.dart';
import 'package:spotify/data/repositories/auth/auth_repo_impl.dart';
import 'package:spotify/data/sources/auth/auth_supabase_servieces.dart';
import 'package:spotify/domain/repositories/auth/auth_repo.dart';
import 'package:spotify/domain/usecase/auth/sighnup_usecase.dart';

import 'data/sources/songs/get_songs_supabase_servieces.dart';
import 'domain/usecase/auth/signin_usecase.dart';

final getIt = GetIt.instance;
Future<void> intializedDependences() async {
  getIt.registerSingleton<AuthSupabaseServieces>(AuthSupabaseServiecesImpl());

  getIt.registerSingleton<AuthRepo>(
    AuthRepoImpl(),
  );

  getIt.registerSingleton<SighnupUsecase>(
    SighnupUsecase(),
  );
  getIt.registerSingleton<SigninUsecase>(
    SigninUsecase(),
  );
  getIt.registerSingleton<SongsSupabaseServieces>(
    SongsSupabaseServiecesimpl(),
  );
}
