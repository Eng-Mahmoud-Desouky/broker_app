import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionItem extends StatelessWidget {
  final WalletTransaction transaction;

  const WalletTransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title takes full width now
                  Text(
                    transaction.typeDisplayName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(transaction.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  if (transaction.provider != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'عبر ${_getProviderDisplayName(transaction.provider!)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isPositive ? '+' : '-'}${transaction.formattedAmount}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        transaction.isPositive
                            ? AppColors.success
                            : AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                // Status Chip moved here
                _buildStatusChip(),
                if (transaction.providerReference != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '#${transaction.providerReference!.substring(0, 8)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionIcon() {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (transaction.type) {
      case WalletTransactionType.topup:
        iconData = Icons.add_circle;
        backgroundColor = AppColors.successLight;
        iconColor = AppColors.success;
        break;
      case WalletTransactionType.purchase:
        iconData = Icons.shopping_cart;
        backgroundColor = AppColors.infoLight;
        iconColor = AppColors.info;
        break;
      case WalletTransactionType.refund:
        iconData = Icons.undo;
        backgroundColor = AppColors.warningLight;
        iconColor = AppColors.warning;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;

    switch (transaction.status) {
      case WalletTransactionStatus.pending:
        backgroundColor = AppColors.warningLight;
        textColor = AppColors.warning;
        break;
      case WalletTransactionStatus.success:
        backgroundColor = AppColors.successLight;
        textColor = AppColors.success;
        break;
      case WalletTransactionStatus.failed:
        backgroundColor = AppColors.errorLight;
        textColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        transaction.statusDisplayName,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'اليوم ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'أمس ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} أيام ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  String _getProviderDisplayName(String provider) {
    switch (provider.toLowerCase()) {
      case 'zaincash':
        return 'زين كاش';
      default:
        return provider;
    }
  }
}
