import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify/data/models/auth/create_user_req.dart';

import '../models/auth/user_loged_req.dart';

abstract class AuthFirebaseServieces {
  Future<Either> signUp(CreateUserReq createUserReq);
  Future<Either> signIn(UserLogedReq userLogedReq);
}

class AuthFirebaseServiecesIpml implements AuthFirebaseServieces {
  @override
  Future<Either> signIn(userLogedReq) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userLogedReq.email, password: userLogedReq.password);
      return const Right("You are login Successfully");
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'user-not-found') {
        // print('No user found for that email.');
        message = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        // print('Wrong password provided for that user.');
        message = "Wrong password provided for that user.";
      }
      return Left(message);
    } catch (e) {
      // print(e);
      return Left(e);
    }
  }

  @override
  Future<Either> signUp(createUserReq) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password,
      );
      return const Right("User Register Successfully");
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        // print('The password provided is too weak.');
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        // print('The account already exists for that email.');
        message = 'The account already exists for that email.';
      }
      return Left(message);
    } catch (e) {
      // print(e);
      return Left(e);
    }
  }
}
