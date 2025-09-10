import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/phone_input_page.dart';
import '../../features/authentication/presentation/pages/otp_verification_page.dart';
import '../../features/authentication/presentation/pages/registration_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/offers_page.dart';
import '../../features/home/presentation/pages/platform_products_page.dart';
import '../../presentation/pages/main_wrapper.dart';
import '../../presentation/pages/favorites_page.dart';
import '../../presentation/pages/profile_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../splash.dart';

class AppRouter {
  static const String splash = '/';
  static const String phoneInput = '/phone-input';
  static const String otpVerification = '/otp-verification';
  static const String registration = '/registration';
  static const String main = '/main';
  static const String home = '/main/home';
  static const String favorites = '/main/favorites';
  static const String profile = '/main/profile';
  static const String settings = '/main/settings';
  static const String offers = '/offers';
  static const String platformProducts = '/platform';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash route
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication routes
      GoRoute(
        path: phoneInput,
        name: 'phone-input',
        builder: (context, state) => const PhoneInputPage(),
      ),
      GoRoute(
        path: otpVerification,
        name: 'otp-verification',
        builder: (context, state) {
          final phoneNumber = state.extra as String?;
          return OtpVerificationPage(phoneNumber: phoneNumber ?? '');
        },
      ),
      GoRoute(
        path: registration,
        name: 'registration',
        builder: (context, state) => const RegistrationPage(),
      ),

      // Standalone routes (outside main wrapper)
      GoRoute(
        path: offers,
        name: 'offers',
        builder: (context, state) => const OffersPage(),
      ),
      GoRoute(
        path: '$platformProducts/:platformId',
        name: 'platform-products',
        builder: (context, state) {
          final platformId = state.pathParameters['platformId'] ?? '';
          return PlatformProductsPage(platformId: platformId);
        },
      ),

      // Main app routes with shell
      ShellRoute(
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: favorites,
            name: 'favorites',
            builder: (context, state) => const FavoritesPage(),
          ),
          GoRoute(
            path: profile,
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Page not found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(home),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
  );

  // Navigation helpers
  static void goToPhoneInput(BuildContext context) {
    context.go(phoneInput);
  }

  static void goToOtpVerification(BuildContext context, String phoneNumber) {
    context.go(otpVerification, extra: phoneNumber);
  }

  static void goToRegistration(BuildContext context) {
    context.go(registration);
  }

  static void goToHome(BuildContext context) {
    context.go(home);
  }

  static void goToFavorites(BuildContext context) {
    context.go(favorites);
  }

  static void goToProfile(BuildContext context) {
    context.go(profile);
  }

  static void goToSettings(BuildContext context) {
    context.go(settings);
  }

  // Check if current route is in main app
  static bool isMainRoute(String location) {
    return location.startsWith('/main');
  }

  // Get current tab index for bottom navigation
  static int getCurrentTabIndex(String location) {
    switch (location) {
      case home:
        return 0;
      case favorites:
        return 1;
      case profile:
        return 2;
      case settings:
        return 3;
      default:
        return 0;
    }
  }
}
