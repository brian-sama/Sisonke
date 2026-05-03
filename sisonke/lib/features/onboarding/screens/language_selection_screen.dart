import 'package:flutter/material.dart';
import 'package:sisonke/shared/widgets/index.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SisonkeAppBar(title: 'Language'),
      body: Center(child: Text('Language Selection Placeholder')),
    );
  }
}
