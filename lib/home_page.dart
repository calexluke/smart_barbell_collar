import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'sensor_manager.dart';
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
  String buttonText = "Start Sensor";
  bool collectingData = false;

  Timer? sampleRateTimer;

  // subscription variables for sensor stream
  Acceleration _latestAccelerometerValue = Acceleration(0, 0, 0);
  Acceleration _latestUserAccelerometerValue = Acceleration(0, 0, 0);
  Acceleration _latestGravityValue = Acceleration(0, 0, 0);
  double _verticalAcceleration = 0.0;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

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
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Text(
                'Total Acceleration:',
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
            accelerationStack(_latestAccelerometerValue),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                  'Gravity:',
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
            accelerationStack(_latestGravityValue),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                  'Vertical Acceleration:',
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
            Text(
              _verticalAcceleration.toStringAsFixed(2),
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

  @override
  void dispose() {
    super.dispose();
    cancelSensorSubscriptions();
  }

  Column accelerationStack(Acceleration event) {
    return Column(
      children: [
        Text('X: ${event.x.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium),
        Text('Y: ${event.y.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium),
        Text('Z: ${event.z.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  // TODO: move all this sensor functionality into SensorManager

  // sensor subscription methods
  void subscribeToSensors() {
    // subscribe to total acceleration
    _streamSubscriptions.add(
      accelerometerEvents.listen(
            (AccelerometerEvent event) {
          setState(() {
            _latestAccelerometerValue = Acceleration(event.x, event.y, event.z);
          });
        },
      ),
    );

    // subscribe to user acceleration, calculate gravity
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
            (UserAccelerometerEvent event) {

              // calculate gravity: total acceleration - user acceleration
              Acceleration gravity = Acceleration(
                  _latestAccelerometerValue.x - event.x,
                  _latestAccelerometerValue.y - event.y,
                  _latestAccelerometerValue.z - event.z);
          setState(() {
            _latestGravityValue = gravity;
            _latestUserAccelerometerValue = Acceleration(event.x, event.y, event.z);
          });
        },
      ),
    );

    sampleRateTimer = Timer.periodic(
        Duration(milliseconds: accelerationSampleRateMS),
            (timer) => updateVerticalAcceleration());
  }

  void cancelSensorSubscriptions() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }

    sampleRateTimer?.cancel();
  }

  void updateVerticalAcceleration() {
    double verticalAcceleration = getVerticalAcceleration(_latestUserAccelerometerValue, _latestGravityValue);
    setState(() {
      _verticalAcceleration = verticalAcceleration;
    });
  }

  double getVerticalAcceleration(Acceleration userAccel, Acceleration gravity) {

    // calculate the vertical acceleration magnitude - user acceleration in the opposite direction from gravity

    double ax = userAccel.x;
    double ay = userAccel.y;
    double az = userAccel.z;

    double gx = gravity.x;
    double gy = gravity.y;
    double gz = gravity.z;

    double gravityMagnitude = sqrt(pow(gx, 2) + pow(gy, 2) + pow(gz, 2));

    // projection of acceleration in the opposite direction of gravity
    double dotProduct = (ax * gx) + (ay * gy) + (az * gz);
    double scaledResult = (dotProduct / gravityMagnitude) * -1.0;

    return scaledResult;
  }


  void toggleDataCollection() {
    setState(() {
      collectingData = !collectingData;
      buttonText = collectingData ? "Stop Sensor" : "Start Sensor";
    });

    if (collectingData) {
      subscribeToSensors();
    } else {
      cancelSensorSubscriptions();
    }
  }
}