import 'dart:io';

import 'package:survi_app/services/database_services.dart';

final DatabaseServices databaseServices = DatabaseServices.instance;

Future<void> pushDataToLocalStorage(
  String region,
  double longitude,
      double latitude,
      String altitude,
      String speed,
      String time,
      String remark,
      String subdepartment,
      String assetowner,
      String projectName,
      String assettype,
      String subtype,
      String assetyear,
      String assetname,
      String status,
      List<File> files) async {
  Map<String, dynamic> surveyData = {
    'regions': region,
    'remark': remark,
    'longitude': longitude,
    'latitude': latitude,
    'timestamp': time,
    'speed': speed,
    'altitude': altitude,
    'subdepartment': subdepartment,
    'assetowner': assetowner,
    'projectName': projectName,
    'assettype': assettype,
    'subtype': subtype,
    'assetyear': assetyear,
    'assetname': assetname,
    'purpose': status,
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
