import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_transaction.dart';
import '../repositories/wallet_repository.dart';

class GetTransactionHistory implements UseCase<List<WalletTransaction>, GetTransactionHistoryParams> {
  final WalletRepository repository;

  GetTransactionHistory(this.repository);

  @override
  Future<Either<Failure, List<WalletTransaction>>> call(GetTransactionHistoryParams params) async {
    return await repository.getTransactionHistory(
      params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetTransactionHistoryParams extends Equatable {
  final String userId;
  final int? limit;
  final int? offset;

  const GetTransactionHistoryParams({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}
