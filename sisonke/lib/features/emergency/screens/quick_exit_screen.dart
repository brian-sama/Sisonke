import 'package:flutter/material.dart';
import 'package:sisonke/shared/widgets/index.dart';

class QuickExitScreen extends StatelessWidget {
  const QuickExitScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SisonkeAppBar(title: 'Quick Exit Settings'),
      body: Center(child: Text('Quick Exit Placeholder')),
    );
  }
}
