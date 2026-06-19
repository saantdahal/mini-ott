import 'package:flutter/material.dart';
import 'package:miniott/shared/widgets/back_button.dart';

class WatchLaterScreen extends StatelessWidget {
  const WatchLaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved for Later'),
        leading: CustomIconButton(icon: Icons.arrow_back_ios_rounded),
      ),
      body: const Center(child: Text('No saved titles yet.')),
    );
  }
}
