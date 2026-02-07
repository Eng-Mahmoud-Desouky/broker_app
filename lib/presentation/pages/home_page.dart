import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/notifications/presentation/bloc/notifications_state.dart';
import '../../features/home/presentation/widgets/custom_app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            int count = 0;
            if (state is NotificationsLoaded) {
              count = state.unreadCount;
            }
            return CustomAppBar(
              notificationCount: count,
              onSupportTap: () async {
                AppRouter.goToSupportList(context);
              },
              onNotificationTap: () {
                AppRouter.goToNotifications(context);
              },
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بك',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مرحباً بك في تطبيق الوسيط',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onPrimary.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Quick actions section
            Text(
              'الإجراءات السريعة',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Grid of action cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.defaultPadding,
                mainAxisSpacing: AppConstants.defaultPadding,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.shopping_cart_outlined,
                    title: 'المنتجات',
                    subtitle: 'تصفح المنتجات',
                    color: AppColors.primary,
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: 'الطلبات',
                    subtitle: 'إدارة الطلبات',
                    color: AppColors.secondary,
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'المحفظة',
                    subtitle: 'إدارة الأموال',
                    color: AppColors.success,
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.support_agent_outlined,
                    title: 'الدعم',
                    subtitle: 'تواصل معنا',
                    color: AppColors.info,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to respective page
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$title - قريباً')));
        },
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
