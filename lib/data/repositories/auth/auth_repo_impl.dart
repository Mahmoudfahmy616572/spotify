import 'package:dartz/dartz.dart';
import 'package:spotify/data/sources/auth/auth_supabase_servieces.dart';
import 'package:spotify/domain/repositories/auth/auth_repo.dart';
import 'package:spotify/serviece_locator.dart';

class AuthRepoImpl implements AuthRepo {
  @override
  Future<Either> signIn(signinReq) async {
    return await getIt<AuthSupabaseServieces>().signIn(signinReq);
  }

  @override
  Future<Either> signUp(createUserReq) async {
    return await getIt<AuthSupabaseServieces>().signUp(createUserReq);
  }
}
