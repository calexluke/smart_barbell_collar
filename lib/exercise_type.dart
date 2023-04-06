enum ExerciseType { squat, benchPress, deadlift }

extension Display on ExerciseType {

  String get displayString {
    switch (this) {
      case ExerciseType.squat:
        return 'Squat';
      case ExerciseType.benchPress:
        return 'Bench Press';
      case ExerciseType.deadlift:
        return 'Deadlift';
      default:
        return "Unknown";
    }
  }

}