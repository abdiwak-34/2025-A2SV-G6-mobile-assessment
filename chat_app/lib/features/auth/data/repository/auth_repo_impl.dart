// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:chat_app/core/error/exeception.dart';
import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/network_info.dart' show NetworkInfo;
import 'package:chat_app/features/auth/data/datasources/local_data_sources.dart';
import 'package:chat_app/features/auth/data/datasources/remote_datasource.dart';
import 'package:chat_app/features/auth/data/model/signUp_request.dart';
import 'package:chat_app/features/auth/data/model/user_model.dart';
import 'package:chat_app/features/auth/domain/entities/login_entity.dart';
import 'package:chat_app/features/auth/domain/entities/signup_entity.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getCurrentUser(String token) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final user = await remoteDataSource.getCurrentUser(token);
      final userModel = UserModel(id: user.id, name: user.name, email: user.email);
      await localDataSource.cacheCurrentUser(userModel);
      return Right(userModel);
    } on AuthException catch (e) {
      return Left(AuthFailure('Authentication failed: ${e.toString()}'));
    } catch (e) {
      print('Unexpected getCurrentUser error: $e');
      return Left(ServerFailure('Failed to get user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> login(LoginData data) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('network failure'));
    }

    try {
      final token = await remoteDataSource.login(data.email, data.password);
      final user = await remoteDataSource.getCurrentUser(token);
      final userModel = UserModel(id: user.id, name: user.name, email: user.email);

      await Future.wait([
        localDataSource.cacheAccessToken(token),
        localDataSource.cacheCurrentUser(userModel),
      ]);

      return Right(token);
    } on AuthException catch (e) {
      return Left(AuthFailure('Authentication failed: ${e.toString()}'));
    } on ServerExceptions catch (e) {
      return Left(ServerFailure('Server error: ${e.toString()}'));
    } catch (e) {
      print('Unexpected login error: $e');
      return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signUp(SignupData data) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('network failed'));
    }

    try {
      final signUpRequest = SignUpRequest(
        name: data.name,
        email: data.email,
        password: data.password,
      );

      final user = await remoteDataSource.signUp(signUpRequest);
      
      final userModel = UserModel(id: user.id, name: user.name, email: user.email);

      await Future.wait([
        localDataSource.cacheCurrentUser(userModel),
      ]);

      return Right(user);
    } on AuthException {
      return Left(AuthFailure('you dont have access credential'));
    } catch (e) {
      return Left(ServerFailure('what ???'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {

    await Future.wait([
      localDataSource.clearTokens(),
      localDataSource.clearUserData(),
    ]);

    return const Right(unit);
  }
}