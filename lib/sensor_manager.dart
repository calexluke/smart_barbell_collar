import 'package:collection/collection.dart';

class Acceleration {
  double x;
  double y;
  double z;

  Acceleration(this.x, this.y, this.z);
}

class SensorDataPoint {
  double value;
  DateTime timeStamp;

  SensorDataPoint(this.value, this.timeStamp);
}

class SensorManager {

  // TODO: move all sensor related code to this class, use provider pattern

  List<double> velocityArrayFromAccelerationData(List<SensorDataPoint> accelerationData) {

    // Assume V is 0 to start
    List<double> velocityData = [0.0];

    for (int i = 1; i < accelerationData.length; i++) {

      int j = i - 1;
      double prevAccel = accelerationData[j].value;
      DateTime currentTime = accelerationData[i].timeStamp;
      DateTime prevTime = accelerationData[j].timeStamp;

      int timeStepMicroseconds = currentTime.difference(prevTime).inMicroseconds;
      double timeStepSeconds = timeStepMicroseconds.toDouble() / Duration.microsecondsPerSecond;

      double dV = prevAccel * (timeStepSeconds);
      double newValue = dV + velocityData[j];
      velocityData.add(newValue);
    }

    return velocityData;
  }

  List<double> getIsolatedRep(List<double> velocityData) {

    // find index of largest value
    double largestValue = velocityData.first;
    int largestValueIndex = 0;

    velocityData.forEachIndexed((index, value) {
      // Checking for largest value in the list
      if (value > largestValue) {
        largestValue = value;
        largestValueIndex = index;
      }
    });

    print("largest velocity value is $largestValue at index $largestValueIndex");

    // start sliding window at the peak
    int left = largestValueIndex;
    int right = largestValueIndex;

    // find bounds of positive rep array
    while (velocityData[left] > 0 && left > 0) {
      left -= 1;
    }

    while (velocityData[right] > 0 && right < velocityData.length) {
      right += 1;
    }

    List<double> repArray = velocityData.sublist(left, right + 1);
    print("Rep array: \n $repArray");

    return repArray;
  }

  double meanVelocity(List<double> velocityData) {
    return velocityData.average;
  }
}