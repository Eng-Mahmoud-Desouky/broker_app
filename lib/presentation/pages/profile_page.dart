import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/constants.dart';
import '../../features/home/presentation/widgets/custom_app_bar.dart';
import '../../features/temp_auth/temp_auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
      body: SingleChildScrollView(
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
                      border: Border.all(color: AppColors.primary, width: 3),
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
                    'مستخدم جديد',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppConstants.smallPadding),

                  // Phone number
                  Text(
                    '+964 7XX XXX XXXX',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.grey600),
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
                  const SnackBar(content: Text('المعلومات الشخصية - قريباً')),
                );
              },
            ),

            _buildProfileOption(
              context,
              icon: Icons.location_on_outlined,
              title: 'العناوين',
              subtitle: 'إدارة عناوين التوصيل',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('العناوين - قريباً')),
                );
              },
            ),

            _buildProfileOption(
              context,
              icon: Icons.payment_outlined,
              title: 'طرق الدفع',
              subtitle: 'إدارة طرق الدفع المحفوظة',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('طرق الدفع - قريباً')),
                );
              },
            ),

            _buildProfileOption(
              context,
              icon: Icons.notifications_outlined,
              title: 'الإشعارات',
              subtitle: 'إعدادات الإشعارات',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الإشعارات - قريباً')),
                );
              },
            ),

            _buildProfileOption(
              context,
              icon: Icons.help_outline,
              title: 'المساعدة والدعم',
              subtitle: 'الحصول على المساعدة',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('المساعدة والدعم - قريباً')),
                );
              },
            ),

            _buildProfileOption(
              context,
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              subtitle: 'إعدادات التطبيق والحساب',
              onTap: () {
                AppRouter.goToSettings(context);
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
                    // Sign out from temporary auth
                    await TempAuthService.signOut();

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
}
