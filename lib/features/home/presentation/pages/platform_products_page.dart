import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';

class PlatformProductsPage extends StatelessWidget {
  final String platformId;

  const PlatformProductsPage({
    super.key,
    required this.platformId,
  });

  @override
  Widget build(BuildContext context) {
    // Get platform name based on ID (dummy data)
    final platformNames = {
      'shein': 'SHEIN',
      'taobao': 'Taobao',
      'amazon': 'Amazon',
      'alibaba': 'Alibaba',
      'aliexpress': 'AliExpress',
    };

    final platformName = platformNames[platformId] ?? 'منصة غير معروفة';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        onSupportTap: () {
          // TODO: Navigate to customer support
        },
        onNotificationTap: () {
          // TODO: Navigate to notifications
        },
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'منتجات $platformName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'تصفح جميع المنتجات المتاحة في $platformName',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      size: 64,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'منتجات $platformName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هذه صفحة مؤقتة لعرض منتجات المنصة\nسيتم تطويرها لاحقاً لعرض المنتجات الحقيقية\nمن $platformName',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('رجوع'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('الرئيسية'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
