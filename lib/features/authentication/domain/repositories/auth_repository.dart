import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_session.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Send OTP to the provided phone number
  Future<Either<Failure, void>> sendOtp(String phoneNumber);

  /// Verify OTP and return authentication session
  Future<Either<Failure, AuthSession>> verifyOtp(
    String phoneNumber,
    String otp,
  );

  /// Get current authentication session
  Future<Either<Failure, AuthSession?>> getCurrentSession();

  /// Sign out the current user
  Future<Either<Failure, void>> signOut();

  /// Refresh the authentication token
  Future<Either<Failure, AuthSession>> refreshToken(String refreshToken);

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? email,
    String? profilePicture,
    String? governorate,
    String? district,
  });

  /// Bypass OTP verification for development/testing purposes
  /// Creates a mock session without actual OTP verification
  Future<Either<Failure, AuthSession>> bypassOtpVerification(
    String phoneNumber,
  );
}
