class Acceleration {
  double x;
  double y;
  double z;

  Acceleration(this.x, this.y, this.z);
}

class AccelerationDataPoint {
  double verticalAcceleration;
  DateTime timeStamp;

  AccelerationDataPoint(this.verticalAcceleration, this.timeStamp);
}

class SensorManager {

  // TODO: move all sensor related code to this class, use provider pattern

}