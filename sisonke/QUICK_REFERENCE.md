# Sisonke App - Quick Reference Guide

## Screen Routes Cheat Sheet

### Main Navigation Tabs
```
/home           → Home Dashboard
/resources      → Resources Hub
/check-in       → Daily Check-In / Mood
/support        → Support Directory
/settings       → Settings & Privacy
```

### Feature Routes
```
# Emergency
/emergency              → Emergency Toolkit
/emergency/safety-plan → Safety Plan
/emergency/grounding   → Grounding Exercise

# Wellness
/breathing             → Breathing Exercise
/safety-plan           → My Safety Plan
/grounding             → Grounding Session

# Tracking
/check-in/mood         → Mood History
/check-in/journal      → Journal Entries
/check-in/recovery     → Sobriety Tracker

# Community
/qa                    → Browse Questions
/qa/ask                → Ask Question

# Utility
/notifications         → Notifications
/bookmarks             → Saved Items
/settings/privacy      → Privacy Center
```

## Widget Usage Examples

### Emergency Button (Everywhere)
```dart
EmergencyHelpButton(
  onPressed: () => context.push('/emergency'),
)
```

### Custom Button
```dart
SisonkeButton(
  label: 'Continue',
  onPressed: () {},
  buttonType: ButtonType.primary,
  icon: Icons.arrow_forward,
)
```

### Custom Card
```dart
SisonkeCard(
  child: Text('Content here'),
  onTap: () {},
)
```

### Resource Card
```dart
ResourceCard(
  title: 'Article Title',
  category: 'Mental Health',
  imageUrl: 'https://...',
  onTap: () {},
  onSave: () {},
)
```

### Dialog Usage
```dart
// Confirm
await SisonkeDialogs.showConfirmDialog(
  context: context,
  title: 'Confirm',
  message: 'Are you sure?',
);

// Info
await SisonkeDialogs.showInfoDialog(
  context: context,
  title: 'Info',
  message: 'Information message',
);

// Sheet
await SisonkeDialogs.showSheet(
  context: context,
  builder: (context) => YourWidget(),
);

// Snackbar
SisonkeDialogs.showSnackbar(
  context: context,
  message: 'Done!',
);
```

### Text Field
```dart
SisonkeTextField(
  label: 'Email',
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Required';
    return null;
  },
)
```

## Provider Usage Examples

### Watching Providers
```dart
// In ConsumerWidget
@override
Widget build(BuildContext context, WidgetRef ref) {
  final resources = ref.watch(resourcesProvider);
  final moods = ref.watch(moodEntriesProvider);
  
  return Text(resources.length.toString());
}
```

### Updating Providers
```dart
// Update a provider
ref.read(resourcesProvider.notifier).state = newResources;

// Toggle theme
ref.read(themeModeProvider.notifier).state = ThemeMode.dark;

// Enable app lock
ref.read(appLockEnabledProvider.notifier).state = true;
```

### Computed Providers
```dart
// Filtered resources (auto-updates when resources or filter changes)
final resources = ref.watch(filteredResourcesProvider);

// Mood trends (auto-calculated)
final trends = ref.watch(moodTrendsProvider);
```

## Models Quick Reference

### Resource
```dart
Resource(
  id: 'res-1',
  title: 'Article Title',
  description: 'Short desc',
  category: ResourceCategory.mentalHealth,
  content: 'Full content...',
  imageUrl: 'https://...',
  createdAt: DateTime.now(),
)
```

### MoodEntry
```dart
MoodEntry(
  id: 'mood-1',
  mood: MoodType.great,
  timestamp: DateTime.now(),
  note: 'Feeling good today',
  energyLevel: 8,
)
```

### JournalEntry
```dart
JournalEntry(
  id: 'entry-1',
  title: 'My Day',
  content: 'Today was great...',
  createdAt: DateTime.now(),
  moodAtTime: 'great',
  isLocked: false,
)
```

### SafetyPlan
```dart
SafetyPlan(
  id: 'plan-1',
  warningSigns: ['Feeling alone', 'Overthinking'],
  copingStrategies: ['Call friend', 'Go for walk'],
  trustedPeople: [
    TrustedPerson(
      id: 'tp-1',
      name: 'Friend Name',
      phoneNumber: '+1234567890',
      relationship: 'Best friend',
    ),
  ],
  safePlaces: ['Park', 'Library'],
  createdAt: DateTime.now(),
)
```

### RecoveryEntry
```dart
RecoveryEntry(
  id: 'rec-1',
  type: RecoveryEventType.victory,
  timestamp: DateTime.now(),
  reflection: 'Stayed strong today',
  streakDays: 42,
)
```

### Question
```dart
Question(
  id: 'q-1',
  title: 'How to manage stress?',
  description: 'I struggle with...',
  category: ResourceCategory.mentalHealth,
  askedAt: DateTime.now(),
  isAnswered: true,
  answers: [
    Answer(
      id: 'a-1',
      content: 'Try meditation...',
      expertName: 'Dr. Smith',
      answeredAt: DateTime.now(),
    ),
  ],
)
```

## Creating a New Screen

### Step 1: Create Screen File
```dart
// lib/features/[feature]/[feature]_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/shared/widgets/index.dart';

class YourScreen extends ConsumerWidget {
  const YourScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: SisonkeAppBar(
        title: 'Screen Title',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Your widgets here
            ],
          ),
        ),
      ),
      floatingActionButton: EmergencyHelpButton(
        onPressed: () => context.push('/emergency'),
      ),
    );
  }
}
```

### Step 2: Add Route to Router
```dart
// In lib/app/router/router.dart
GoRoute(
  path: '/your-route',
  builder: (context, state) => const YourScreen(),
),
```

### Step 3: Create Provider (if needed)
```dart
// lib/features/[feature]/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final yourDataProvider = StateProvider<YourData>((ref) => YourData());
```

## Theme/Styling

### Colors
Primary color from theme:
```dart
Theme.of(context).primaryColor
Colors.red.shade600        // Danger
Colors.grey.shade300       // Disabled
```

### Text Styles
```dart
Theme.of(context).textTheme.headlineSmall
Theme.of(context).textTheme.titleLarge
Theme.of(context).textTheme.titleMedium
Theme.of(context).textTheme.bodyLarge
Theme.of(context).textTheme.bodySmall
```

### Spacing
Standard:
```dart
const SizedBox(height: 8)   // Small
const SizedBox(height: 12)  // Medium
const SizedBox(height: 16)  // Large
const SizedBox(height: 24)  // Extra large
```

### Border Radius
```dart
BorderRadius.circular(8)    // Cards
BorderRadius.circular(12)   // Buttons
BorderRadius.circular(20)   // Bottom sheets
```

## Testing Navigation

```bash
# Run with hot reload
flutter run

# Test specific route
flutter run --route=/resources

# Test on specific device/browser
flutter run -d chrome      # Web
flutter run -d emulator    # Android
```

## Debugging Tips

### Check all routes
Look in `lib/app/router/router.dart` for complete route list

### Screen not showing?
1. Check if route is registered in router
2. Verify screen file exists
3. Check for compile errors: `flutter analyze`

### Provider not updating?
1. Make sure you're using `ref.watch()` not `ref.read()`
2. Check provider is notifier type for updates
3. Use `ref.refresh()` to force update

### Widget not rebuilding?
1. Wrap in `Consumer` or use `ConsumerWidget`
2. Also watch the provider: `ref.watch(provider)`
3. Check setState/riverpod syntax

## Common Tasks

### Add New Resource Category
```dart
// In lib/shared/models/resource.dart
enum ResourceCategory {
  yourCategory('Your Category'),
}
```

### Add New Mood Type
```dart
// In lib/shared/models/mood.dart
enum MoodType {
  yourMood('Label', '😊'),
}
```

### Add New Screen to Tab
1. Create screen file in feature folder
2. Add route to router in corresponding tab branch
3. Screen will appear when tab is selected

### Lock a Screen (Behind App Lock)
Future implementation - check PrivacyCenter

### Add Offline Support
Use Isar database in your Provider:
```dart
final data = await isar.yourObjects.where().findAll();
```

---

**Last Updated:** April 27, 2026
**Status:** Phase 1 Complete ✅

