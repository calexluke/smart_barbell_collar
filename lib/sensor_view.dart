import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'sensor_manager.dart';
import 'constants.dart';
import 'file_handler.dart';
import'package:provider/provider.dart';
import 'calibration_data.dart';

class SensorViewPage extends StatefulWidget {
  const SensorViewPage({super.key, required this.title});

  final String title;

  @override
  State<SensorViewPage> createState() => _SensorViewPageState();
}

class _SensorViewPageState extends State<SensorViewPage> {
  String buttonText = "Start Sensor";
  bool collectingData = false;

  Timer? sampleRateTimer;

  // subscription variables for sensor stream
  Acceleration _latestAccelerometerValue = Acceleration(0, 0, 0);
  Acceleration _latestUserAccelerometerValue = Acceleration(0, 0, 0);
  Acceleration _latestGravityValue = Acceleration(0, 0, 0);
  // double peakVelocityDuringRep = 0.0;
  double _meanVelocityDuringRep = 0.0;
  String _resultText = "No result yet";

  List<SensorDataPoint> _verticalAccelerationData = [SensorDataPoint(0.0, DateTime.now())];
  int _selectedWeight = 135;
  int estimated1RMPercent = 0;
  int estimated1RMLoad = 0;


  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  FileHandler handler = FileHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false, // hides back button in app bar
        actions: [
          IconButton(
          onPressed: writeToCSVFile,
              icon: const Icon(Icons.ios_share))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            if (Provider.of<CalibrationData>(context).calibrationIsComplete(widget.title))...[
              Text(
                'Select Weight',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _selectedWeight.toString(),
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    Text(
                      ' lbs',
                      style: Theme.of(context).textTheme.headline5,
                    )
                  ]),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: const Color(0xFF8D8E98),
                    thumbColor: Theme.of(context).colorScheme.secondary,
                    overlayColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 15.0),
                    overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 25.0)),
                child: Slider(
                  value: _selectedWeight.toDouble(),
                  min: 45.0,
                  max: 585.0,
                  onChanged: (double newValue) {
                    int nearestFivePounds = roundedToNearest5(newValue);
                    // int intValue = newValue.round();
                    // int nearestFivePounds = (intValue ~/ 5) * 5;
                    setState(() {
                      _selectedWeight = nearestFivePounds;
                    });
                  },
                ),
              ),
            ] else ... [
              Text(
                'Calibration Rep at ${Provider.of<CalibrationData>(context).currentCalibrationPercent(widget.title)}% 1RM',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],

            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                  'Vertical Acceleration:',
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
            Text(
              _verticalAccelerationData.last.value.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodyMedium
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                  'Mean Velocity During Rep:',
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
            Text(
                _meanVelocityDuringRep.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodyMedium
            ),
    if (Provider.of<CalibrationData>(context).calibrationIsComplete(widget.title))...[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
              'Results:',
              style: Theme.of(context).textTheme.headline5
          ),
        ),
        Text(
            _resultText,
            style: Theme.of(context).textTheme.bodyMedium
        ),
      ],
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: TextButton(
                  onPressed: () => toggleDataCollection(context),
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

  void writeToCSVFile() async {
    // only write to file if some data has been collected.
    if (_verticalAccelerationData.length > 1) {
      handler.writeAccelerations(_verticalAccelerationData);
      handler.shareCSVFile();
    }
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
              // print("User acceleration: x: ${event.x} y: ${event.y} z: ${event.z}");
              // print("TotalAcceleration: x: ${_latestAccelerometerValue.x} y: ${_latestAccelerometerValue.y} z: ${_latestAccelerometerValue.z}");
              // print("Gravity: x: ${gravity.x} y: ${gravity.y} z: ${gravity.z}");
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
    SensorDataPoint dataPoint = SensorDataPoint(verticalAcceleration, DateTime.now());
    setState(() {
      _verticalAccelerationData.add(dataPoint);
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
    // sign issue: might need to multiply by -1
    double scaledResult = (dotProduct / gravityMagnitude);

    // debug print statements:
    // print("Calculate Vertical accelleration");
    // print("user accel: x: $ax y: $ay z: $az");
    // print("Gravity: x: $gx y: $gy z: $gz");
    // print("gravity magnitude: $gravityMagnitude");
    // print("dot product: $dotProduct");
    // print("scaled result: $scaledResult");

    if (scaledResult.isNaN) {
      return 0.0;
    } else {
      return scaledResult;
    }
  }


  void toggleDataCollection(BuildContext context) {
    setState(() {
      collectingData = !collectingData;
      buttonText = collectingData ? "Stop Sensor" : "Start Sensor";
    });

    if (collectingData) {
      // _verticalAccelerationData.clear();
      // reset the array for next rep
      _verticalAccelerationData = [SensorDataPoint(0.0, DateTime.now())];
      subscribeToSensors();
    } else {
      cancelSensorSubscriptions();
      // do velocity calculation and rep detection here

      List<SensorDataPoint> accelerationDataCopy = _verticalAccelerationData;
      print("Acceleration data count: ${accelerationDataCopy.length}");
      if (accelerationDataCopy.isNotEmpty) {
        // remove first element, which is the default value (placeholder) in the UI
        accelerationDataCopy.removeAt(0);
        SensorManager manager = SensorManager();

        // calculate velocity from acceleration, isolate rep
        List<double> velocityArray = manager.velocityArrayFromAccelerationData(accelerationDataCopy);
        List<double> repData = manager.getIsolatedRep(velocityArray);
        double meanVelocity = manager.meanVelocity(repData);

        if (Provider.of<CalibrationData>(context, listen: false).calibrationIsComplete(widget.title)) {
          // rep after calibration has been completed
          // calculate estimated 1rm from velocity data
          double? predictedPercent = Provider.of<CalibrationData>(context, listen: false).prediction(meanVelocity, widget.title);
          if (predictedPercent != null) {
            double error = Provider.of<CalibrationData>(context, listen: false).regressionError(widget.title);
            int errorInt = (error * 100).round();
            double scaledPercent = predictedPercent / 100.0;
            double load1RM = _selectedWeight.toDouble() / scaledPercent;
            int loadToNearest5 = roundedToNearest5(load1RM);
            int roundedPercent = (predictedPercent).round();

            String resultMessage = "We estimate that $_selectedWeight lbs is $roundedPercent% +- $errorInt% of your 1RM, \nAnd your actual 1RM is around $loadToNearest5 lbs";

            setState(() {
              _meanVelocityDuringRep = meanVelocity;
              _resultText = resultMessage;
            });
          } else {
            setState(() {
              _meanVelocityDuringRep = meanVelocity;
              _resultText = "Error accessing regression model";
            });
          }
        } else {
          // completed calibration rep. Update the current data point and advance index
          print('update calibration datapoint');
          Provider.of<CalibrationData>(context, listen: false).updateCurrentCalibrationDataPoint(meanVelocity, widget.title);
          Provider.of<CalibrationData>(context, listen: false).updateCalibrationIndex(widget.title);

          if(Provider.of<CalibrationData>(context, listen: false).calibrationIsComplete(widget.title)) {
            // this was the last calibration rep. Do linear regression
            print('last calibration rep complete!');
            Provider.of<CalibrationData>(context, listen: false).createRegressionModelFromCalibrationData(widget.title);
          }

          // dismiss sheet
          Navigator.pop(context);
        }

        // Provider.of<CalibrationData>(context, listen: false).updateCalibrationIndex(widget.title);
        // Provider.of<CalibrationData>(context, listen: false).testLinearRegression();
        // dismiss sheet
        // Navigator.pop(context);

      }

    }
  }

  int roundedToNearest5(double value) {
    int intValue = value.round();
    int nearestFive = (intValue ~/ 5) * 5;
    return nearestFive;
  }
}