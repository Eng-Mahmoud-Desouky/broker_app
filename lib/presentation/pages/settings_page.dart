import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/constants.dart';
import '../../features/home/presentation/widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App settings section
            _buildSectionHeader(context, 'إعدادات التطبيق'),

            _buildSettingItem(
              context,
              icon: Icons.language_outlined,
              title: 'اللغة',
              subtitle: 'العربية',
              onTap: () {
                _showLanguageDialog(context);
              },
            ),

            _buildSettingItem(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'المظهر',
              subtitle: 'فاتح',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('إعدادات المظهر - قريباً')),
                );
              },
            ),

            _buildSettingItem(
              context,
              icon: Icons.notifications_outlined,
              title: 'الإشعارات',
              subtitle: 'مفعلة',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('إعدادات الإشعارات - قريباً')),
                  );
                },
                activeColor: AppColors.primary,
              ),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Account settings section
            _buildSectionHeader(context, 'إعدادات الحساب'),

            _buildSettingItem(
              context,
              icon: Icons.security_outlined,
              title: 'الأمان والخصوصية',
              subtitle: 'إدارة إعدادات الأمان',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الأمان والخصوصية - قريباً')),
                );
              },
            ),

            _buildSettingItem(
              context,
              icon: Icons.backup_outlined,
              title: 'النسخ الاحتياطي',
              subtitle: 'نسخ احتياطي للبيانات',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('النسخ الاحتياطي - قريباً')),
                );
              },
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Support section
            _buildSectionHeader(context, 'الدعم والمساعدة'),

            _buildSettingItem(
              context,
              icon: Icons.help_outline,
              title: 'مركز المساعدة',
              subtitle: 'الأسئلة الشائعة والدعم',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('مركز المساعدة - قريباً')),
                );
              },
            ),

            _buildSettingItem(
              context,
              icon: Icons.feedback_outlined,
              title: 'إرسال ملاحظات',
              subtitle: 'شاركنا رأيك',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('إرسال ملاحظات - قريباً')),
                );
              },
            ),

            _buildSettingItem(
              context,
              icon: Icons.info_outline,
              title: 'حول التطبيق',
              subtitle: 'الإصدار ${AppConstants.appVersion}',
              onTap: () {
                _showAboutDialog(context);
              },
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Legal section
            _buildSectionHeader(context, 'القانونية'),

            _buildSettingItem(
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

            _buildSettingItem(
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppConstants.defaultPadding,
        top: AppConstants.smallPadding,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
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
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
        ),
        trailing:
            trailing ??
            const Icon(
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

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('اختر اللغة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('العربية'),
                  leading: Radio<String>(
                    value: 'ar',
                    groupValue: 'ar',
                    onChanged: (value) {
                      Navigator.of(context).pop();
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                ListTile(
                  title: const Text('English'),
                  leading: Radio<String>(
                    value: 'en',
                    groupValue: 'ar',
                    onChanged: (value) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تغيير اللغة - قريباً')),
                      );
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
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
      children: [
        const Text('تطبيق الوسيط للتجارة الإلكترونية'),
        const SizedBox(height: 16),
        const Text('تم تطويره بواسطة فريق التطوير'),
      ],
    );
  }
}
