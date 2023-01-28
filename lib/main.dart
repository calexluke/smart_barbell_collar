import 'package:flutter/material.dart';
import 'sensor_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Barbell Collar',
      theme: ThemeData.dark().copyWith(
        colorScheme: ThemeData.dark().colorScheme.copyWith(
            secondary: Colors.blueGrey,
        )
      ),
      home: const SensorViewPage(title: 'Smart Barbell Collar'),
    );
  }
}
