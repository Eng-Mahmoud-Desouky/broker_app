import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wallet_repository.dart';

class CancelTopUpSession implements UseCase<void, CancelTopUpSessionParams> {
  final WalletRepository repository;

  CancelTopUpSession(this.repository);

  @override
  Future<Either<Failure, void>> call(CancelTopUpSessionParams params) async {
    return await repository.cancelTopUpSession(params.transactionId);
  }
}

class CancelTopUpSessionParams extends Equatable {
  final String transactionId;

  const CancelTopUpSessionParams({required this.transactionId});

  @override
  List<Object> get props => [transactionId];
}
