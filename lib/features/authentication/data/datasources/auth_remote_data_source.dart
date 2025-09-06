import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phoneNumber);
  Future<AuthSessionModel> verifyOtp(String phoneNumber, String otp);
  Future<AuthSessionModel?> getCurrentSession();
  Future<void> signOut();
  Future<AuthSessionModel> refreshToken(String refreshToken);
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? profilePicture,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await supabaseClient.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: true,
      );
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<AuthSessionModel> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await supabaseClient.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.sms,
      );

      if (response.session == null) {
        throw const AuthenticationException(message: 'Invalid OTP or session expired');
      }

      return AuthSessionModel(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken ?? '',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          response.session!.expiresAt! * 1000,
        ),
        user: UserModel.fromJson(response.user!.toJson()),
      );
    } on AuthException catch (e) {
      if (e.message.contains('invalid') || e.message.contains('expired')) {
        throw InvalidOtpException(message: e.message);
      }
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to verify OTP: ${e.toString()}');
    }
  }

  @override
  Future<AuthSessionModel?> getCurrentSession() async {
    try {
      final session = supabaseClient.auth.currentSession;
      
      if (session == null) {
        return null;
      }

      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return null;
      }

      return AuthSessionModel(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          session.expiresAt! * 1000,
        ),
        user: UserModel.fromJson(user.toJson()),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to get current session: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<AuthSessionModel> refreshToken(String refreshToken) async {
    try {
      final response = await supabaseClient.auth.refreshSession();
      
      if (response.session == null) {
        throw const AuthenticationException(message: 'Failed to refresh token');
      }

      return AuthSessionModel(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken ?? '',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          response.session!.expiresAt! * 1000,
        ),
        user: UserModel.fromJson(response.user!.toJson()),
      );
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to refresh token: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      
      if (user == null) {
        return null;
      }

      return UserModel.fromJson(user.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? profilePicture,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (email != null) {
        updates['email'] = email;
      }
      
      final userMetadata = <String, dynamic>{};
      if (name != null) {
        userMetadata['name'] = name;
      }
      if (profilePicture != null) {
        userMetadata['profile_picture'] = profilePicture;
      }
      
      if (userMetadata.isNotEmpty) {
        updates['data'] = userMetadata;
      }

      final response = await supabaseClient.auth.updateUser(
        UserAttributes(
          email: email,
          data: userMetadata.isNotEmpty ? userMetadata : null,
        ),
      );

      if (response.user == null) {
        throw const AuthenticationException(message: 'Failed to update profile');
      }

      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to update profile: ${e.toString()}');
    }
  }
}
