import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/split_now_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/page_transitions.dart';
import 'theme/app_theme.dart';

class PloyApp extends StatelessWidget {
  PloyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ploy',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/split',
        pageBuilder: (context, state) => SlideFromRightTransition(
          key: state.pageKey,
          child: const SplitNowScreen(),
        ),
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) => SlideFromRightTransition(
          key: state.pageKey,
          child: const HistoryScreen(),
        ),
      ),
      GoRoute(
        path: '/history/:id',
        pageBuilder: (context, state) {
          final sessionId = state.pathParameters['id']!;
          return SlideFromRightTransition(
            key: state.pageKey,
            child: HistoryScreen(sessionId: sessionId),
          );
        },
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
    ],
  );
}
