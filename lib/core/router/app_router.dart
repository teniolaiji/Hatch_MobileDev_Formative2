import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/user_providers.dart';
import '../../features/home/presentation/student_home_screen.dart';


class Routes {
  Routes._();
  static const login = '/login';
  static const home = '/home';
  static const signup = '/signup';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: Routes.welcome,
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) {
      final loggedIn = authRepository.currentUser != null;
      final loc = state.matchedLocation;
      final onPublicScreen =
          loc == Routes.welcome || loc == Routes.login || loc == Routes.signup;

      // Not signed in: allow only the public screens.
      if (!loggedIn) return onPublicScreen ? null : Routes.welcome;

      // Signed in: do we have a profile yet?
      final hasProfile = ref.read(currentUserProvider).value != null;

      // Signed in but no role chosen yet -> onboarding.
      if (!hasProfile && loc != Routes.onboarding) return Routes.onboarding;

      // Onboarded but still sitting on a public or onboarding screen -> home.
      if (hasProfile && (onPublicScreen || loc == Routes.onboarding)) {
        return Routes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
