part of 'wallet_bloc.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final List<WalletTransaction> transactions;
  final bool isLoadingMore;

  const WalletLoaded({
    required this.wallet,
    required this.transactions,
    this.isLoadingMore = false,
  });

  @override
  List<Object> get props => [wallet, transactions, isLoadingMore];

  WalletLoaded copyWith({
    Wallet? wallet,
    List<WalletTransaction>? transactions,
    bool? isLoadingMore,
  }) {
    return WalletLoaded(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object> get props => [message];
}

class WalletTopUpLoading extends WalletState {
  final Wallet wallet;
  final List<WalletTransaction> transactions;

  const WalletTopUpLoading({
    required this.wallet,
    required this.transactions,
  });

  @override
  List<Object> get props => [wallet, transactions];
}

class WalletTopUpSessionCreated extends WalletState {
  final Wallet wallet;
  final List<WalletTransaction> transactions;
  final String transactionId;
  final String paymentUrl;

  const WalletTopUpSessionCreated({
    required this.wallet,
    required this.transactions,
    required this.transactionId,
    required this.paymentUrl,
  });

  @override
  List<Object> get props => [wallet, transactions, transactionId, paymentUrl];
}

class WalletTopUpError extends WalletState {
  final Wallet wallet;
  final List<WalletTransaction> transactions;
  final String message;

  const WalletTopUpError({
    required this.wallet,
    required this.transactions,
    required this.message,
  });

  @override
  List<Object> get props => [wallet, transactions, message];
}
