import 'package:flutter/material.dart';
import 'package:github_api/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(primary: Colors.black),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}