import 'package:flutter/material.dart';
import 'dashboard.dart'; // Import de la page du dashboard

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DîneView',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: Dashboard(), // Lancer directement le dashboard
    );
  }
}
