import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wallet_repository.dart';

class CreateTopUpTransaction implements UseCase<Map<String, dynamic>, CreateTopUpTransactionParams> {
  final WalletRepository repository;

  CreateTopUpTransaction(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(CreateTopUpTransactionParams params) async {
    return await repository.createTopUpTransaction(
      userId: params.userId,
      amount: params.amount,
    );
  }
}

class CreateTopUpTransactionParams extends Equatable {
  final String userId;
  final int amount; // Amount in fils

  const CreateTopUpTransactionParams({
    required this.userId,
    required this.amount,
  });

  @override
  List<Object> get props => [userId, amount];
}
