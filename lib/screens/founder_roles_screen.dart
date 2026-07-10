import 'package:flutter/material.dart';

class FounderRolesScreen extends StatelessWidget {
  const FounderRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My roles')),
      body: Center(
        child: Text('Your posted roles will appear here.',
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}