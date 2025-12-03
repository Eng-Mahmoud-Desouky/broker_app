import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../home/presentation/widgets/custom_app_bar.dart';
import '../../../temp_auth/temp_auth_service.dart';
import '../bloc/wallet_bloc.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_transaction_list.dart';
import '../widgets/wallet_top_up_dialog.dart';
import 'payment_webview_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late WalletBloc _walletBloc;
  String? _currentUserId;
  bool _walletInitialized = false;

  @override
  void initState() {
    super.initState();
    _walletBloc = di.sl<WalletBloc>();
    // Initialize wallet after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWalletFromAuthState();
    });
  }

  void _initializeWalletFromAuthState() {
    try {
      // Check both authentication systems
      final authState = context.read<AuthBloc>().state;

      // Check if user is authenticated via TempAuthService (email/password)
      final tempAuthUser = TempAuthService.getCurrentUser();

      if (authState is AuthAuthenticated) {
        // User authenticated via AuthBloc (phone + OTP)
        _currentUserId = authState.session.user.id;
        if (!_walletInitialized) {
          _walletInitialized = true;
          _walletBloc.add(WalletLoadRequested(userId: _currentUserId!));
        }
      } else if (tempAuthUser != null) {
        // User authenticated via TempAuthService (email/password)
        _currentUserId = tempAuthUser.id;
        if (!_walletInitialized) {
          _walletInitialized = true;
          _walletBloc.add(WalletLoadRequested(userId: _currentUserId!));
        }
      } else if (authState is AuthInitial || authState is AuthLoading) {
        // Auth state is still loading, wait for it to update
        // The listener will call this method again when state changes
      } else {
        // User is not authenticated - emit unauthenticated state
        if (!_walletInitialized) {
          _walletInitialized = true;
          _walletBloc.add(const WalletUnauthenticatedRequested());
        }
      }
    } catch (e) {
      // Emit error state for any unexpected errors
      _walletBloc.add(WalletErrorOccurred(message: 'خطأ في تحميل المحفظة: $e'));
    }
  }

  @override
  void dispose() {
    _walletBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _walletBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          // Check both authentication systems when auth state changes
          final tempAuthUser = TempAuthService.getCurrentUser();

          if (authState is AuthAuthenticated) {
            // User authenticated via AuthBloc (phone + OTP)
            _currentUserId = authState.session.user.id;
            if (!_walletInitialized && _walletBloc.state is WalletInitial) {
              _walletInitialized = true;
              _walletBloc.add(WalletLoadRequested(userId: _currentUserId!));
            }
          } else if (tempAuthUser != null) {
            // User authenticated via TempAuthService (email/password)
            _currentUserId = tempAuthUser.id;
            if (!_walletInitialized && _walletBloc.state is WalletInitial) {
              _walletInitialized = true;
              _walletBloc.add(WalletLoadRequested(userId: _currentUserId!));
            }
          } else if (authState is! AuthInitial && authState is! AuthLoading) {
            // User is not authenticated
            if (!_walletInitialized && _walletBloc.state is WalletInitial) {
              _walletInitialized = true;
              _walletBloc.add(const WalletUnauthenticatedRequested());
            }
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            notificationCount: 3,
            onSupportTap: () async {
              AppRouter.goToSupportList(context);
            },
            onNotificationTap: () {
              // TODO: Navigate to notifications
            },
          ),
          body: BlocConsumer<WalletBloc, WalletState>(
            listener: (context, state) {
              if (state is WalletError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state is WalletTopUpError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state is WalletTopUpSessionCreated) {
                _navigateToPayment(state.paymentUrl, state.transactionId);
              }
            },
            builder: (context, state) {
              if (state is WalletLoading) {
                return _buildLoadingState();
              } else if (state is WalletUnauthenticated) {
                return _buildUnauthenticatedState();
              } else if (state is WalletError) {
                return _buildErrorState(state.message);
              } else if (state is WalletLoaded ||
                  state is WalletTopUpLoading ||
                  state is WalletTopUpSessionCreated ||
                  state is WalletTopUpError) {
                return _buildLoadedState(state);
              }

              return _buildInitialState();
            },
          ),
          floatingActionButton: _buildTopUpButton(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildUnauthenticatedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'يجب تسجيل الدخول',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى تسجيل الدخول لعرض محفظتك والقيام بعمليات الشحن',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to login
                AppRouter.goToPhoneInput(context);
              },
              icon: const Icon(Icons.login),
              label: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshWallet,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Text('جاري تحميل المحفظة...', style: AppTextStyles.bodyLarge),
    );
  }

  Widget _buildLoadedState(WalletState state) {
    late final dynamic wallet;
    late final dynamic transactions;
    late final bool isTopUpLoading;

    if (state is WalletLoaded) {
      wallet = state.wallet;
      transactions = state.transactions;
      isTopUpLoading = false;
    } else if (state is WalletTopUpLoading) {
      wallet = state.wallet;
      transactions = state.transactions;
      isTopUpLoading = true;
    } else if (state is WalletTopUpSessionCreated) {
      wallet = state.wallet;
      transactions = state.transactions;
      isTopUpLoading = false;
    } else if (state is WalletTopUpError) {
      wallet = state.wallet;
      transactions = state.transactions;
      isTopUpLoading = false;
    }

    return RefreshIndicator(
      onRefresh: () async => _refreshWallet(),
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: WalletBalanceCard(
                wallet: wallet,
                isLoading: isTopUpLoading,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'سجل المعاملات',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.onBackground,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          WalletTransactionList(
            transactions: transactions,
            onLoadMore: _loadMoreTransactions,
            isLoadingMore: state is WalletLoaded ? state.isLoadingMore : false,
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpButton() {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        final isLoading = state is WalletTopUpLoading;

        return FloatingActionButton.extended(
          onPressed: isLoading ? null : _showTopUpDialog,
          backgroundColor: isLoading ? AppColors.grey400 : AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          icon:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                  : const Icon(Icons.add),
          label: Text(
            isLoading ? 'جاري الشحن...' : 'شحن المحفظة',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
        );
      },
    );
  }

  void _refreshWallet() {
    if (_currentUserId != null) {
      _walletBloc.add(WalletRefreshRequested(userId: _currentUserId!));
    }
  }

  void _loadMoreTransactions() {
    if (_currentUserId != null) {
      final state = _walletBloc.state;
      if (state is WalletLoaded && !state.isLoadingMore) {
        _walletBloc.add(
          WalletTransactionHistoryRequested(
            userId: _currentUserId!,
            limit: 20,
            offset: state.transactions.length,
          ),
        );
      }
    }
  }

  void _showTopUpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => BlocProvider.value(
            value: _walletBloc,
            child: WalletTopUpDialog(
              onTopUp: (amount) {
                // Close the dialog first
                Navigator.of(context).pop();

                if (_currentUserId != null) {
                  _walletBloc.add(
                    WalletTopUpRequested(
                      userId: _currentUserId!,
                      amount: amount,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('خطأ: لم يتم العثور على معرف المستخدم'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
            ),
          ),
    );
  }

  void _navigateToPayment(String paymentUrl, String transactionId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider.value(
              value: _walletBloc,
              child: PaymentWebViewScreen(
                paymentUrl: paymentUrl,
                transactionId: transactionId,
                userId: _currentUserId!,
              ),
            ),
      ),
    );
  }
}
