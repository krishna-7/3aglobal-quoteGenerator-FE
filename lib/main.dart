import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/payment_links_screen.dart';
import 'screens/users_screen.dart';
import 'screens/payment_link_report_screen.dart';
import 'screens/user_types_screen.dart';
import 'screens/menus_screen.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Quote Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) {
    try {
      final container = ProviderScope.containerOf(context);
      final authState = container.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isGoingToLogin = state.uri.path == '/login';

      // If user is logged in and trying to access login page, redirect to dashboard
      if (isLoggedIn && isGoingToLogin) {
        return '/dashboard';
      }

      // If user is not logged in and trying to access protected routes, redirect to login
      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }
    } catch (e) {
      // If there's an error reading auth state, allow navigation
      // This handles cases where ProviderScope might not be available yet
    }

    return null; // No redirect needed
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/payment-links',
      builder: (context, state) => const PaymentLinksScreen(),
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) => const UsersScreen(),
    ),
    GoRoute(
      path: '/reports/payment-links',
      builder: (context, state) => const PaymentLinkReportScreen(),
    ),
    GoRoute(path: '/settings/user-types', builder: (context, state) => const UserTypesScreen()),
    GoRoute(path: '/settings/menus', builder: (context, state) => const MenusScreen()),
  ],
);
