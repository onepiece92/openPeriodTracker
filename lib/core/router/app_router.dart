import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/doctor_view.dart';
import '../../features/calendar/calendar_view.dart';
import '../../features/insights/insights_view.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/diagnosis/diagnosis_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/yoga/yoga_screen.dart';

GoRouter createRouter({required bool isOnboarded}) {
  return GoRouter(
    initialLocation: isOnboarded ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              ShellRoute(
                builder: (context, state, child) => HomeScreen(child: child),
                routes: [
                  GoRoute(
                    path: '/home',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: CalendarView(key: ValueKey('calendar')),
                    ),
                  ),
                  GoRoute(
                    path: '/home/doctor',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: DoctorView(key: ValueKey('doctor')),
                    ),
                  ),
                  GoRoute(
                    path: '/home/insights',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: InsightsView(key: ValueKey('insights')),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AnalyticsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/yoga',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: YogaScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diagnosis',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DiagnosisScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
