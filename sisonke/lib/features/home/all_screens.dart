import 'package:flutter/material.dart';
import 'package:sisonke/shared/widgets/index.dart';

/// Placeholder screens for features
/// These will be fully implemented in subsequent phases

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Resources',
      ),
      body: Center(
        child: Text(
          'Resources Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class ResourceDetailScreen extends StatelessWidget {
  final String resourceId;

  const ResourceDetailScreen({
    Key? key,
    required this.resourceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Resource',
      ),
      body: Center(
        child: Text(
          'Resource Detail Screen: $resourceId',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Daily Check-In',
      ),
      body: Center(
        child: Text(
          'Check-In Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Mood Tracker',
      ),
      body: Center(
        child: Text(
          'Mood Tracker Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class JournalScreen extends StatelessWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Journal',
      ),
      body: Center(
        child: Text(
          'Journal Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class EmergencyToolkitScreen extends StatelessWidget {
  const EmergencyToolkitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Emergency Toolkit',
      ),
      body: Center(
        child: Text(
          'Emergency Toolkit Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class SafetyPlanScreen extends StatelessWidget {
  const SafetyPlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Safety Plan',
      ),
      body: Center(
        child: Text(
          'Safety Plan Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class BreathingExerciseScreen extends StatelessWidget {
  const BreathingExerciseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Breathing Exercise',
      ),
      body: Center(
        child: Text(
          'Breathing Exercise Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class GroundingExerciseScreen extends StatelessWidget {
  const GroundingExerciseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Grounding Exercise',
      ),
      body: Center(
        child: Text(
          'Grounding Exercise Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class QAScreen extends StatelessWidget {
  const QAScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Ask Anonymously',
      ),
      body: Center(
        child: Text(
          'Q&A Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class AskQuestionScreen extends StatelessWidget {
  const AskQuestionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Ask Question',
      ),
      body: Center(
        child: Text(
          'Ask Question Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class SupportDirectoryScreen extends StatelessWidget {
  const SupportDirectoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Support Directory',
      ),
      body: Center(
        child: Text(
          'Support Directory Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Saved Items',
      ),
      body: Center(
        child: Text(
          'Bookmarks Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Notifications',
      ),
      body: Center(
        child: Text(
          'Notifications Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Settings',
      ),
      body: Center(
        child: Text(
          'Settings Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class PrivacyCenterScreen extends StatelessWidget {
  const PrivacyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Privacy Center',
      ),
      body: Center(
        child: Text(
          'Privacy Center Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class SobrietyTrackerScreen extends StatelessWidget {
  const SobrietyTrackerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Recovery Tracker',
      ),
      body: Center(
        child: Text(
          'Sobriety Tracker Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class TopicSelectionScreen extends StatelessWidget {
  const TopicSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Select Topics',
        showBackButton: false,
      ),
      body: Center(
        child: Text(
          'Topic Selection Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Sign In',
      ),
      body: Center(
        child: Text(
          'Auth Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Language',
      ),
      body: Center(
        child: Text(
          'Language Selection Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class AppLockScreen extends StatelessWidget {
  const AppLockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'App Lock',
      ),
      body: Center(
        child: Text(
          'App Lock Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class QuickExitScreen extends StatelessWidget {
  const QuickExitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Quick Exit',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}



