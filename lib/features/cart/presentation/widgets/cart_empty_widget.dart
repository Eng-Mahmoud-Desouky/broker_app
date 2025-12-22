import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget displayed when cart is empty
class CartEmptyWidget extends StatelessWidget {
  const CartEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 120,
              color: AppColors.grey300,
            ),
            const SizedBox(height: 24),
            const Text(
              'السلة فارغة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ابدأ بإضافة منتجات من المنصات المختلفة',
              style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                AppRouter.goToHome(context);
              },
              icon: const Icon(Icons.home_outlined),
              label: const Text('الرجوع للرئيسية'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
