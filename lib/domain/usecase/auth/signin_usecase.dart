import 'package:dartz/dartz.dart';
import 'package:spotify/core/usecase/usecase.dart';
import 'package:spotify/data/models/auth/user_loged_req.dart';
import 'package:spotify/domain/repository/auth/auth_repository.dart';
import 'package:spotify/serviece_locator.dart';

class SigninUsecase implements Usecase<Either, UserLogedReq> {
  @override
  Future<Either> call({UserLogedReq? param}) {
    return getIt<AuthRepository>().signIn(param!);
  }
}
