import 'package:flutter/material.dart';
import 'constants.dart';
import 'exercise_type.dart';
import 'calibration_view.dart';
import 'calibration_data.dart';
import 'package:provider/provider.dart';

// Home page - user selects exercise

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.title});

  final String title;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ExerciseType _selectedExercise = ExerciseType.squat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () => {
                Provider.of<CalibrationData>(context, listen: false).resetCalibrationData()
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text("Select Exercise",
                  style: Theme.of(context).textTheme.headline4),
            ),
            exerciseRadioRow(ExerciseType.squat),
            exerciseRadioRow(ExerciseType.benchPress),
            exerciseRadioRow(ExerciseType.deadlift),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
              child: TextButton(
                onPressed: () async => {
                  if (_selectedExercise.displayString != 'Squat') {
                    // for now, don't load saved data for squat, so we use hardcoded data for debug
                    await Provider.of<CalibrationData>(context, listen: false).loadDataFromPreferences(_selectedExercise.displayString),
                  },

                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CalibrationView(exercise: _selectedExercise);
                  })),
              },
                  child: Text("Select Exercise"),
                  style: textButtonStyle(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile exerciseRadioRow(ExerciseType selection) {
    return ListTile(
      title: Text(selection.displayString),
      leading: Radio<ExerciseType>(
        activeColor: Theme.of(context).colorScheme.secondary,
        value: selection,
        groupValue: _selectedExercise,
        onChanged: (ExerciseType? selection) {
          setState(() {
            _selectedExercise = selection ?? ExerciseType.squat;
          });
        },
      ),
    );
  }

}
