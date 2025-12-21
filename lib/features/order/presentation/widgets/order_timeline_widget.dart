import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';

/// Modern timeline widget for displaying order progress
class OrderTimelineWidget extends StatelessWidget {
  final Order order;

  const OrderTimelineWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Handle cancelled status differently
    if (order.status == OrderStatus.cancelled) {
      return _buildCancelledTimeline(context);
    }

    return _buildNormalTimeline(context);
  }

  Widget _buildNormalTimeline(BuildContext context) {
    final progressStatuses = OrderStatus.progressStatuses;
    final currentIndex = order.status.progressIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مسار الطلب',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: progressStatuses.length,
          itemBuilder: (context, index) {
            final status = progressStatuses[index];
            final isCompleted = index < currentIndex;
            final isCurrent = index == currentIndex;
            final isPending = index > currentIndex;

            return _buildTimelineItem(
              context: context,
              status: status,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isPending: isPending,
              isLast: index == progressStatuses.length - 1,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCancelledTimeline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مسار الطلب',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error, width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      OrderStatus.cancelled.arabicLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      OrderStatus.cancelled.getStatusDescription(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDateTime(order.updatedAt),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required OrderStatus status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isPending,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          Column(
            children: [
              _buildIndicator(
                status: status,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
              ),
              if (!isLast)
                _buildConnector(isCompleted: isCompleted, isCurrent: isCurrent),
            ],
          ),
          const SizedBox(width: 16),
          // Content column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildContent(
                context: context,
                status: status,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isPending: isPending,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator({
    required OrderStatus status,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    final color =
        isCompleted
            ? AppColors.success
            : isCurrent
            ? status.getStatusColor()
            : AppColors.grey300;

    if (isCompleted) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.check, color: AppColors.white, size: 20),
      );
    }

    if (isCurrent) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.2),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                status.getStatusIcon(),
                color: AppColors.white,
                size: 20,
              ),
            ),
          );
        },
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(status.getStatusIcon(), color: color, size: 18),
    );
  }

  Widget _buildConnector({required bool isCompleted, required bool isCurrent}) {
    final color =
        isCompleted
            ? AppColors.success
            : isCurrent
            ? AppColors.primary.withOpacity(0.3)
            : AppColors.grey300;

    return Container(
      width: 3,
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required OrderStatus status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isPending,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isCurrent
                ? status.getStatusColor().withOpacity(0.08)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCurrent
                  ? status.getStatusColor().withOpacity(0.3)
                  : isPending
                  ? AppColors.grey200
                  : AppColors.success.withOpacity(0.3),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  status.arabicLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        isCurrent || isCompleted
                            ? AppColors.onSurface
                            : AppColors.grey500,
                  ),
                ),
              ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            status.getStatusDescription(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  isCurrent || isCompleted
                      ? AppColors.onSurfaceVariant
                      : AppColors.grey400,
            ),
          ),
          if (isCompleted || isCurrent) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AppColors.grey600),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(order.updatedAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'الآن';
        }
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('dd/MM/yyyy - HH:mm', 'ar').format(dateTime);
    }
  }
}
