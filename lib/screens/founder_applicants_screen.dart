import 'package:flutter/material.dart';

class FounderApplicantsScreen extends StatelessWidget {
  const FounderApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: Center(
        child: Text('Applicants to your roles will appear here.',
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}