import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/auth/domain/entities/login_entity.dart';
import 'package:chat_app/features/auth/domain/entities/signup_entity.dart';
import 'package:chat_app/features/auth/domain/entities/token_entity.dart';
import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';
abstract class AuthRepository {
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> signUp(SignupData data);
  Future<Either<Failure, String>> login(LoginData data);
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, List<User>>> getUsers();
}
