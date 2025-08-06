import 'package:chat_app/core/error/exeception.dart';
import 'package:chat_app/features/auth/data/model/signUp_request.dart';
import 'package:chat_app/features/auth/data/model/user_model.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class AuthRemoteDataSource {
  Future<String> login(String email, String password);
  Future<String> signUp(SignUpRequest request); 
  Future<User> getCurrentUser(String token);
}


// lib/data/datasources/remote/auth_remote_data_source_impl.dart

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  static const String _baseUrl = 'https://g5-flutter-learning-path-be.onrender.com/api/v2';

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<String> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _parseAuthResponse(response);
  }

  @override
  Future<String> signUp(SignUpRequest signUp) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': signUp.name,
        'email': signUp.email,
        'password': signUp.password,
      }),
    );

    return _parseAuthResponse(response);
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return _parseUserResponse(response);
  }

  // Helper Methods
  String _parseAuthResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (statusCode == 200 || statusCode == 201) {
      return body['data']['access_token'] as String;
    } else {
      throw AuthException(body['message'] as String? ?? 'Authentication failed');
    }
  }

  UserModel _parseUserResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (statusCode == 200) {
      return UserModel.fromJson(body['data']);
    } else {
      throw AuthException(body['message'] as String? ?? 'Failed to fetch user');
    }
  }
}