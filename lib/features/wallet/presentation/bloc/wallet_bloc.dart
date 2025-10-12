import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/usecases/get_wallet_balance.dart';
import '../../domain/usecases/get_transaction_history.dart';
import '../../domain/usecases/create_topup_transaction.dart';
import '../../domain/usecases/get_transaction_by_id.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletBalance getWalletBalance;
  final GetTransactionHistory getTransactionHistory;
  final CreateTopUpTransaction createTopUpTransaction;
  final GetTransactionById getTransactionById;

  WalletBloc({
    required this.getWalletBalance,
    required this.getTransactionHistory,
    required this.createTopUpTransaction,
    required this.getTransactionById,
  }) : super(WalletInitial()) {
    on<WalletLoadRequested>(_onWalletLoadRequested);
    on<WalletRefreshRequested>(_onWalletRefreshRequested);
    on<WalletTopUpRequested>(_onWalletTopUpRequested);
  }

  Future<void> _onWalletLoadRequested(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    print('WalletBloc: Loading wallet for user ${event.userId}');
    emit(WalletLoading());

    try {
      // Load wallet balance
      final walletResult = await getWalletBalance(
        GetWalletBalanceParams(userId: event.userId),
      );

      await walletResult.fold(
        (failure) async {
          print('WalletBloc: Failed to load wallet: ${failure.message}');
          emit(WalletError(message: failure.message));
        },
        (wallet) async {
          print('WalletBloc: Wallet loaded successfully: ${wallet.balanceInDinars} IQD');
          
          // Load transaction history
          final transactionsResult = await getTransactionHistory(
            GetTransactionHistoryParams(userId: event.userId, limit: 20),
          );

          transactionsResult.fold(
            (failure) {
              print('WalletBloc: Failed to load transactions: ${failure.message}');
              emit(WalletError(message: failure.message));
            },
            (transactions) {
              print('WalletBloc: Loaded ${transactions.length} transactions');
              emit(WalletLoaded(wallet: wallet, transactions: transactions));
            },
          );
        },
      );
    } catch (e) {
      print('WalletBloc: Unexpected error during wallet load: $e');
      emit(WalletError(message: 'خطأ غير متوقع: $e'));
    }
  }

  Future<void> _onWalletRefreshRequested(
    WalletRefreshRequested event,
    Emitter<WalletState> emit,
  ) async {
    if (state is WalletLoaded) {
      final currentState = state as WalletLoaded;

      // Load wallet balance
      final walletResult = await getWalletBalance(
        GetWalletBalanceParams(userId: event.userId),
      );

      await walletResult.fold(
        (failure) async => emit(WalletError(message: failure.message)),
        (wallet) async {
          // Load transaction history
          final transactionsResult = await getTransactionHistory(
            GetTransactionHistoryParams(userId: event.userId, limit: 20),
          );

          transactionsResult.fold(
            (failure) => emit(WalletError(message: failure.message)),
            (transactions) => emit(WalletLoaded(wallet: wallet, transactions: transactions)),
          );
        },
      );
    }
  }

  Future<void> _onWalletTopUpRequested(
    WalletTopUpRequested event,
    Emitter<WalletState> emit,
  ) async {
    print('WalletBloc: Top-up requested for ${event.amount} fils');
    
    if (state is WalletLoaded) {
      final currentState = state as WalletLoaded;
      print('WalletBloc: Emitting top-up loading state');
      
      emit(
        WalletTopUpLoading(
          wallet: currentState.wallet,
          transactions: currentState.transactions,
        ),
      );

      try {
        print('WalletBloc: Calling createTopUpTransaction use case');
        final result = await createTopUpTransaction(
          CreateTopUpTransactionParams(
            userId: event.userId,
            amount: event.amount,
          ),
        );

        result.fold(
          (failure) {
            print('WalletBloc: Top-up failed: ${failure.message}');
            emit(
              WalletTopUpError(
                wallet: currentState.wallet,
                transactions: currentState.transactions,
                message: failure.message,
              ),
            );
          },
          (paymentData) {
            print('WalletBloc: Top-up session created: $paymentData');
            final transactionId = paymentData['id'] as String;
            final paymentUrl =
                'https://test.zaincash.iq/transaction/pay?id=$transactionId';

            print('WalletBloc: Payment URL: $paymentUrl');
            emit(
              WalletTopUpSessionCreated(
                wallet: currentState.wallet,
                transactions: currentState.transactions,
                transactionId: transactionId,
                paymentUrl: paymentUrl,
              ),
            );
          },
        );
      } catch (e) {
        print('WalletBloc: Unexpected error during top-up: $e');
        emit(
          WalletTopUpError(
            wallet: currentState.wallet,
            transactions: currentState.transactions,
            message: 'خطأ غير متوقع: $e',
          ),
        );
      }
    } else {
      print('WalletBloc: Cannot top-up, wallet not loaded. Current state: $state');
    }
  }
}
