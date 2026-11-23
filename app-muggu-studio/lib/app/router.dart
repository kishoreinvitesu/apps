import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_tab.dart';
import '../core/preferences/preferences_storage.dart';
import '../features/create/presentation/create_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/design/presentation/design_detail_screen.dart';
import '../features/design/presentation/practice_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/saved/presentation/saved_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'shell/app_shell.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final container = ProviderScope.containerOf(context, listen: false);
      final prefs =
          await container.read(userPreferencesProvider.future);
      final goingToOnboarding = state.uri.path == '/onboarding';
      if (!prefs.onboardingComplete && !goingToOnboarding) {
        return '/onboarding';
      }
      if (prefs.onboardingComplete && goingToOnboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      // Onboarding — outside the shell (no nav bar)
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Settings — outside the shell (full-screen with its own AppBar back)
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          currentPath: state.uri.path,
          selectedTab: appTabFromExtra(state.extra, state.uri.path),
          child: child,
        ),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/design/:designId',
            builder: (context, state) => DesignDetailScreen(
              designId: state.pathParameters['designId']!,
              originTab: appTabFromExtra(state.extra, '/explore'),
            ),
            routes: [
              GoRoute(
                path: 'practice',
                builder: (context, state) =>
                    PracticeScreen(designId: state.pathParameters['designId']!),
              ),
            ],
          ),
          GoRoute(
            path: '/create',
            builder: (context, state) => const CreateScreen(),
          ),
          GoRoute(
            path: '/saved',
            builder: (context, state) => const SavedScreen(),
          ),
        ],
      ),
    ],
  );
}
