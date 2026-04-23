import 'package:flutter/material.dart';

class DummyScreen extends StatelessWidget {
  final String title;

  const DummyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          "This is the $title screen.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
