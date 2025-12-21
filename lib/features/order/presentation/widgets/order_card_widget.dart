import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order.dart';
import 'order_status_badge.dart';

/// Card widget for displaying order summary in list
class OrderCardWidget extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCardWidget({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Reference number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.referenceNumber,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OrderStatusBadge(
                    status: order.status,
                    showIcon: false,
                    fontSize: 11,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(order.createdAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Order details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Number of items
                    Expanded(
                      child: _buildInfoItem(
                        context: context,
                        icon: Icons.shopping_bag_outlined,
                        label: 'المنتجات',
                        value: '${order.totalItems}',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppColors.grey300,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    // Total weight
                    Expanded(
                      child: _buildInfoItem(
                        context: context,
                        icon: Icons.scale,
                        label: 'الوزن',
                        value: '${order.totalWeightKg.toStringAsFixed(1)} كجم',
                      ),
                    ),
                    if (order.totalPrice != null) ...[
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColors.grey300,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      // Total price
                      Expanded(
                        child: _buildInfoItem(
                          context: context,
                          icon: Icons.attach_money,
                          label: 'السعر',
                          value: '\$${order.totalPrice!.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // View details button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'عرض التفاصيل',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }
}
