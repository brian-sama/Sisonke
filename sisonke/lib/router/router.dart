import 'package:go_router/go_router.dart';
import 'package:sisonke/router/bottom_navigation_shell.dart';
import 'package:sisonke/features/onboarding/splash_screen.dart';
import 'package:sisonke/features/onboarding/onboarding_screen.dart';
// Note: TopicSelectionScreen, AuthScreen, etc. should be moved to their features.
// For now, I will import the ones I just moved.
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
import 'package:sisonke/features/checkin/screens/journal_entry_screen.dart';
import 'package:sisonke/features/checkin/screens/sobriety_tracker_screen.dart';
import 'package:sisonke/features/support/screens/support_directory_screen.dart';
import 'package:sisonke/features/support/screens/bookmarks_screen.dart';
import 'package:sisonke/features/settings/screens/settings_screen.dart';
import 'package:sisonke/features/settings/screens/privacy_center_screen.dart';
import 'package:sisonke/features/efriend/screens/efriend_screen.dart';
import 'package:sisonke/features/community/screens/community_feed_screen.dart';
import 'package:sisonke/features/counselor/screens/talk_to_counselor_screen.dart';
import 'package:sisonke/features/counselor/screens/case_chat_screen.dart';
import 'package:sisonke/features/counselor/screens/counselor_flow_screens.dart';
import 'package:sisonke/features/counselor/screens/counselor_mobile_workspace_screen.dart';
import 'package:sisonke/features/settings/screens/profile_safety_screen.dart';

// Placeholder imports for remaining deleted all_screens.dart members
// I will create these files next if they don't exist.
import 'package:sisonke/features/auth/screens/auth_screen.dart';
import 'package:sisonke/features/onboarding/screens/topic_selection_screen.dart';
import 'package:sisonke/features/onboarding/screens/language_selection_screen.dart';
import 'package:sisonke/features/settings/screens/notifications_screen.dart';
import 'package:sisonke/features/emergency/screens/quick_exit_screen.dart';
import 'package:sisonke/features/settings/screens/app_lock_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    /// ==================== Onboarding & Auth ====================
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/topic-selection',
      builder: (context, state) => const TopicSelectionScreen(),
    ),
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(
      path: '/counselor-mode',
      builder: (context, state) => const CounselorMobileWorkspaceScreen(),
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

        /// ========== E-Friend Tab ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/e-friend',
              builder: (context, state) => const EFriendScreen(),
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

        /// ========== Community Tab ==========
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              builder: (context, state) => const CommunityFeedScreen(),
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
    GoRoute(
      path: '/mood-tracker',
      builder: (context, state) => const MoodTrackerScreen(),
    ),
    GoRoute(
      path: '/private-journal',
      builder: (context, state) => const JournalScreen(),
    ),
    GoRoute(
      path: '/journal-entry',
      builder: (context, state) =>
          JournalEntryScreen(mode: state.uri.queryParameters['mode']),
    ),
    GoRoute(
      path: '/talk-to-counselor',
      builder: (context, state) => const TalkToCounselorScreen(),
    ),
    GoRoute(
      path: '/counselor-request',
      builder: (context, state) => const CounselorRequestScreen(),
    ),
    GoRoute(
      path: '/counselor-request-status/:caseId',
      builder: (context, state) =>
          CounselorRequestStatusScreen(caseId: state.pathParameters['caseId']!),
    ),
    GoRoute(
      path: '/callback-request/:caseId',
      builder: (context, state) =>
          CallbackRequestScreen(caseId: state.pathParameters['caseId']!),
    ),
    GoRoute(
      path: '/voice-note-request/:caseId',
      builder: (context, state) =>
          VoiceNoteRecorderScreen(caseId: state.pathParameters['caseId']!),
    ),
    GoRoute(
      path: '/case-history',
      builder: (context, state) => const CaseHistoryScreen(),
    ),
    GoRoute(
      path: '/emergency-escalation/:caseId',
      builder: (context, state) =>
          EmergencyEscalationScreen(caseId: state.pathParameters['caseId']!),
    ),
    GoRoute(
      path: '/live-chat/:caseId',
      builder: (context, state) => CaseChatScreen(
        caseId: state.pathParameters['caseId']!,
        title: (state.extra as Map?)?['title'] ?? 'Live Support',
      ),
    ),
    GoRoute(
      path: '/profile-safety',
      builder: (context, state) => const ProfileSafetyScreen(),
    ),
  ],
);
