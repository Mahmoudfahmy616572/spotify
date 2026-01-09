import 'package:dartz/dartz.dart';
import 'package:spotify/core/usecase/usecase.dart';
import 'package:spotify/data/models/auth/create_user_req.dart';
import 'package:spotify/domain/repository/auth/auth_repository.dart';

import '../../../serviece_locator.dart';

class SignUpUsecase implements Usecase<Either, CreateUserReq> {
  @override
  Future<Either> call({CreateUserReq? param}) async {
   return await getIt<AuthRepository>().signUp(param!);
  }
}
