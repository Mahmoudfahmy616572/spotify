import 'package:dartz/dartz.dart';
import 'package:spotify/data/sources/auth_firebase_servieces.dart';
import 'package:spotify/domain/repository/auth/auth_repository.dart';
import 'package:spotify/serviece_locator.dart';

class AuthRepoImp implements AuthRepository {
  @override
  Future<Either> signIn(userLogedReq) async {
   return await getIt<AuthFirebaseServieces>().signIn(userLogedReq);
  }

  @override
  Future<Either> signUp(createuserReq) async {
    return await getIt<AuthFirebaseServieces>().signUp(createuserReq);
  }
}
