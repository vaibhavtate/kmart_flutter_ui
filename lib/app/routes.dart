import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/auth/login_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/location/location_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String login = '/login';
  static const String location = '/location';
  static const String cart = '/cart';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;

      final isLoggedIn = session != null;
      final currentRoute = state.matchedLocation;

      final isLoginRoute = currentRoute == login;

      if (!isLoggedIn && !isLoginRoute) {
        return login;
      }

      if (isLoggedIn && isLoginRoute) {
        return location;
      }

      return null;
    },
    routes: [
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: location,
        builder: (context, state) => const LocationScreen(),
      ),
      GoRoute(path: home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: cart, builder: (context, state) => const CartScreen()),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
