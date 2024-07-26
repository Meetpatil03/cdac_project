import 'dart:async';
import 'dart:io';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:survi_app/apis/submit_api.dart';
import 'package:survi_app/models/survey_with_files.dart';
import 'package:survi_app/services/database_services.dart';
import 'package:survi_app/services/log_services.dart';
import 'package:workmanager/workmanager.dart';

final DatabaseServices _databaseServices = DatabaseServices.instance;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await LogService.log('Workmanager Task Started');
    // check internet Connectivity

    pushDataToMongoDB([122.22, 37.99], "129", "12", "10:30",
              "Just Testing for Api Calls", []);

    bool hasInternet = await InternetConnection().hasInternetAccess;
    await LogService.log("Internet Connection Status : $hasInternet");

    // if (hasInternet) {
    //   await LogService.log(
    //       "Internet Connected Fetching Data from Local Storage");
    //   // fetch the survey from local storage data
    //   List<SurveyWithFiles> surveywithfiles =
    //       await _databaseServices.getUnsyncedSurveyWithFiles();
    //   await LogService.log(
    //       "Fetched ${surveywithfiles.length} survey from the local Database Storage");

    //   for (var surveyWithFiles in surveywithfiles) {
    //     await LogService.log(
    //         'Pushing Survey_id ${surveyWithFiles.survey.id} to MongoDB');
    //     try {
    //       double longitude = surveyWithFiles.survey.longitude;
    //       double latitude = surveyWithFiles.survey.latitude;
    //       String altitude = surveyWithFiles.survey.altitude;
    //       String speed = surveyWithFiles.survey.speed;
    //       String timestamp = surveyWithFiles.survey.timestamp;
    //       String description = surveyWithFiles.survey.description;
    //       List<File> files =
    //           surveyWithFiles.files.map((file) => File(file.filePath)).toList();

    //       pushDataToMongoDB([longitude, latitude], altitude, speed, timestamp,
    //           description, files);

    //       await LogService.log(
    //           'Pushed Survey survey_Id :${surveyWithFiles.survey.id} Successfully');

    //       // if successfully delete data from local
    //       await _databaseServices.markSynced(surveyWithFiles.survey.id);

    //       await LogService.log(
    //           'marked synced Survey survey_id ${surveyWithFiles.survey.id} in local Storage');
    //     } catch (e) {
    //       await LogService.log(
    //           'Fail to Push Survey id: ${surveyWithFiles.survey.id} Error : $e');
    //       print('Error for Syncing survey $e');
    //     }
    //   }
    // }

    return Future.value(true);
  });
}
