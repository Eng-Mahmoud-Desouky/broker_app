part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class WalletLoadRequested extends WalletEvent {
  final String userId;

  const WalletLoadRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class WalletRefreshRequested extends WalletEvent {
  final String userId;

  const WalletRefreshRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class WalletTransactionHistoryRequested extends WalletEvent {
  final String userId;
  final int? limit;
  final int? offset;

  const WalletTransactionHistoryRequested({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}

class WalletTopUpRequested extends WalletEvent {
  final String userId;
  final int amount; // Amount in fils

  const WalletTopUpRequested({
    required this.userId,
    required this.amount,
  });

  @override
  List<Object> get props => [userId, amount];
}

class WalletTransactionStatusChecked extends WalletEvent {
  final String transactionId;

  const WalletTransactionStatusChecked({required this.transactionId});

  @override
  List<Object> get props => [transactionId];
}

class WalletRealTimeUpdatesStarted extends WalletEvent {
  final String userId;

  const WalletRealTimeUpdatesStarted({required this.userId});

  @override
  List<Object> get props => [userId];
}

class WalletRealTimeUpdatesStopped extends WalletEvent {}

class WalletBalanceUpdated extends WalletEvent {
  final Wallet wallet;

  const WalletBalanceUpdated({required this.wallet});

  @override
  List<Object> get props => [wallet];
}

class WalletTransactionsUpdated extends WalletEvent {
  final List<WalletTransaction> transactions;

  const WalletTransactionsUpdated({required this.transactions});

  @override
  List<Object> get props => [transactions];
}
