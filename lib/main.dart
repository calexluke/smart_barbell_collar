import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_barbell_collar/home_view.dart';
import 'package:provider/provider.dart';
import 'calibration_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ChangeNotifierProvider(
      create: (BuildContext context) => CalibrationData(),
      child: MaterialApp(
        title: 'Smart Barbell Collar',
        theme: ThemeData.dark().copyWith(
          colorScheme: ThemeData.dark().colorScheme.copyWith(
              secondary: Colors.blueGrey,
          )
        ),
        home: const HomeView(title: 'Smart Barbell Collar'),
      ),
    );
  }
}
