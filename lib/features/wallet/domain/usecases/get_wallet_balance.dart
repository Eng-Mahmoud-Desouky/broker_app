import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

class GetWalletBalance implements UseCase<Wallet, GetWalletBalanceParams> {
  final WalletRepository repository;

  GetWalletBalance(this.repository);

  @override
  Future<Either<Failure, Wallet>> call(GetWalletBalanceParams params) async {
    return await repository.getWalletBalance(params.userId);
  }
}

class GetWalletBalanceParams extends Equatable {
  final String userId;

  const GetWalletBalanceParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
