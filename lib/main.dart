import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const VocatchApp());
}

class VocatchApp extends StatelessWidget {
  const VocatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocatch',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocatch'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Vocatch!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '외국어 단어 학습 앱',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
