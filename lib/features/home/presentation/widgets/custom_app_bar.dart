import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSupportTap;
  final VoidCallback? onNotificationTap;
  final int? notificationCount;

  const CustomAppBar({
    super.key,
    this.onSupportTap,
    this.onNotificationTap,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      leading: IconButton(
        onPressed: onSupportTap ?? () {
          // TODO: Navigate to customer support
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('دعم العملاء - قريباً'),
              backgroundColor: AppColors.secondary,
            ),
          );
        },
        icon: const Icon(Icons.support_agent_rounded),
        tooltip: 'دعم العملاء',
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Broker App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: onNotificationTap ?? () {
                // TODO: Navigate to notifications
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('الإشعارات - قريباً'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
              icon: const Icon(Icons.notifications_rounded),
              tooltip: 'الإشعارات',
            ),
            if (notificationCount != null && notificationCount! > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount! > 99 ? '99+' : notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
