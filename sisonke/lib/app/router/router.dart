import 'package:go_router/go_router.dart';
import 'package:sisonke/app/router/bottom_navigation_shell.dart';
import 'package:sisonke/features/onboarding/splash_screen.dart';
import 'package:sisonke/features/onboarding/onboarding_screen.dart';
import 'package:sisonke/features/home/all_screens.dart' show
    AppLockScreen,
    AuthScreen,
    LanguageSelectionScreen,
    NotificationsScreen,
    QuickExitScreen,
    TopicSelectionScreen;
import 'package:sisonke/features/home/home_screen.dart';
import 'package:sisonke/features/resources/screens/resources_screen.dart';
import 'package:sisonke/features/resources/screens/resource_detail_screen.dart';
import 'package:sisonke/features/qa/screens/qa_screen.dart';
import 'package:sisonke/features/qa/screens/ask_question_screen.dart';
import 'package:sisonke/features/qa/screens/question_detail_screen.dart';
import 'package:sisonke/features/emergency/screens/emergency_toolkit_screen.dart';
import 'package:sisonke/features/emergency/screens/safety_plan_screen.dart';
import 'package:sisonke/features/emergency/screens/grounding_exercise_screen.dart';
import 'package:sisonke/features/emergency/screens/breathing_exercise_screen.dart';
import 'package:sisonke/features/checkin/screens/check_in_screen.dart';
import 'package:sisonke/features/checkin/screens/mood_tracker_screen.dart';
import 'package:sisonke/features/checkin/screens/journal_screen.dart';
import 'package:sisonke/features/checkin/screens/sobriety_tracker_screen.dart';
import 'package:sisonke/features/support/screens/support_directory_screen.dart';
import 'package:sisonke/features/support/screens/bookmarks_screen.dart';
import 'package:sisonke/features/settings/screens/settings_screen.dart';
import 'package:sisonke/features/settings/screens/privacy_center_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    /// ==================== Onboarding & Auth ====================
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/topic-selection',
      builder: (context, state) => const TopicSelectionScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/app-lock',
      builder: (context, state) => const AppLockScreen(),
    ),
    GoRoute(
      path: '/quick-exit',
      builder: (context, state) => const QuickExitScreen(),
    ),

    /// ==================== Main Navigation Tabs ====================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavigationShell(
          navigationShell: navigationShell,
          child: navigationShell,
        );
      },
      branches: [
        /// ========== Home Tab ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'resources/:resourceId',
                  builder: (context, state) => ResourceDetailScreen(
                    resourceId: state.pathParameters['resourceId']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        /// ========== Resources Tab ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/resources',
              builder: (context, state) => const ResourcesScreen(),
              routes: [
                GoRoute(
                  path: ':resourceId',
                  builder: (context, state) => ResourceDetailScreen(
                    resourceId: state.pathParameters['resourceId']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        /// ========== Check-In Tab ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/check-in',
              builder: (context, state) => const CheckInScreen(),
              routes: [
                GoRoute(
                  path: 'mood',
                  builder: (context, state) => const MoodTrackerScreen(),
                ),
                GoRoute(
                  path: 'journal',
                  builder: (context, state) => const JournalScreen(),
                ),
                GoRoute(
                  path: 'recovery',
                  builder: (context, state) => const SobrietyTrackerScreen(),
                ),
              ],
            ),
          ],
        ),

        /// ========== Support Tab ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/support',
              builder: (context, state) => const SupportDirectoryScreen(),
              routes: [
                GoRoute(
                  path: 'directory',
                  builder: (context, state) => const SupportDirectoryScreen(),
                ),
                GoRoute(
                  path: 'bookmarks',
                  builder: (context, state) => const BookmarksScreen(),
                ),
              ],
            ),
          ],
        ),

        /// ========== Settings Tab ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'privacy',
                  builder: (context, state) => const PrivacyCenterScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    /// ==================== Feature Screens ====================
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyToolkitScreen(),
      routes: [
        GoRoute(
          path: 'safety-plan',
          builder: (context, state) => const SafetyPlanScreen(),
        ),
        GoRoute(
          path: 'grounding',
          builder: (context, state) => const GroundingExerciseScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/breathing',
      builder: (context, state) => const BreathingExerciseScreen(),
    ),
    GoRoute(
      path: '/safety-plan',
      builder: (context, state) => const SafetyPlanScreen(),
    ),
    GoRoute(
      path: '/grounding',
      builder: (context, state) => const GroundingExerciseScreen(),
    ),

    /// ==================== Q&A Routes ====================
    GoRoute(
      path: '/qa',
      builder: (context, state) => const QAScreen(),
      routes: [
        GoRoute(
          path: 'ask',
          builder: (context, state) => const AskQuestionScreen(),
        ),
        GoRoute(
          path: 'question/:questionId',
          builder: (context, state) => QuestionDetailScreen(
            questionId: state.pathParameters['questionId']!,
          ),
        ),
      ],
    ),

    /// ==================== Utility Screens ====================
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/bookmarks',
      builder: (context, state) => const BookmarksScreen(),
    ),
  ],
);
