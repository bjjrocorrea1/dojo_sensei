import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const DojoSenseiApp());
}

class DojoSenseiApp extends StatelessWidget {
  const DojoSenseiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dojo Sensei',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}