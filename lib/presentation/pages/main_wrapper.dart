import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';

class MainWrapper extends StatelessWidget {
  final Widget child;

  const MainWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = AppRouter.getCurrentTabIndex(location);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey500,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          elevation: 0,
          onTap: (index) => _onTabTapped(context, index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: localizations.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
              label: 'طلباتي',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_outlined),
              activeIcon: const Icon(Icons.shopping_cart),
              label: 'السلة',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              activeIcon: const Icon(Icons.account_balance_wallet),
              label: 'المحفظة',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: 'الحساب',
            ),
          ],
        ),
      ),
    );
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.orders);
        break;
      case 2:
        context.go(AppRouter.cart);
        break;
      case 3:
        context.go(AppRouter.wallet);
        break;
      case 4:
        context.go(AppRouter.profile);
        break;
    }
  }
}
