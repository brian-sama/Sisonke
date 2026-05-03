import 'package:flutter/material.dart';
import 'package:sisonke/shared/widgets/index.dart';

class TopicSelectionScreen extends StatelessWidget {
  const TopicSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SisonkeAppBar(title: 'Choose Topics'),
      body: Center(child: Text('Topic Selection Placeholder')),
    );
  }
}
