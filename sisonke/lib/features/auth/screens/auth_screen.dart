import 'package:flutter/material.dart';
import 'package:sisonke/shared/widgets/index.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SisonkeAppBar(title: 'Authentication'),
      body: Center(child: Text('Login/Register Screen Placeholder')),
    );
  }
}
