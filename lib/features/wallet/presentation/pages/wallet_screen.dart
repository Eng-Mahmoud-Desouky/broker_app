import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _walletBloc = di.sl<WalletBloc>();
    // Delay initialization to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWallet();
    });
  }

  void _initializeWallet() {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _currentUserId = authState.session.user.id;
        print('Wallet: Initializing for user ID: $_currentUserId'); // Debug log
        _walletBloc.add(WalletLoadRequested(userId: _currentUserId!));
      } else {
        print('Wallet: User not authenticated, state: $authState'); // Debug log
        // Handle unauthenticated state
        _walletBloc.add(
          WalletLoadRequested(userId: 'temp-user-id'),
        ); // Fallback for testing
      }
    } catch (e) {
      print('Wallet: Error during initialization: $e'); // Debug log
      // Emit error state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل المحفظة: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('المحفظة', style: AppTextStyles.headlineSmall),
          backgroundColor: AppColors.surface,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _refreshWallet,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
            ),
          ],
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
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
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
                  print(
                    'Wallet: Requesting top-up for amount: $amount fils',
                  ); // Debug log
                  _walletBloc.add(
                    WalletTopUpRequested(
                      userId: _currentUserId!,
                      amount: amount,
                    ),
                  );
                } else {
                  print('Wallet: No user ID available for top-up'); // Debug log
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
              ),
            ),
      ),
    );
  }
}
