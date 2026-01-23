import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/constants.dart';
import '../../core/di/injection_container.dart';
import '../../core/services/notifications_service.dart';
import '../../features/home/presentation/widgets/custom_app_bar.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/notifications/presentation/bloc/notifications_state.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String displayName = 'مستخدم جديد';
          String displayPhone = '';

          if (state is AuthAuthenticated) {
            displayName = state.session.user.name ?? 'مستخدم جديد';
            displayPhone = state.session.user.phoneNumber;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                // Profile header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile picture
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: AppConstants.defaultPadding),

                      // User name
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: AppConstants.smallPadding),

                      // Phone number
                      Text(
                        displayPhone,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Profile options
                _buildProfileOption(
                  context,
                  icon: Icons.person_outline,
                  title: 'المعلومات الشخصية',
                  subtitle: 'إدارة معلوماتك الشخصية',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('المعلومات الشخصية - قريباً'),
                      ),
                    );
                  },
                ),

                _buildProfileOption(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'العناوين',
                  subtitle: 'إدارة عناوين التوصيل',
                  onTap: () {
                    AppRouter.goToAddressList(context);
                  },
                ),

                _buildNotificationToggle(context),

                _buildProfileOption(
                  context,
                  icon: Icons.help_outline,
                  title: 'المساعدة والدعم',
                  subtitle: 'الحصول على المساعدة',
                  onTap: () {
                    AppRouter.goToSupportList(context);
                  },
                ),

                _buildProfileOption(
                  context,
                  icon: Icons.info_outline,
                  title: 'حول التطبيق',
                  subtitle: 'الإصدار ${AppConstants.appVersion}',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),

                _buildProfileOption(
                  context,
                  icon: Icons.description_outlined,
                  title: 'شروط الاستخدام',
                  subtitle: 'اقرأ شروط الاستخدام',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('شروط الاستخدام - قريباً')),
                    );
                  },
                ),

                _buildProfileOption(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'سياسة الخصوصية',
                  subtitle: 'اقرأ سياسة الخصوصية',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('سياسة الخصوصية - قريباً')),
                    );
                  },
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.grey400,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        tileColor: AppColors.surface,
      ),
    );
  }

  Widget _buildNotificationToggle(BuildContext context) {
    final notificationsService = sl<NotificationsService>();
    bool isEnabled = notificationsService.isNotificationsEnabled();

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppConstants.smallBorderRadius,
                ),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
              ),
            ),
            title: const Text(
              'الإشعارات',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: const Text(
              'تلقي التنبيهات عند وجود تحديثات',
              style: TextStyle(color: AppColors.grey600, fontSize: 12),
            ),
            value: isEnabled,
            activeColor: AppColors.primary,
            onChanged: (bool value) async {
              setState(() {
                isEnabled = value;
              });
              await notificationsService.setNotificationsEnabled(value);
            },
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  try {
                    // Sign out using AuthBloc
                    context.read<AuthBloc>().add(AuthSignOutRequested());

                    if (context.mounted) {
                      // Navigate to phone input page
                      AppRouter.goToPhoneInput(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تسجيل الخروج بنجاح'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'حدث خطأ أثناء تسجيل الخروج: ${e.toString()}',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.business, color: AppColors.white, size: 32),
      ),
      children: const [
        Text('تطبيق الوسيط للتجارة الإلكترونية'),
        SizedBox(height: 16),
        Text('تم تطويره بواسطة فريق التطوير'),
      ],
    );
  }
}
