import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheSession(AuthSessionModel session);
  Future<AuthSessionModel?> getCachedSession();
  Future<void> clearSession();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  Future<bool> isFirstTime();
  Future<void> setFirstTime(bool isFirstTime);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheSession(AuthSessionModel session) async {
    try {
      final sessionJson = json.encode(session.toJson());
      await secureStorage.write(
        key: AppConstants.userTokenKey,
        value: sessionJson,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache session: ${e.toString()}');
    }
  }

  @override
  Future<AuthSessionModel?> getCachedSession() async {
    try {
      final sessionJson = await secureStorage.read(key: AppConstants.userTokenKey);
      
      if (sessionJson == null) {
        return null;
      }

      final sessionMap = json.decode(sessionJson) as Map<String, dynamic>;
      return AuthSessionModel.fromJson(sessionMap);
    } catch (e) {
      throw CacheException(message: 'Failed to get cached session: ${e.toString()}');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await secureStorage.delete(key: AppConstants.userTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear session: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await secureStorage.write(
        key: AppConstants.userDataKey,
        value: userJson,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = await secureStorage.read(key: AppConstants.userDataKey);
      
      if (userJson == null) {
        return null;
      }

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await secureStorage.delete(key: AppConstants.userDataKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear user: ${e.toString()}');
    }
  }

  @override
  Future<bool> isFirstTime() async {
    try {
      return sharedPreferences.getBool(AppConstants.isFirstTimeKey) ?? true;
    } catch (e) {
      throw CacheException(message: 'Failed to check first time: ${e.toString()}');
    }
  }

  @override
  Future<void> setFirstTime(bool isFirstTime) async {
    try {
      await sharedPreferences.setBool(AppConstants.isFirstTimeKey, isFirstTime);
    } catch (e) {
      throw CacheException(message: 'Failed to set first time: ${e.toString()}');
    }
  }
}
