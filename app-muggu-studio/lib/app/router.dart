import 'package:go_router/go_router.dart';

import '../features/create/presentation/create_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/design/presentation/design_detail_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/saved/presentation/saved_screen.dart';
import 'shell/app_shell.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/design/:designId',
            builder: (context, state) =>
                DesignDetailScreen(designId: state.pathParameters['designId']!),
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
