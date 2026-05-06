import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:sisonke/core/services/local_database_service.dart';
import 'package:sisonke/core/services/providers.dart';
import 'package:sisonke/router/router.dart';
import 'package:sisonke/theme/app_theme.dart';
import 'package:sisonke/core/providers/app_providers.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/core/services/bootstrap_content_service.dart';
import 'package:sisonke/core/services/public_content_sync_service.dart';
import 'package:sisonke/core/services/push_notification_service.dart';
import 'package:sisonke/core/services/widget_service.dart';
import 'package:sisonke/l10n/app_localizations.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      const dsn = String.fromEnvironment('SENTRY_DSN');
      options.dsn = dsn;
      options.tracesSampleRate = kReleaseMode ? 0.1 : 1.0;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await WidgetService.setup();

      final sharedPreferences = await SharedPreferences.getInstance();
      final bootstrapContentService = BootstrapContentService(
        sharedPreferences,
      );
      await bootstrapContentService.ensureSeeded();

      final localDatabaseService = LocalDatabaseService();
      try {
        await localDatabaseService.init();
      } catch (e, stackTrace) {
        await Sentry.captureException(e, stackTrace: stackTrace);
      }

      PublicContentSyncService(
        ApiService(),
        bootstrapContentService,
        sharedPreferences,
      ).sync().catchError((Object e, StackTrace stackTrace) async {
        if (kDebugMode) debugPrint('Public content sync skipped: $e');
        await Sentry.captureException(e, stackTrace: stackTrace);
      });

      PushNotificationService(ApiService()).initialize().catchError((
        Object e,
        StackTrace stackTrace,
      ) async {
        if (kDebugMode) debugPrint('Push notification setup skipped: $e');
        await Sentry.captureException(e, stackTrace: stackTrace);
      });

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            localDatabaseServiceProvider.overrideWithValue(
              localDatabaseService,
            ),
          ],
          child: const MyApp(),
        ),
      );
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onHide: () {
        _flushNavigationStack();
      },
      onPause: () {
        _flushNavigationStack();
      },
    );
  }

  Future<void> _flushNavigationStack() async {
    // Security Feature: Instant quick-exit when backgrounded or dropped
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinEnabled = prefs.getBool(AppConstants.pinEnabledKey) ?? false;
      router.go(pinEnabled ? '/app-lock' : '/home');
    } catch (e) {
      debugPrint('Lifecycle flush failed: $e');
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sisonke',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('sn'), Locale('nd')],
    );
  }
}
