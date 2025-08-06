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
  Future<Either<Failure, User>> getCurrentUser(String id) async {
    try {

      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null && cachedUser.id == id) {
        return Right(cachedUser);
      }

      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('network failure'));
      }

      final token = await localDataSource.getCachedAccessToken();
      if (token == null) return Left(CacheFailure('cache failure'));

      final user = await remoteDataSource.getCurrentUser(token);
      final userModel = UserModel(id: user.id, name: user.name, email: user.email);
      await localDataSource.cacheCurrentUser(userModel);
      return Right(userModel);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('server failed'));
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
    } on AuthException {
      return Left(AuthFailure('authentication error'));
    } on ServerExceptions {
      return Left(ServerFailure('server failed'));
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

      final token = await remoteDataSource.signUp(signUpRequest);
      final user = await remoteDataSource.getCurrentUser(token);
      final userModel = UserModel(id: user.id, name: user.name, email: user.email);

      await Future.wait([
        localDataSource.cacheAccessToken(token),
        localDataSource.cacheCurrentUser(userModel),
      ]);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('server failed'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout(String token) async {

    final isConnected = await networkInfo.isConnected;
    if (isConnected && token.isNotEmpty) {
      try {
        await localDataSource.clearTokens();
        await localDataSource.clearUserData();
      } on CacheExceptions {
        return left(CacheFailure('cache failed'));
      }
    }

    await Future.wait([
      localDataSource.clearTokens(),
      localDataSource.clearUserData(),
    ]);

    return const Right(unit);
  }
}