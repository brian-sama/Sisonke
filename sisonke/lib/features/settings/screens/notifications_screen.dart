import 'package:flutter/material.dart';
import 'package:sisonke/shared/widgets/index.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SisonkeAppBar(title: 'Notifications'),
      body: Center(child: Text('Notifications Placeholder')),
    );
  }
}
