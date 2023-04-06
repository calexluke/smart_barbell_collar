import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

class CalibrationDataPoint {
  int percent1RM;
  double velocity;
  CalibrationDataPoint(this.percent1RM, this.velocity);
}

class CalibrationData extends ChangeNotifier {

  final velocityColumnName = 'velocity';
  final percentColumnName = '%1RM';

  // hardcoded for testing purposes
  LinearRegressor? squatLoadVelocityModel;
  int squatCalibrationIndex = 10;
  List<CalibrationDataPoint> squatCalibrationDataList = [
    CalibrationDataPoint(20, 1.41),
    CalibrationDataPoint(20, 1.41),
    CalibrationDataPoint(20, 1.41),
    CalibrationDataPoint(40, 1.16),
    CalibrationDataPoint(40, 1.16),
    CalibrationDataPoint(40, 1.16),
    CalibrationDataPoint(60, 0.86),
    CalibrationDataPoint(60, 0.86),
    CalibrationDataPoint(60, 0.86),
    CalibrationDataPoint(80, 0.55),
    CalibrationDataPoint(90, 0.40),
  ];

  LinearRegressor? benchLoadVelocityModel;
  int benchCalibrationIndex = 0;
  List<CalibrationDataPoint> benchCalibrationDataList = [
    CalibrationDataPoint(20, 0.0),
    CalibrationDataPoint(20, 0.0),
    CalibrationDataPoint(20, 0.0),
    CalibrationDataPoint(40, 0.0),
    CalibrationDataPoint(40, 0.0),
    CalibrationDataPoint(40, 0.0),
    CalibrationDataPoint(60, 0.0),
    CalibrationDataPoint(60, 0.0),
    CalibrationDataPoint(60, 0.0),
    CalibrationDataPoint(80, 0.0),
    CalibrationDataPoint(90, 0.0),
  ];

  LinearRegressor? deadliftLoadVelocityModel;
  int deadliftCalibrationIndex = 9;
  List<CalibrationDataPoint> deadliftCalibrationDataList = [
    CalibrationDataPoint(20, 0.0),
    CalibrationDataPoint(20, 0.0),
    CalibrationDataPoint(20, 0.0),
    CalibrationDataPoint(40, 0.0),
    CalibrationDataPoint(40, 0.0),
    CalibrationDataPoint(40, 0.0),
    CalibrationDataPoint(60, 0.0),
    CalibrationDataPoint(60, 0.0),
    CalibrationDataPoint(60, 0.0),
    CalibrationDataPoint(80, 0.0),
    CalibrationDataPoint(90, 0.0),
  ];

  List<CalibrationDataPoint> getCalibrationData(String exercise) {
    switch (exercise) {
      case 'Squat':
        return squatCalibrationDataList;
      case 'Bench Press':
        return benchCalibrationDataList;
      case 'Deadlift':
        return deadliftCalibrationDataList;
      default:
        print('invalid exercise type!');
        return [];
    }
  }

  int getCalibrationIndex(String exercise) {
    switch (exercise) {
      case 'Squat':
        return squatCalibrationIndex;
      case 'Bench Press':
        return benchCalibrationIndex;
      case 'Deadlift':
        return deadliftCalibrationIndex;
      default:
        print('invalid exercise type!');
        return 0;
    }
  }

  int currentCalibrationPercent(String exercise) {
    int index = getCalibrationIndex(exercise);
    List<CalibrationDataPoint> data = getCalibrationData(exercise);
    if (index < data.length) {
      return data[index].percent1RM;
    } else {
      print('invalid index, can get current calibration rep!');
      return 0;
    }
  }

  bool calibrationIsComplete(String exercise) {
    int index = getCalibrationIndex(exercise);
    List<CalibrationDataPoint> data = getCalibrationData(exercise);
    return (index >= data.length);
  }

  void updateCalibrationIndex(String exercise) {
    switch (exercise) {
      case 'Squat':
        squatCalibrationIndex = squatCalibrationIndex + 1;
        print('calibration index now is $squatCalibrationIndex');
        break;
      case 'Bench Press':
        benchCalibrationIndex = benchCalibrationIndex + 1;
        print('calibration index now is $benchCalibrationIndex');
        break;
      case 'Deadlift':
        deadliftCalibrationIndex = deadliftCalibrationIndex + 1;
        print('calibration index now is $deadliftCalibrationIndex');
        break;
      default:
        print('invalid exercise type!');
        return;
    }
    notifyListeners();
  }

  void updateCurrentCalibrationDataPoint(double velocityValue, String exercise) {
    switch (exercise) {
      case 'Squat':
        squatCalibrationDataList[squatCalibrationIndex].velocity = velocityValue;
        break;
      case 'Bench Press':
        benchCalibrationDataList[benchCalibrationIndex].velocity = velocityValue;
        break;
      case 'Deadlift':
        deadliftCalibrationDataList[deadliftCalibrationIndex].velocity = velocityValue;
        break;
      default:
        print('invalid exercise type!');
        return;
    }
    notifyListeners();
  }

  LinearRegressor? getRegressionModel(String exercise) {
    switch (exercise) {
      case 'Squat':
        return squatLoadVelocityModel;
      case 'Bench Press':
        return benchLoadVelocityModel;
      case 'Deadlift':
        return deadliftLoadVelocityModel;
      default:
        print('invalid exercise type!');
        return null;
    }
  }

  void createRegressionModelFromCalibrationData(String exercise) {
    switch (exercise) {
      case 'Squat':
        squatLoadVelocityModel = createRegressionModelForCalibrationData(getCalibrationData(exercise));
        break;
      case 'Bench Press':
        benchLoadVelocityModel = createRegressionModelForCalibrationData(getCalibrationData(exercise));
        break;
      case 'Deadlift':
        deadliftLoadVelocityModel = createRegressionModelForCalibrationData(getCalibrationData(exercise));
        break;
      default:
        print('invalid exercise type!');
        return;
    }
    notifyListeners();
  }

  DataFrame calibrationDataFrame(List<CalibrationDataPoint> dataList) {
    DataFrame data = DataFrame([
      [percentColumnName, velocityColumnName],
      [dataList[0].percent1RM,  dataList[0].velocity],
      [dataList[1].percent1RM,  dataList[1].velocity],
      [dataList[2].percent1RM,  dataList[2].velocity],
      [dataList[3].percent1RM,  dataList[3].velocity],
      [dataList[4].percent1RM,  dataList[4].velocity],
      [dataList[5].percent1RM,  dataList[5].velocity],
      [dataList[6].percent1RM,  dataList[6].velocity],
      [dataList[7].percent1RM,  dataList[7].velocity],
      [dataList[8].percent1RM,  dataList[8].velocity],
      [dataList[9].percent1RM,  dataList[9].velocity],
      [dataList[10].percent1RM, dataList[10].velocity],
    ]);
    return data;
  }

  double? prediction(double velocityValue, String exercise) {
    LinearRegressor? model = getRegressionModel(exercise);
    if (model != null) {
      final unlabelledData = DataFrame([
        [velocityColumnName],
        [velocityValue],
      ]);
      final prediction = model.predict(unlabelledData);
      double value = prediction.rows.last.first;
      print('prediction: $prediction');
      print('prediction value: $value');
      return value;
    } else {
      print("regression model was null for $exercise");
      return null;
    }
  }

  LinearRegressor createRegressionModelForCalibrationData(List<CalibrationDataPoint> dataList) {
    DataFrame data = calibrationDataFrame(dataList);
    print('data: ${data.rows}');
    final unlabelledData = DataFrame([
      [velocityColumnName],
      [0.6],
    ]);
    // Remember, we discussed the bias term above, "fitIntercept" says
    // that we want to consider, how much biased our line is
    final model = LinearRegressor(data, percentColumnName, fitIntercept: true);
    final prediction = model.predict(unlabelledData);
    final error = model.assess(data, MetricType.mape);
    print('Coefficients: ${model.coefficients}');
    print('Prediction: $prediction');
    print('Error: $error');

    return model;
  }

  double regressionError(String exercise) {
    LinearRegressor? model;
    switch (exercise) {
      case 'Squat':
        model = squatLoadVelocityModel;
        break;
      case 'Bench Press':
        model = squatLoadVelocityModel;
        break;
      case 'Deadlift':
        model = squatLoadVelocityModel;
        break;
      default:
        print('invalid exercise type!');
        return 0.0;
    }

    if (model != null) {
      DataFrame data = calibrationDataFrame(getCalibrationData(exercise));
      final error = model.assess(data, MetricType.mape);
      return error;
    } else {
      print('regression model for $exercise was null!');
      return 0.0;
    }

  }
}