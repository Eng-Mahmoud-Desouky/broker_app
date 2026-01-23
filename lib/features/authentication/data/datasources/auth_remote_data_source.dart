import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
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
    String? governorate,
    String? district,
  });

  /// Bypass OTP verification for development/testing purposes
  Future<AuthSessionModel> bypassOtpVerification(String phoneNumber);

  /// Fetch user profile from 'profiles' table
  Future<UserModel?> getProfile(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> sendOtp(String phoneNumber) async {
    try {
      print('\n📞 ===== Supabase sendOtp =====');
      print('📞 Sending OTP to: $phoneNumber');

      await supabaseClient.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: true,
      );

      print('✅ OTP sent successfully');
      print('==============================\n');
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      print('==============================\n');

      // Provide user-friendly error messages in Arabic
      String userMessage = e.message;

      if (e.message.contains('rate limit') ||
          e.message.contains('you can only request this after')) {
        userMessage =
            'يرجى الانتظار قليلاً قبل طلب رمز تحقق جديد. حاول مرة أخرى بعد دقيقة.';
      } else if (e.message.contains('invalid phone number')) {
        userMessage =
            'رقم الهاتف غير صحيح. يرجى التحقق من الرقم والمحاولة مرة أخرى.';
      } else if (e.message.contains('Phone provider not configured')) {
        userMessage =
            'خدمة إرسال الرسائل غير متاحة حالياً. يرجى المحاولة لاحقاً.';
      }

      throw AuthenticationException(message: userMessage);
    } catch (e) {
      print('❌ Exception: ${e.toString()}');
      print('==============================\n');
      throw ServerException(
        message:
            'فشل إرسال رمز التحقق. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
      );
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
        throw const AuthenticationException(
          message: 'Invalid OTP or session expired',
        );
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
      throw CacheException(
        message: 'Failed to get current session: ${e.toString()}',
      );
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
      throw ServerException(
        message: 'Failed to refresh token: ${e.toString()}',
      );
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
      throw CacheException(
        message: 'Failed to get current user: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? profilePicture,
    String? governorate,
    String? district,
  }) async {
    try {
      // Check if we have a current session
      final currentSession = supabaseClient.auth.currentSession;
      final currentUser = supabaseClient.auth.currentUser;

      // If no session (development mode with mock user), create a mock updated user
      if (currentSession == null || currentUser == null) {
        // This handles the development mode case where we have a mock session
        // Create a mock updated user with the provided data
        final mockUser = UserModel(
          id: 'dev_user_mock', // Use a consistent ID for development
          phoneNumber: '+9647700000000', // Default phone for development
          email: email,
          name: name,
          profilePicture: profilePicture,
          governorate: governorate,
          district: district,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
          isVerified: true,
        );

        return mockUser;
      }

      // Normal Supabase update for authenticated users
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
      if (governorate != null) {
        userMetadata['governorate'] = governorate;
      }
      if (district != null) {
        userMetadata['district'] = district;
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
        throw const AuthenticationException(
          message: 'Failed to update profile',
        );
      }

      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw ServerException(
        message: 'Failed to update profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthSessionModel> bypassOtpVerification(String phoneNumber) async {
    try {
      // CRITICAL: This should NEVER be called in production
      // This method is only for development/testing purposes
      assert(
        AppConfig.isDevelopment && AppConfig.bypassOtpInDevelopment,
        'Bypass OTP should only be used in development mode',
      );

      // Double-check production environment
      if (!AppConfig.isDevelopment || !AppConfig.bypassOtpInDevelopment) {
        throw const AuthenticationException(
          message: 'Bypass OTP is not allowed in production environment',
        );
      }

      // Create a mock user for development/testing purposes
      // This bypasses the actual Supabase OTP verification

      // Generate a mock session with the phone number
      final mockUser = UserModel(
        id: 'dev_user_${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}',
        phoneNumber: phoneNumber,
        email: null,
        name: null,
        profilePicture: null,
        governorate: null,
        district: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: true, // Mark as verified for development mode
      );

      // Create a mock session
      final mockSession = AuthSessionModel(
        accessToken:
            'dev_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'dev_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        user: mockUser,
      );

      return mockSession;
    } catch (e) {
      throw ServerException(
        message: 'Failed to bypass OTP verification: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel?> getProfile(String userId) async {
    try {
      final response =
          await supabaseClient
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      // Convert the profile data to a partial UserModel
      // Note: We need to combine this with the auth user data usually,
      // but here we are just returning the profile part
      return UserModel(
        id: userId,
        phoneNumber: '', // Will be filled from auth user
        email: response['email'],
        name: response['name'],
        profilePicture: response['profile_picture'],
        governorate: response['governorate'],
        district: response['district'],
        createdAt: DateTime.parse(response['created_at']),
        updatedAt:
            response['updated_at'] != null
                ? DateTime.parse(response['updated_at'])
                : null,
        isVerified: true, // Assumed if they have a profile
      );
    } catch (e) {
      print('❌ Error fetching profile: $e');
      // Return null instead of throwing to allow flow to continue without profile
      return null;
    }
  }
}
