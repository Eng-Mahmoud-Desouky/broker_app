import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/notification.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/notifications_cubit.dart';
import '../bloc/notifications_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'تحديد الكل كمقروء',
            onPressed: () {
              context.read<NotificationsCubit>().markNotificationsAsRead();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is NotificationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () =>
                            context
                                .read<NotificationsCubit>()
                                .loadNotifications(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          } else if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 100,
                      color: AppColors.grey400,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'لا توجد إشعارات حالياً',
                      style: TextStyle(fontSize: 18, color: AppColors.grey600),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh:
                  () => context.read<NotificationsCubit>().loadNotifications(),
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return _NotificationItem(notification: notification);
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'orders':
        icon = Icons.shopping_bag_outlined;
        iconColor = AppColors.primary;
        break;
      case 'support_messages':
        icon = Icons.support_agent_rounded;
        iconColor = AppColors.secondary;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        iconColor = AppColors.grey600;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color:
            notification.isRead
                ? Colors.white
                : AppColors.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              notification.isRead
                  ? AppColors.grey200
                  : AppColors.primary.withOpacity(0.1),
        ),
        boxShadow: [
          if (!notification.isRead)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: TextStyle(color: AppColors.grey600, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              dateFormat.format(notification.createdAt),
              style: const TextStyle(color: AppColors.grey400, fontSize: 11),
            ),
          ],
        ),
        trailing:
            !notification.isRead
                ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                )
                : null,
      ),
    );
  }
}
