import 'package:get_it/get_it.dart';
import 'package:spotify/data/sources/auth_firebase_servieces.dart';
import 'package:spotify/domain/repository/auth/auth_repository.dart';
import 'package:spotify/domain/usecase/auth/sign_up_usecase.dart';
import 'package:spotify/domain/usecase/auth/signin_usecase.dart';

import 'data/repository/auth/auth_repo_imp.dart';

final getIt = GetIt.instance;
Future<void> intializedDependences() async {
  getIt.registerSingleton<AuthFirebaseServieces>(AuthFirebaseServiecesIpml());
  getIt.registerSingleton<AuthRepository>(AuthRepoImp());
  getIt.registerSingleton<SignUpUsecase>(SignUpUsecase());
  getIt.registerSingleton<SigninUsecase>(SigninUsecase());
}
