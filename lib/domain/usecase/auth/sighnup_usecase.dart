import 'package:dartz/dartz.dart';
import 'package:spotify/core/usecase/usecase.dart';
import 'package:spotify/data/models/auth/create_user_req.dart';
import 'package:spotify/domain/repositories/auth/auth_repo.dart';
import 'package:spotify/serviece_locator.dart';

class SighnupUsecase implements Usecase<Either, CreateUserReq> {
  @override
  Future<Either> call({CreateUserReq? param}) {
    if (param == null) {
      return Future.value(const Left("Missing registration data."));
    }
    return getIt<AuthRepo>().signUp(param);
  }
}
