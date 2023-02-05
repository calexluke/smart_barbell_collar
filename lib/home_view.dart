import 'package:flutter/material.dart';
import 'sensor_view.dart';
import 'constants.dart';

// Home page - user selects exercise

enum ExerciseType { squat, benchPress, deadlift }

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.title});

  final String title;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ExerciseType? _selectedExercise = ExerciseType.squat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            exerciseRadioRow(ExerciseType.squat, "Squat"),
            exerciseRadioRow(ExerciseType.benchPress, "Bench Press"),
            exerciseRadioRow(ExerciseType.deadlift, "Deadlift"),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
              child: TextButton(
                onPressed: () => {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child:
                            SensorViewPage(title: "Access Sensors")
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

  ListTile exerciseRadioRow(ExerciseType selection, String text) {
    return ListTile(
      title: Text(text),
      leading: Radio<ExerciseType>(
        activeColor: Theme.of(context).colorScheme.secondary,
        value: selection,
        groupValue: _selectedExercise,
        onChanged: (ExerciseType? selection) {
          setState(() {
            _selectedExercise = selection;
          });
        },
      ),
    );
  }

}
