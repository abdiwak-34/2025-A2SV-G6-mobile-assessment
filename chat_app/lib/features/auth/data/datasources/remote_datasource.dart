import 'package:chat_app/core/error/exeception.dart';
import 'package:chat_app/features/auth/data/datasources/local_data_sources.dart';
import 'package:chat_app/features/auth/data/model/signUp_request.dart';
import 'package:chat_app/features/auth/data/model/user_model.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class AuthRemoteDataSource {
  Future<String> login(String email, String password);
  Future<UserModel> signUp(SignUpRequest request); 
  Future<User> getCurrentUser();
  Future<List<UserModel>> getUsers();
}


class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthLocalDataSource localDataSource;
  final http.Client client;
  static const String _baseUrl = 'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v3/';

  AuthRemoteDataSourceImpl(this.client, this.localDataSource);

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('${_baseUrl}auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      final token = _parseAuthResponse(response);

      if (token.isEmpty) {
        throw AuthException();
      }
      localDataSource.cacheAccessToken(token);
      return token;
      
    } catch (e) {
      print('Login error: $e');
      throw AuthException();
    }
  }

@override
Future<List<UserModel>> getUsers() async {
  final token = await localDataSource.getCachedAccessToken();
  if (token == null || token.isEmpty) {
    throw AuthException();
  }
  try {
    final response = await client.get(
      Uri.parse('${_baseUrl}users'),
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>;

      return data
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw AuthException();
    }
  } catch (e) {
    print('Get users error: $e');
    throw AuthException();
  }
}


  @override
  Future<UserModel> signUp(SignUpRequest signUp) async {
    try {
      final response = await client.post(
        Uri.parse('${_baseUrl}auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': signUp.name,
          'email': signUp.email,
          'password': signUp.password,
        }),
      );

      return _parseUserResponse(response);
    } catch (e) {
      print('SignUp error: $e');
      throw AuthException();
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final token = await localDataSource.getCachedAccessToken();
      if (token == null || token.isEmpty) {
        throw AuthException();
      }

      final response = await client.get(
        Uri.parse('${_baseUrl}users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _parseUserResponse(response);
    } catch (e) {
      print('Get current user error: $e');
      throw AuthException();
    }
  }

  String _parseAuthResponse(http.Response response) {
    final statusCode = response.statusCode;
    final rawBody = response.body.trim();

    if (statusCode == 200 || statusCode == 201) {
      if (rawBody.isEmpty) {
        throw Exception("Empty response body on success status");
      }

      final body = jsonDecode(rawBody) as Map<String, dynamic>;
      print(body);

      if (body['data'] == null || body['data']['access_token'] == null) {
        throw Exception("No access token in response");
      }

      return body['data']['access_token'] as String;
    } else {
      throw AuthException();
    }
  }


  UserModel _parseUserResponse(http.Response response) {
    final statusCode = response.statusCode;
    print('Response status code: $statusCode');
    print('Response body: ${response.body}');
    
    if (response.body.isEmpty) {
      throw AuthException();
    }
    
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (statusCode == 200 || statusCode == 201) {
      if (body['data'] != null) {
        return UserModel.fromJson(body['data']);
      } else {
        throw AuthException();
      }
    } else {
      print('Error response: ${body['message'] ?? 'Unknown error'}');
      throw AuthException();
    }
  }
}