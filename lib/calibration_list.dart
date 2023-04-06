import 'package:flutter/material.dart';
import 'calibration_data.dart';

class CalibrationListView extends StatelessWidget {
  const CalibrationListView({super.key, required this.calibrationData, required this.calibrationIndex});

  final int calibrationIndex;
  final List<CalibrationDataPoint> calibrationData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return CalibrationListRow(percent: calibrationData[index].percent1RM, isChecked: index < calibrationIndex);
      },
      itemCount: calibrationData.length,
    );
  }
}

class CalibrationListRow extends StatelessWidget {
  const CalibrationListRow({super.key, required this.percent, required this.isChecked});
  final int percent;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Rep at $percent% 1RM',
      style: TextStyle(decoration: isChecked ? TextDecoration.lineThrough : null)),
      trailing: Checkbox(
        value: isChecked,
        onChanged: (value) {
          // checkbox does not change when user taps, it only changes when a rep is completed and velocity values are added to the list
          // so do nothing here
          // setState(() {
          //   isChecked = value!;
          // });
        },
        activeColor: Theme.of(context).colorScheme.secondary,
      ),

    );
  }
}