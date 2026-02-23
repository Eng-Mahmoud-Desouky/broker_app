import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  WalletRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Wallet>> getWalletBalance(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final wallet = await remoteDataSource.getWalletBalance(userId);
        return Right(wallet);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, List<WalletTransaction>>> getTransactionHistory(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final transactions = await remoteDataSource.getTransactionHistory(
          userId,
          limit: limit,
          offset: offset,
        );
        return Right(transactions);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createTopUpTransaction({
    required String userId,
    required int amount,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.createTopUpTransaction(
          userId: userId,
          amount: amount,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, WalletTransaction>> getTransactionById(
    String transactionId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final transaction = await remoteDataSource.getTransactionById(
          transactionId,
        );
        return Right(transaction);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Stream<Either<Failure, Wallet>> watchWalletBalance(String userId) {
    return remoteDataSource
        .watchWalletBalance(userId)
        .map((wallet) => Right<Failure, Wallet>(wallet))
        .handleError((error) {
          if (error is ServerException) {
            return Left<Failure, Wallet>(ServerFailure(message: error.message));
          }
          return Left<Failure, Wallet>(
            ServerFailure(message: 'Unknown error: $error'),
          );
        });
  }

  @override
  Stream<Either<Failure, List<WalletTransaction>>> watchTransactionHistory(
    String userId,
  ) {
    return remoteDataSource
        .watchTransactionHistory(userId)
        .map(
          (transactions) =>
              Right<Failure, List<WalletTransaction>>(transactions),
        )
        .handleError((error) {
          if (error is ServerException) {
            return Left<Failure, List<WalletTransaction>>(
              ServerFailure(message: error.message),
            );
          }
          return Left<Failure, List<WalletTransaction>>(
            ServerFailure(message: 'Unknown error: $error'),
          );
        });
  }

  @override
  Future<Either<Failure, void>> deductBalance({
    required String userId,
    required double amount,
    required String orderId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deductBalance(
          userId: userId,
          amount: amount,
          orderId: orderId,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
  }
}
