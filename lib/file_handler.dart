import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'sensor_manager.dart';

class FileHandler {

  final String csvFileName = "accelerationData.csv";

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get _csvFilePath async {
    final path = await _localPath;
    return '$path/$csvFileName';
  }

  Future<File> get _accelerationFile async {
    final csvPath = await _csvFilePath;
    return File(csvPath);
  }

  Future<String> readAcceleration() async {
    try {
      final file = await _accelerationFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "error reading file: $e";
    }
  }

  Future<File> writeAccelerations(List<SensorDataPoint> accelerationData) async {
    File file = await _accelerationFile;
    String csvFileData = getCSVString(accelerationData);
    // String csvFileDataWithVelocity = getCSVStringWithVelocity(accelerationData);
    file = await file.writeAsString(csvFileData);
    return file;
  }

  String getCSVString(List<SensorDataPoint> accelerationData) {

    // remove first element (placeholder from UI)
    List<SensorDataPoint> accelerationDataCopy = accelerationData;
    if (accelerationDataCopy.isNotEmpty) {
      accelerationDataCopy.removeAt(0);
    }

    // column headings
    String csvString = 't,ay\n';
    // add each data point
    double timeStep = 0.0;
    for (int i = 0; i < accelerationDataCopy.length; i++) {
      String dataString = accelerationDataCopy[i].value.toString();
      if (i > 0) {
        DateTime previousTimeStamp = accelerationDataCopy[i - 1].timeStamp;
        DateTime currentTimeStamp = accelerationDataCopy[i].timeStamp;
        int differenceMicroseconds = currentTimeStamp.difference(previousTimeStamp).inMicroseconds;
        double differenceSeconds = differenceMicroseconds.toDouble() / Duration.microsecondsPerSecond;
        timeStep = timeStep + differenceSeconds;
      }
      String timeStepString = timeStep.toString();
      // append data point
      csvString = '$csvString$timeStepString, $dataString\n';
    }
    return csvString;
  }

  // used to compare calculated velocity with the version calculated in matlab
  String getCSVStringWithVelocity(List<SensorDataPoint> accelerationData) {

    // remove first element (placeholder from UI)
    List<SensorDataPoint> accelerationDataCopy = accelerationData;
    if (accelerationDataCopy.isNotEmpty) {
      accelerationDataCopy.removeAt(0);
    }

    SensorManager manager = SensorManager();
    List<double> calculatedVelocities = manager.velocityArrayFromAccelerationData(accelerationDataCopy);
    List<double> repData = manager.getIsolatedRep(calculatedVelocities);
    double meanValue = manager.meanVelocity(repData);
    print("mean value: $meanValue");

    // column headings
    String csvString = 't,ay,vy\n';
    // add each data point
    double timeStep = 0.0;
    for (int i = 0; i < accelerationDataCopy.length; i++) {
      String accelString = accelerationDataCopy[i].value.toString();
      String velocityString;

      if (i > 0) {
        DateTime previousTimeStamp = accelerationDataCopy[i - 1].timeStamp;
        DateTime currentTimeStamp = accelerationDataCopy[i].timeStamp;
        int differenceMicroseconds = currentTimeStamp.difference(previousTimeStamp).inMicroseconds;
        double differenceSeconds = differenceMicroseconds.toDouble() / Duration.microsecondsPerSecond;
        timeStep = timeStep + differenceSeconds;
        velocityString = calculatedVelocities[i - 1].toString();
      } else {
        velocityString = calculatedVelocities[i].toString();
      }

      String timeStepString = timeStep.toString();
      // append data point
      csvString = '$csvString$timeStepString, $accelString, $velocityString\n';
    }
    return csvString;
  }


  void shareCSVFile() async {
    final csvPath = await _csvFilePath;
    Share.shareXFiles([XFile(csvPath)]);
    // Share.shareFiles([csvPath], text: 'Acceleration Data');
  }
}