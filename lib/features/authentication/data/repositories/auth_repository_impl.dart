import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

import '../models/user_model.dart';

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
  Future<Either<Failure, void>> sendOtp(String phoneNumber) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendOtp(phoneNumber);
        return const Right(null);
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> verifyOtp(
    String phoneNumber,
    String otp,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final session = await remoteDataSource.verifyOtp(phoneNumber, otp);

        // Cache the session and user locally
        await localDataSource.cacheSession(session);
        await localDataSource.cacheUser(session.user as UserModel);
        await localDataSource.setFirstTime(false);

        return Right(session);
      } on InvalidOtpException catch (e) {
        return Left(InvalidOtpFailure(message: e.message));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, AuthSession?>> getCurrentSession() async {
    try {
      // First try to get from remote (Supabase)
      if (await networkInfo.isConnected) {
        try {
          final remoteSession = await remoteDataSource.getCurrentSession();
          if (remoteSession != null) {
            // Update local cache
            await localDataSource.cacheSession(remoteSession);
            await localDataSource.cacheUser(remoteSession.user as UserModel);
            return Right(remoteSession);
          }
        } catch (e) {
          // If remote fails, try local cache
        }
      }

      // Fallback to local cache
      final localSession = await localDataSource.getCachedSession();
      return Right(localSession);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Clear local data first
      await localDataSource.clearSession();
      await localDataSource.clearUser();

      // Then try to sign out from remote if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.signOut();
        } catch (e) {
          // Ignore remote sign out errors since local is cleared
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> refreshToken(String refreshToken) async {
    if (await networkInfo.isConnected) {
      try {
        final session = await remoteDataSource.refreshToken(refreshToken);

        // Update local cache
        await localDataSource.cacheSession(session);
        await localDataSource.cacheUser(session.user as UserModel);

        return Right(session);
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final session = await getCurrentSession();
      return session.fold(
        (failure) => false,
        (session) => session != null && !session.isExpired,
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // First try to get from remote if connected
      if (await networkInfo.isConnected) {
        try {
          final remoteUser = await remoteDataSource.getCurrentUser();
          if (remoteUser != null) {
            // Update local cache
            await localDataSource.cacheUser(remoteUser);
            return Right(remoteUser);
          }
        } catch (e) {
          // If remote fails, try local cache
        }
      }

      // Fallback to local cache
      final localUser = await localDataSource.getCachedUser();
      return Right(localUser);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? email,
    String? profilePicture,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.updateProfile(
          name: name,
          email: email,
          profilePicture: profilePicture,
        );

        // Update local cache
        await localDataSource.cacheUser(user);

        return Right(user);
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
  }
}
