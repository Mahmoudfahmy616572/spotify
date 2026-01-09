import 'package:dartz/dartz.dart';
import 'package:spotify/data/models/auth/user_loged_req.dart';

import '../../../data/models/auth/create_user_req.dart';

abstract class AuthRepository {
  Future<Either> signUp(CreateUserReq createUserReq);
  Future<Either> signIn(UserLogedReq userLogedReq);
}
