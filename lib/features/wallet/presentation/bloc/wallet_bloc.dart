import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/usecases/get_wallet_balance.dart';
import '../../domain/usecases/get_transaction_history.dart';
import '../../domain/usecases/create_topup_transaction.dart';
import '../../domain/usecases/get_transaction_by_id.dart';
import '../../domain/usecases/cancel_topup_session.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletBalance getWalletBalance;
  final GetTransactionHistory getTransactionHistory;
  final CreateTopUpTransaction createTopUpTransaction;
  final GetTransactionById getTransactionById;
  final CancelTopUpSession cancelTopUpSession;

  WalletBloc({
    required this.getWalletBalance,
    required this.getTransactionHistory,
    required this.createTopUpTransaction,
    required this.getTransactionById,
    required this.cancelTopUpSession,
  }) : super(WalletInitial()) {
    on<WalletLoadRequested>(_onWalletLoadRequested);
    on<WalletRefreshRequested>(_onWalletRefreshRequested);
    on<WalletTopUpRequested>(_onWalletTopUpRequested);
    on<WalletTransactionStatusChecked>(_onWalletTransactionStatusChecked);
    on<WalletTopUpSessionClosed>(_onWalletTopUpSessionClosed);
    on<WalletUnauthenticatedRequested>(_onWalletUnauthenticatedRequested);
    on<WalletErrorOccurred>(_onWalletErrorOccurred);
  }

  Future<void> _onWalletLoadRequested(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      // Load wallet balance
      final walletResult = await getWalletBalance(
        GetWalletBalanceParams(userId: event.userId),
      );

      await walletResult.fold(
        (failure) async {
          emit(WalletError(message: failure.message));
        },
        (wallet) async {
          // Load transaction history
          final transactionsResult = await getTransactionHistory(
            GetTransactionHistoryParams(userId: event.userId, limit: 20),
          );

          transactionsResult.fold(
            (failure) {
              emit(WalletError(message: failure.message));
            },
            (transactions) {
              emit(WalletLoaded(wallet: wallet, transactions: transactions));
            },
          );
        },
      );
    } catch (e) {
      emit(WalletError(message: 'خطأ غير متوقع: $e'));
    }
  }

  Future<void> _onWalletRefreshRequested(
    WalletRefreshRequested event,
    Emitter<WalletState> emit,
  ) async {
    if (state is WalletLoaded) {
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
            (transactions) =>
                emit(WalletLoaded(wallet: wallet, transactions: transactions)),
          );
        },
      );
    }
  }

  Future<void> _onWalletTopUpRequested(
    WalletTopUpRequested event,
    Emitter<WalletState> emit,
  ) async {
    if (kDebugMode) {
      debugPrint('💳 WalletTopUpRequested event received');
      debugPrint('   User ID: ${event.userId}');
      debugPrint('   Amount (dinars): ${event.amount}');
    }

    // Allow top-up from WalletLoaded or WalletTopUpError states
    if (state is WalletLoaded || state is WalletTopUpError) {
      final Wallet currentWallet;
      final List<WalletTransaction> currentTransactions;

      if (state is WalletLoaded) {
        final loadedState = state as WalletLoaded;
        currentWallet = loadedState.wallet;
        currentTransactions = loadedState.transactions;
      } else {
        final errorState = state as WalletTopUpError;
        currentWallet = errorState.wallet;
        currentTransactions = errorState.transactions;
      }

      emit(
        WalletTopUpLoading(
          wallet: currentWallet,
          transactions: currentTransactions,
        ),
      );

      if (kDebugMode) {
        debugPrint('   State changed to WalletTopUpLoading');
      }

      try {
        if (kDebugMode) {
          debugPrint('   Calling createTopUpTransaction...');
        }

        final result = await createTopUpTransaction(
          CreateTopUpTransactionParams(
            userId: event.userId,
            amount: event.amount,
          ),
        );

        if (kDebugMode) {
          debugPrint('   createTopUpTransaction completed');
        }

        result.fold(
          (failure) {
            if (kDebugMode) {
              debugPrint('❌ Top-up failed: ${failure.message}');
            }

            emit(
              WalletTopUpError(
                wallet: currentWallet,
                transactions: currentTransactions,
                message: failure.message,
              ),
            );
          },
          (paymentData) {
            if (kDebugMode) {
              debugPrint('✅ Payment data received:');
              debugPrint('   Raw data: $paymentData');
              debugPrint('   Data type: ${paymentData.runtimeType}');
              debugPrint('   Keys: ${paymentData.keys.toList()}');
            }

            // Safely extract transaction ID with null check
            final transactionId = paymentData['id'] as String?;

            if (transactionId == null || transactionId.isEmpty) {
              if (kDebugMode) {
                debugPrint('❌ Transaction ID is null or empty');
                debugPrint('   Available keys: ${paymentData.keys.toList()}');
                debugPrint('   Full response: $paymentData');
              }

              emit(
                WalletTopUpError(
                  wallet: currentWallet,
                  transactions: currentTransactions,
                  message:
                      'خطأ في إنشاء المعاملة: لم يتم استلام معرف المعاملة من الخادم',
                ),
              );
              return;
            }

            if (kDebugMode) {
              debugPrint('   Transaction ID: $transactionId');
            }

            final paymentUrl =
                'https://test.zaincash.iq/transaction/pay?id=$transactionId';

            if (kDebugMode) {
              debugPrint('   Payment URL: $paymentUrl');
            }

            emit(
              WalletTopUpSessionCreated(
                wallet: currentWallet,
                transactions: currentTransactions,
                transactionId: transactionId,
                paymentUrl: paymentUrl,
              ),
            );

            if (kDebugMode) {
              debugPrint('✅ WalletTopUpSessionCreated state emitted');
            }
          },
        );
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ Exception in _onWalletTopUpRequested: $e');
          debugPrint('   Stack trace: $stackTrace');
        }

        emit(
          WalletTopUpError(
            wallet: currentWallet,
            transactions: currentTransactions,
            message: 'خطأ غير متوقع: $e',
          ),
        );
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          '⚠️ WalletTopUpRequested ignored - state is not WalletLoaded or WalletTopUpError',
        );
        debugPrint('   Current state: ${state.runtimeType}');
      }
    }
  }

  Future<void> _onWalletTransactionStatusChecked(
    WalletTransactionStatusChecked event,
    Emitter<WalletState> emit,
  ) async {
    if (state is WalletTopUpLoading) {
      final currentState = state as WalletTopUpLoading;

      try {
        // Fetch the transaction details to verify payment status
        final result = await getTransactionById(
          GetTransactionByIdParams(transactionId: event.transactionId),
        );

        result.fold(
          (failure) {
            emit(
              WalletTopUpError(
                wallet: currentState.wallet,
                transactions: currentState.transactions,
                message: 'فشل التحقق من حالة الدفع: ${failure.message}',
              ),
            );
          },
          (transaction) {
            // Check if payment was successful
            if (transaction.status.toString().contains('completed') ||
                transaction.status.toString().contains('success')) {
              // Payment successful - emit completion state
              emit(
                WalletTopUpCompleted(
                  wallet: currentState.wallet,
                  transactions: currentState.transactions,
                  transactionId: event.transactionId,
                ),
              );

              // Refresh wallet data after successful payment
              _refreshWalletAfterPayment(currentState.wallet.userId, emit);
            } else if (transaction.status.toString().contains('failed') ||
                transaction.status.toString().contains('cancelled')) {
              // Payment failed
              emit(
                WalletTopUpError(
                  wallet: currentState.wallet,
                  transactions: currentState.transactions,
                  message: 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى.',
                ),
              );
            } else {
              // Payment still pending
              emit(
                WalletTopUpError(
                  wallet: currentState.wallet,
                  transactions: currentState.transactions,
                  message: 'لم تكتمل عملية الدفع بعد. يرجى المحاولة لاحقاً.',
                ),
              );
            }
          },
        );
      } catch (e) {
        emit(
          WalletTopUpError(
            wallet: currentState.wallet,
            transactions: currentState.transactions,
            message: 'خطأ في التحقق من حالة الدفع: $e',
          ),
        );
      }
    }
  }

  Future<void> _refreshWalletAfterPayment(
    String userId,
    Emitter<WalletState> emit,
  ) async {
    try {
      // Load updated wallet balance
      final walletResult = await getWalletBalance(
        GetWalletBalanceParams(userId: userId),
      );

      await walletResult.fold(
        (failure) async {
          // If refresh fails, keep the completion state
        },
        (wallet) async {
          // Load updated transaction history
          final transactionsResult = await getTransactionHistory(
            GetTransactionHistoryParams(userId: userId, limit: 20),
          );

          transactionsResult.fold(
            (failure) {
              // If refresh fails, keep the completion state
            },
            (transactions) {
              // Emit updated wallet state
              emit(WalletLoaded(wallet: wallet, transactions: transactions));
            },
          );
        },
      );
    } catch (e) {
      // If refresh fails, keep the current state
    }
  }

  Future<void> _onWalletTopUpSessionClosed(
    WalletTopUpSessionClosed event,
    Emitter<WalletState> emit,
  ) async {
    if (kDebugMode) {
      debugPrint('🔄 WalletTopUpSessionClosed event received');
      debugPrint('   User ID: ${event.userId}');
      debugPrint('   Current state: ${state.runtimeType}');
    }

    // Only handle if we're in a top-up related state
    if (state is WalletTopUpSessionCreated ||
        state is WalletTopUpLoading ||
        state is WalletTopUpError) {
      final Wallet currentWallet;
      final List<WalletTransaction> currentTransactions;

      if (state is WalletTopUpSessionCreated) {
        final sessionState = state as WalletTopUpSessionCreated;
        currentWallet = sessionState.wallet;
        currentTransactions = sessionState.transactions;
      } else if (state is WalletTopUpLoading) {
        final loadingState = state as WalletTopUpLoading;
        currentWallet = loadingState.wallet;
        currentTransactions = loadingState.transactions;
      } else {
        final errorState = state as WalletTopUpError;
        currentWallet = errorState.wallet;
        currentTransactions = errorState.transactions;
      }

      if (kDebugMode) {
        debugPrint('   Refreshing wallet data...');
      }

      // 1. Cancel the session in the background if transactionId is provided
      final transactionId =
          event.transactionId ??
          (state is WalletTopUpSessionCreated
              ? (state as WalletTopUpSessionCreated).transactionId
              : null);

      if (transactionId != null) {
        if (kDebugMode) {
          debugPrint('   Cancelling topup session for TX: $transactionId');
        }
        // Fire and forget cancellation - we don't want to block the UI reset
        unawaited(
          cancelTopUpSession(
            CancelTopUpSessionParams(transactionId: transactionId),
          ),
        );
      }

      try {
        // 2. Refresh wallet data
        final walletResult = await getWalletBalance(
          GetWalletBalanceParams(userId: event.userId),
        );

        await walletResult.fold(
          (failure) async {
            if (kDebugMode) {
              debugPrint('   ⚠️ Failed to refresh wallet: ${failure.message}');
              debugPrint('   Using cached wallet data');
            }
            // Use cached data if refresh fails
            emit(
              WalletLoaded(
                wallet: currentWallet,
                transactions: currentTransactions,
              ),
            );
          },
          (wallet) async {
            // Load updated transaction history
            final transactionsResult = await getTransactionHistory(
              GetTransactionHistoryParams(userId: event.userId, limit: 20),
            );

            transactionsResult.fold(
              (failure) {
                if (kDebugMode) {
                  debugPrint(
                    '   ⚠️ Failed to refresh transactions: ${failure.message}',
                  );
                  debugPrint('   Using cached transactions');
                }
                // Use updated wallet with cached transactions if refresh fails
                emit(
                  WalletLoaded(
                    wallet: wallet,
                    transactions: currentTransactions,
                  ),
                );
              },
              (transactions) {
                if (kDebugMode) {
                  debugPrint('   ✅ Wallet refreshed successfully');
                }
                emit(WalletLoaded(wallet: wallet, transactions: transactions));
              },
            );
          },
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('   ❌ Exception while refreshing: $e');
          debugPrint('   Using cached wallet data');
        }
        // Use cached data if exception occurs
        emit(
          WalletLoaded(
            wallet: currentWallet,
            transactions: currentTransactions,
          ),
        );
      }

      if (kDebugMode) {
        debugPrint('   State reset to WalletLoaded');
      }
    } else {
      if (kDebugMode) {
        debugPrint('   ⚠️ Ignoring - state is not top-up related');
      }
    }
  }

  Future<void> _onWalletUnauthenticatedRequested(
    WalletUnauthenticatedRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletUnauthenticated());
  }

  Future<void> _onWalletErrorOccurred(
    WalletErrorOccurred event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletError(message: event.message));
  }
}
