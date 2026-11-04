import 'package:flutter/material.dart';

void main() {
  runApp(const AwadyMusicApp());
}

class AwadyMusicApp extends StatelessWidget {
  const AwadyMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awady Music',
      theme: ThemeData(
        fontFamily: 'Inter',
        fontFamilyFallback: const ['IBMPlexSansArabic'],
      ),
      home: const Scaffold(),
    );
  }
}
