import 'package:chat_app/features/auth/data/model/user_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {

  Future<void> cacheCurrentUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUserData();

  Future<void> cacheAccessToken(String token);
  Future<String?> getCachedAccessToken();
  Future<void> clearTokens();
}


class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _userKey = 'cached_user';
  static const _tokenKey = 'auth_token';

  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheCurrentUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await sharedPreferences.setString(_userKey, userJson);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = sharedPreferences.getString(_userKey);
    if (userJson == null) return null;
    
    try {
      return UserModel.fromJson(json.decode(userJson));
    } catch (_) {
      await clearUserData();
      return null;
    }
  }

  @override
  Future<void> clearUserData() async {
    await sharedPreferences.remove(_userKey);
  }

  @override
  Future<void> cacheAccessToken(String token) async {
    await sharedPreferences.setString(_tokenKey, token);
  }

  @override
  Future<String?> getCachedAccessToken() async {
    return sharedPreferences.getString(_tokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await sharedPreferences.remove(_tokenKey);
  }
}