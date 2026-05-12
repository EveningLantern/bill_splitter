import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/split_now_screen.dart';
import 'screens/history_screen.dart';
import 'screens/session_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

// ── Slide-from-right page transition ─────────────────────────────────────────
CustomTransitionPage<T> _slideTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeInOutCubic));
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: animation.drive(tween),
          child: child,
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class PloyApp extends StatelessWidget {
  PloyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ploy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      // /split — canonical path (also accepts legacy /split-now via redirect)
      GoRoute(
        path: '/split',
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const SplitNowScreen(),
        ),
      ),
      // Legacy redirect so existing context.push('/split-now') still works
      GoRoute(
        path: '/split-now',
        redirect: (_, __) => '/split',
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const HistoryScreen(),
        ),
        routes: [
          // /history/:id — full-page session detail
          GoRoute(
            path: ':id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _slideTransition(
                context: context,
                state: state,
                child: SessionDetailScreen(sessionId: id),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),
    ],
  );
}
