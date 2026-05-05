import 'package:flutter/foundation.dart';

class AppConstants {
  // API Configuration
  static String get apiBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (kReleaseMode) return 'https://sisonke.mmpzmne.co.zw/api';
    return devApiBaseUrl;
  }

  static String get devApiBaseUrl {
    // Since the backend is running on the VPS, we point to the production domain
    return 'https://sisonke.mmpzmne.co.zw/api';
  }

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String deviceIdKey = 'device_id';
  
  // App Configuration
  static const String appName = 'Sisonke';
  static const String appVersion = '1.0.0';
  static const bool isDebugMode = kDebugMode;
  
  // Resource Categories
  static const List<String> resourceCategories = [
    'mental-health',
    'srhr',
    'emergency',
    'substance-use',
    'wellness',
    'guide',
  ];
  
  static const Map<String, String> categoryDisplayNames = {
    'mental-health': 'Mental Health',
    'srhr': 'SRHR',
    'emergency': 'Emergency Support',
    'substance-use': 'Substance Use',
    'wellness': 'General Wellness',
    'guide': 'Guides',
  };
  
  // Q&A Categories
  static const List<String> questionCategories = [
    'mental-health',
    'srhr',
    'emergency',
    'relationships',
    'general',
  ];
  
  static const Map<String, String> questionCategoryDisplayNames = {
    'mental-health': 'Mental Health',
    'srhr': 'SRHR',
    'emergency': 'Emergency',
    'relationships': 'Relationships',
    'general': 'General',
  };
  
  // Mood Options
  static const List<String> moodOptions = [
    'great',
    'okay',
    'low',
    'anxious',
    'angry',
    'overwhelmed',
  ];
  
  static const Map<String, String> moodDisplayNames = {
    'great': 'Great',
    'okay': 'Okay',
    'low': 'Low',
    'anxious': 'Anxious',
    'angry': 'Angry',
    'overwhelmed': 'Overwhelmed',
  };
  
  static const Map<String, String> moodEmojis = {
    'great': '😊',
    'okay': '😐',
    'low': '😔',
    'anxious': '😰',
    'angry': '😠',
    'overwhelmed': '😵',
  };
  
  // Emergency Contact Categories
  static const List<String> emergencyCategories = [
    'crisis',
    'mental-health',
    'srhr',
    'general',
  ];
  
  static const Map<String, String> emergencyCategoryDisplayNames = {
    'crisis': 'Crisis Hotlines',
    'mental-health': 'Mental Health',
    'srhr': 'SRHR Services',
    'general': 'General Support',
  };
  
  // Zimbabwe Emergency Numbers
  static const Map<String, String> zimbabweEmergencyNumbers = {
    'lifeline': '+263 292 62 662',
    'alac': '+263 242 307 048',
    'mental_welfare': '+263 772 123 456',
    'srhr_services': '+263 772 789 012',
  };
  
  // App Colors
  static const String primaryColor = '#2E7D32'; // Green
  static const String secondaryColor = '#1976D2'; // Blue
  static const String accentColor = '#F57C00'; // Orange
  static const String errorColor = '#D32F2F'; // Red
  static const String backgroundColor = '#FAFAFA';
  static const String surfaceColor = '#FFFFFF';
  
  // Text Sizes
  static const double textXSmall = 12.0;
  static const double textSmall = 14.0;
  static const double textMedium = 16.0;
  static const double textLarge = 18.0;
  static const double textXLarge = 20.0;
  static const double textXXLarge = 24.0;
  
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  
  // Animation Durations
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Settings
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 50; // MB
  
  // Security
  static const int maxLoginAttempts = 3;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // Local Storage Keys
  static const String bookmarksKey = 'bookmarks';
  static const String offlineResourcesKey = 'offline_resources';
  static const String moodHistoryKey = 'mood_history';
  static const String journalEntriesKey = 'journal_entries';
  static const String userPreferencesKey = 'user_preferences';
  static const String lastSyncKey = 'last_sync';
  
  // Notification Settings
  static const String dailyReminderKey = 'daily_reminder';
  static const String notificationTimeKey = 'notification_time';
  static const String enableNotificationsKey = 'enable_notifications';
  
  // Privacy Settings
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String pinEnabledKey = 'pin_enabled';
  static const String quickExitEnabledKey = 'quick_exit_enabled';
  static const String dataCollectionKey = 'data_collection';
}
