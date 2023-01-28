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

  Future<File> writeAccelerations(List<AccelerationDataPoint> accelerationData) async {
    File file = await _accelerationFile;
    String csvFileData = getCSVString(accelerationData);
    file = await file.writeAsString(csvFileData);
    return file;
  }

  String getCSVString(List<AccelerationDataPoint> accelerationData) {

    // remove first element (placeholder from UI)
    if (accelerationData.isNotEmpty) {
    accelerationData.removeAt(0);
    }

    // column headings
    String csvString = 't,ay\n';
    // add each data point
    double timeStep = 0.0;
    for (int i = 0; i < accelerationData.length; i++) {
      String dataString = accelerationData[i].verticalAcceleration.toString();
      if (i > 0) {
        DateTime previousTimeStamp = accelerationData[i - 1].timeStamp;
        DateTime currentTimeStamp = accelerationData[i].timeStamp;
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


  void shareCSVFile() async {
    final csvPath = await _csvFilePath;
    Share.shareXFiles([XFile(csvPath)]);
    // Share.shareFiles([csvPath], text: 'Acceleration Data');
  }
}