import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/wallet_transaction.dart';
import 'wallet_transaction_item.dart';

class WalletTransactionList extends StatelessWidget {
  final List<WalletTransaction> transactions;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;

  const WalletTransactionList({
    super.key,
    required this.transactions,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == transactions.length) {
            // Load more indicator
            if (isLoadingMore) {
              return _buildLoadMoreIndicator();
            } else if (onLoadMore != null) {
              return _buildLoadMoreButton();
            }
            return const SizedBox.shrink();
          }

          final transaction = transactions[index];
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: index == transactions.length - 1 ? 100 : 8, // Extra space for FAB
            ),
            child: WalletTransactionItem(transaction: transaction),
          );
        },
        childCount: transactions.length + (onLoadMore != null ? 1 : 0),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد معاملات',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر معاملاتك هنا بعد إجراء أول عملية شحن أو شراء',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: OutlinedButton(
          onPressed: onLoadMore,
          child: const Text('تحميل المزيد'),
        ),
      ),
    );
  }
}
