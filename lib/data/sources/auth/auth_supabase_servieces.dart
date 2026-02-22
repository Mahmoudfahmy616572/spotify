import 'package:dartz/dartz.dart';
import 'package:spotify/data/models/auth/create_user_req.dart';
import 'package:spotify/data/models/auth/signin_req.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';

abstract class AuthSupabaseServieces {
  Future<Either> signUp(CreateUserReq createUserReq);
  Future<Either> signIn(SigninReq signinReq);
}

class AuthSupabaseServiecesImpl implements AuthSupabaseServieces {
  @override
  Future<Either> signUp(createUserReq) async {
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: createUserReq.email,
        password: createUserReq.password,
        // You can add additional user metadata if needed
        data: {'Full_name': createUserReq.username},
      );

      await Supabase.instance.client.from('Users').insert(
        {
          'username': res.user?.userMetadata?["Full_name"],
          'email': res.user?.email,
        },
      );

      // The user and session are available in the response
      final User? user = res.user;
      // final Session? session = res.session;

      if (user != null) {
        return const Right(
            "Account Created! Check your email for verification if enabled.");
      }
    } on AuthException catch (e) {
      if (e.code == 'email_exists') {
        // This only triggers if Email Confirmation is DISABLED in dashboard
        return const Left('This email is already registered. Please log in.');
      } else {
        return Left(e.message);
      }
      // );
    } catch (e) {
      return left("An unexpected error occurred: $e");
    }
    return left("error");
  }

  @override
  Future<Either> signIn(signinReq) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: signinReq.email,
        password: signinReq.password,
      );

      if (res.user != null) {
        // print('Login successful: ${res.user!.email}');
        return Right('Login successful: ${res.user!.email}');
      }
    } on AuthException catch (error) {
      if (error.code == 'invalid_credentials') {
        // This only triggers if Email Confirmation is DISABLED in dashboard
        return const Left('Wrong email or password.');
      } else if (error.code == 'email_not_confirmed') {
        return const Left('Please verify your email before logging in.');
      } else if (error.code == 'too_many_requests') {
        return const Left('Too many attempts. Please wait a moment.');
      } else {
        return Left('Login failed:${error.message}');
      }
    }
    return const Left("Unknown Error");
  }
}
