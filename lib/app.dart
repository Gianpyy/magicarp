import 'package:flutter/material.dart';
import 'console_widget.dart';

class SensingApp extends StatelessWidget {
  const SensingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Magicarp",
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const ConsolePage(title: "Magicarp"),
    );
  }
  
}