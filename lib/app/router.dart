import 'package:go_router/go_router.dart';

import '../features/history/view/history_screen.dart';
import '../features/records/view/records_screen.dart';
import '../features/session_detail/view/session_detail_screen.dart';
import '../features/settings/view/settings_screen.dart';
import '../features/tracking/view/home_screen.dart';
import '../core/models/session.dart';
import 'app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        // ── Tab 0: Tracking ───────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // ── Tab 1: History ────────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final session = state.extra as Session;
                    return SessionDetailScreen(session: session);
                  },
                ),
              ],
            ),
          ],
        ),

        // ── Tab 2: Records ────────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/records',
              builder: (context, state) => const RecordsScreen(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final session = state.extra as Session;
                    return SessionDetailScreen(session: session);
                  },
                ),
              ],
            ),
          ],
        ),

        // ── Tab 3: Settings ───────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
