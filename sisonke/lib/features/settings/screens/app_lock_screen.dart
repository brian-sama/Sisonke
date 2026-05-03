import 'package:flutter/material.dart';
import 'package:sisonke/shared/widgets/index.dart';

class AppLockScreen extends StatelessWidget {
  const AppLockScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SisonkeAppBar(title: 'App Lock'),
      body: Center(child: Text('App Lock Placeholder')),
    );
  }
}
