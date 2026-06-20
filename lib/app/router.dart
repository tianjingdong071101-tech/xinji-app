import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/timeline/timeline_screen.dart';
import '../presentation/screens/write/write_screen.dart';
import '../presentation/screens/insights/insights_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/detail/diary_detail_screen.dart';
import '../domain/model/diary_entry.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/timeline',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/timeline',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const TimelineScreen(),
          ),
        ),
        GoRoute(
          path: '/insights',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const InsightsScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const ProfileScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/write',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WriteScreen(),
    ),
    GoRoute(
      path: '/diary/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final entry = state.extra as DiaryEntry;
        return DiaryDetailScreen(entry: entry);
      },
    ),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (i) {
          switch (i) {
            case 0: context.go('/timeline');
            case 1: context.go('/insights');
            case 2: context.go('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: '时间线'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: '洞察'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/write'),
        child: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/timeline')) return 0;
    if (location.startsWith('/insights')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }
}
