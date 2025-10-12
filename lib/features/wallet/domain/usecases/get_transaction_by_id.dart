import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_transaction.dart';
import '../repositories/wallet_repository.dart';

class GetTransactionById implements UseCase<WalletTransaction, GetTransactionByIdParams> {
  final WalletRepository repository;

  GetTransactionById(this.repository);

  @override
  Future<Either<Failure, WalletTransaction>> call(GetTransactionByIdParams params) async {
    return await repository.getTransactionById(params.transactionId);
  }
}

class GetTransactionByIdParams extends Equatable {
  final String transactionId;

  const GetTransactionByIdParams({required this.transactionId});

  @override
  List<Object> get props => [transactionId];
}
