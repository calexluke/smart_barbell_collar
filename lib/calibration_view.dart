import 'package:flutter/material.dart';
import 'sensor_view.dart';
import 'constants.dart';
import 'exercise_type.dart';
import 'calibration_list.dart';
import 'calibration_data.dart';
import 'package:provider/provider.dart';

// Calibration View - user keeps track of their progress in calibration sequence

class CalibrationView extends StatefulWidget {
  const CalibrationView({super.key, required this.exercise});

  final ExerciseType exercise;

  @override
  State<CalibrationView> createState() => _CalibrationViewState();
}

class _CalibrationViewState extends State<CalibrationView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.exercise.displayString} calibration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // const Spacer(),
            Expanded(
              child: CalibrationListView(
                calibrationData: Provider.of<CalibrationData>(context).getCalibrationData(widget.exercise.displayString),
                calibrationIndex: Provider.of<CalibrationData>(context).getCalibrationIndex(widget.exercise.displayString),),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: TextButton(
                onPressed: () => {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.8,
                              child:
                              SensorViewPage(title: widget.exercise.displayString)
                          ),
                        );
                      }
                  )
                },
                child: Text("Start Exercise"),
                style: textButtonStyle(context),
              ),
            )

          ],
        ),
      ),
    );
  }
}
