import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/constants.dart';
import '../../features/home/presentation/widgets/custom_app_bar.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        notificationCount: 3,
        onSupportTap: () async {
          AppRouter.goToSupportList(context);
        },
        onNotificationTap: () {
          // TODO: Navigate to notifications
        },
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(
                    AppConstants.largeBorderRadius,
                  ),
                ),
                child: Icon(
                  Icons.favorite_outline,
                  size: 80,
                  color: AppColors.grey400,
                ),
              ),

              const SizedBox(height: AppConstants.largePadding),

              Text(
                'لا توجد عناصر مفضلة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.smallPadding),

              Text(
                'ابدأ بإضافة المنتجات إلى قائمة المفضلة لديك',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.grey600),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.largePadding),

              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to products page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تصفح المنتجات - قريباً')),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('تصفح المنتجات'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.largePadding,
                    vertical: AppConstants.defaultPadding,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
