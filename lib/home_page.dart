import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  String buttonText = "Start Sensor";
  bool collectingData = false;

  Column accelerationStack(AccelerometerEvent event) {
    return Column(
      children: [
        Text('X: ${event.x}',
        style: Theme.of(context).textTheme.bodyMedium),
        Text('Y: ${event.y}',
            style: Theme.of(context).textTheme.bodyMedium),
        Text('Z: ${event.z}',
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  void toggleDataCollection() {
    setState(() {
      collectingData = !collectingData;
      buttonText = collectingData ? "Stop Sensor" : "Start Sensor";
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Text(
                'User Acceleration:',
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
            accelerationStack(AccelerometerEvent(0.0, 0.0, 0.0)),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                  'Gravity:',
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
            accelerationStack(AccelerometerEvent(0.0, 0.0, 0.0)),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                  'Vertical Acceleration:',
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
            Text(
              '0.0',
                style: Theme.of(context).textTheme.bodyMedium
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: TextButton(
                  onPressed: toggleDataCollection,
                style: textButtonStyle(context),
                child: Text(buttonText),


              ),
            ),
          ],
        ),
      ),
    );
  }
}