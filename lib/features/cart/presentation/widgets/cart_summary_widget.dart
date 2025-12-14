import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/cart_bloc.dart';

/// Widget displaying cart summary with total items and price
class CartSummaryWidget extends StatelessWidget {
  final int totalItems;
  final double? totalPrice;

  const CartSummaryWidget({
    super.key,
    required this.totalItems,
    this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إجمالي المنتجات:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '$totalItems منتج',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            if (totalPrice != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الإجمالي التقريبي:',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${totalPrice!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'ملاحظة: الأسعار تقريبية وقد تختلف حسب العملة',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Get cart items from BLoC
                  final cartBloc = context.read<CartBloc>();
                  final cartState = cartBloc.state;

                  if (cartState is CartLoaded) {
                    final items = cartState.items;

                    // Check if all items have weight
                    final hasAllWeights = items.every(
                      (item) => item.weightKg != null,
                    );

                    if (!hasAllWeights) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'يرجى إضافة أوزان جميع المنتجات قبل إنشاء الطلب',
                          ),
                          backgroundColor: AppColors.warning,
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    // Navigate to create order
                    AppRouter.goToCreateOrder(context, items);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('السلة فارغة'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('متابعة الطلب'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
