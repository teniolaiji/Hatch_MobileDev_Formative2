import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/app_user.dart';
import '../models/opportunity.dart';
import '../providers/auth_providers.dart';
import '../providers/user_providers.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/opportunity_detail_screen.dart';
import '../screens/student_shell.dart';
import '../screens/student_home_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/applications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/founder_shell.dart';
import '../screens/founder_home_screen.dart';
import '../screens/founder_roles_screen.dart';
import '../screens/founder_applicants_screen.dart';
import '../screens/post_opportunity_screen.dart';
import '../screens/edit_about_screen.dart';
import '../screens/edit_tags_screen.dart';
import '../screens/edit_entries_screen.dart';
import '../screens/applicant_detail_screen.dart';
import '../screens/edit_startup_screen.dart';
import 'package:hatch/screens/applicant_detail_screen.dart';
import 'package:hatch/models/application.dart';

class Routes {
  Routes._();
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const onboarding = '/onboarding';
  static const opportunityDetail = '/opportunity';
  static const postOpportunity = '/founder/roles/post-opportunity';
  // Student shell tabs
  static const studentHome = '/student/home';
  static const discover = '/student/discover';
  static const applications = '/student/applications';
  static const studentProfile = '/student/profile';
  // Founder shell tabs
  static const founderHome = '/founder/home';
  static const founderRoles = '/founder/roles';
  static const founderApplicants = '/founder/applicants';
  static const founderProfile = '/founder/profile';
  //edit profile tabs
  static const editAbout = '/profile/about';
  static const editSkills = '/profile/skills';
  static const editInterests = '/profile/interests';
  static const editExperience = '/profile/experience';
  static const editEducation = '/profile/education';
  static const editStartup = '/profile/startup';
  // Applicant detail
  static const applicantDetail = '/applicant';
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

      final user = ref.read(currentUserProvider).value;
      final hasProfile = user != null;

      if (!hasProfile && loc != Routes.onboarding) return Routes.onboarding;

      if (hasProfile && (onPublicScreen || loc == Routes.onboarding)) {
        return user.role == UserRole.founder
            ? Routes.founderHome
            : Routes.studentHome;
      }

      return null;
    },
    routes: [
      GoRoute(path: Routes.welcome, builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: Routes.signup, builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: Routes.opportunityDetail,
        builder: (_, state) =>
            OpportunityDetailScreen(opportunity: state.extra as Opportunity),
      ),
      // ── Profile edit screens (pushed on top of the shell) ─────────────────
      GoRoute(
        path: Routes.editAbout,
        builder: (_, __) => const EditAboutScreen(),
      ),
      GoRoute(
        path: Routes.editSkills,
        builder: (_, __) => EditTagsScreen(
          title: 'Skills',
          field: 'skills',
          readTags: (u) => (u as AppUser).skills,
        ),
      ),
      GoRoute(
        path: Routes.editInterests,
        builder: (_, __) => EditTagsScreen(
          title: 'Interests',
          field: 'interests',
          readTags: (u) => (u as AppUser).interests,
        ),
      ),
      GoRoute(
        path: Routes.editExperience,
        builder: (_, __) => EditEntriesScreen(
          title: 'Experience',
          field: 'experience',
          readEntries: (u) => (u as AppUser).experience,
        ),
      ),
      GoRoute(
        path: Routes.editEducation,
        builder: (_, __) => EditEntriesScreen(
          title: 'Education',
          field: 'education',
          readEntries: (u) => (u as AppUser).education,
        ),
      ),
      GoRoute(
        path: Routes.editStartup,
        builder: (_, __) => const EditStartupScreen(),
      ),
      GoRoute(
        path: Routes.applicantDetail,
        builder: (c, s) =>
            ApplicantDetailScreen(application: s.extra as Application),
      ),
      // ── Student shell ─────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            StudentShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.studentHome,
                builder: (_, __) => const StudentHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.discover,
                builder: (_, __) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.applications,
                builder: (_, __) => const ApplicationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.studentProfile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Founder shell ─────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            FounderShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.founderHome,
                builder: (_, __) => const FounderHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.founderRoles,
                builder: (_, __) => const FounderRolesScreen(),
                routes: [
                  GoRoute(
                    path: 'post-opportunity',
                    builder: (_, __) => const PostOpportunityScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.founderApplicants,
                builder: (_, __) => const FounderApplicantsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.founderProfile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
