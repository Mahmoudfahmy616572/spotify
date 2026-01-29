import 'package:dartz/dartz.dart';
import 'package:spotify/data/models/auth/create_user_req.dart';
import 'package:spotify/data/models/auth/signin_req.dart';

abstract class AuthRepo {
  Future<Either> signUp(CreateUserReq createUserReq);
  Future<Either> signIn(SigninReq signinReq);
}
