import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../providers/user_providers.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/student_home_screen.dart';
import '../screens/home_screen.dart';
import 'package:hatch/screens/discover_screen.dart';

class Routes {
  Routes._();
  static const login = '/login';
  static const home = '/home';
  static const signup = '/signup';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const discover = '/discover';
}

class _RouterNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final notifier = _RouterNotifier();

  ref.listen(authStateChangesProvider, (_, __) => notifier.notify());
  ref.listen(currentUserProvider, (_, __) => notifier.notify());
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: Routes.welcome,
    refreshListenable: notifier,
    redirect: (context, state) {
      final loggedIn = authRepository.currentUser != null;
      final loc = state.matchedLocation;
      final onPublicScreen =
          loc == Routes.welcome || loc == Routes.login || loc == Routes.signup;

      if (!loggedIn) return onPublicScreen ? null : Routes.welcome;

      final hasProfile = ref.read(currentUserProvider).value != null;

      if (!hasProfile && loc != Routes.onboarding) return Routes.onboarding;

      if (hasProfile && (onPublicScreen || loc == Routes.onboarding)) {
        return Routes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: Routes.discover,
        builder: (context, state) => const DiscoverScreen(),
      ),
    ],
  );
});
