import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wallet.dart';
import '../entities/wallet_transaction.dart';

abstract class WalletRepository {
  /// Get user's wallet balance
  Future<Either<Failure, Wallet>> getWalletBalance(String userId);

  /// Get user's transaction history
  Future<Either<Failure, List<WalletTransaction>>> getTransactionHistory(
    String userId, {
    int? limit,
    int? offset,
  });

  /// Create a top-up transaction and get payment session
  Future<Either<Failure, Map<String, dynamic>>> createTopUpSession({
    required String userId,
    required double amount, // Amount in Iraqi Dinars (IQD)
  });

  /// Get transaction by ID
  Future<Either<Failure, WalletTransaction>> getTransactionById(
    String transactionId,
  );

  /// Stream wallet balance changes
  Stream<Either<Failure, Wallet>> watchWalletBalance(String userId);

  /// Stream transaction history changes
  Stream<Either<Failure, List<WalletTransaction>>> watchTransactionHistory(
    String userId,
  );

  /// Deduct balance from wallet
  Future<Either<Failure, void>> deductBalance({
    required String userId,
    required double amount,
    required String orderId,
  });

  /// Cancel a top-up session
  Future<Either<Failure, void>> cancelTopUpSession(String transactionId);
}
