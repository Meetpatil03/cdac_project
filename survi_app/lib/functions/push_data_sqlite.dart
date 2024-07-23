import 'dart:io';

import 'package:survi_app/services/database_services.dart';

final DatabaseServices databaseServices = DatabaseServices.instance;

Future<void> pushDataToLocalStorage(String description, double longitude,
    double latitude, String time, String speed, String altitude,List<File> files) async {
  Map<String, dynamic> surveyData = {
    'description': description,
    'longitude': longitude,
    'latitude': latitude,
    'timestamp': time,
    'speed': speed,
    'altitude': altitude,
  };

  int surveyId = await databaseServices.insertSurvey(surveyData);

  for (var file in files) {
      Map<String, dynamic> fileData = {
        'survey_id': surveyId,
        'file_path': file.path,
      };

      await databaseServices.insertFile(fileData);
    }
}
