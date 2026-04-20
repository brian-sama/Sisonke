import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/features/auth/auth_state.dart';
import 'package:sisonke/shared/models/user.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sisonke'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authStateProvider.notifier).signOut(),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user != null
                  ? 'Welcome${user.displayName != null ? ', ${user.displayName}' : ''}!'
                  : 'Welcome to Sisonke',
            ),
            const SizedBox(height: 20),
            if (user == null) ...[
              ElevatedButton(
                onPressed: () => ref.read(authStateProvider.notifier).signInAnonymously(),
                child: const Text('Continue as Guest'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _showSignInDialog(context, ref),
                child: const Text('Sign In'),
              ),
            ] else ...[
              Text('User ID: ${user.id}'),
              Text('Is Guest: ${user.isGuest}'),
            ],
          ],
        ),
      ),
    );
  }

  void _showSignInDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(authStateProvider.notifier).signInWithEmail(
                  emailController.text,
                  passwordController.text,
                );
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}