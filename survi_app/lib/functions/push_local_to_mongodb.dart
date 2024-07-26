import 'dart:io';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:survi_app/apis/submit_api.dart';
import 'package:survi_app/models/survey_with_files.dart';
import 'package:survi_app/services/database_services.dart';

final DatabaseServices _databaseServices = DatabaseServices.instance;

Future<void> pushLocalDataToMongoDB() async{
  bool hasInternet = await InternetConnection().hasInternetAccess;
   

    if (hasInternet) {
      print(
          "Internet Connected Fetching Data from Local Storage");
      // fetch the survey from local storage data
      
      List<SurveyWithFiles> surveywithfiles =
          await _databaseServices.getUnsyncedSurveyWithFiles();


      print(
          "Fetched ${surveywithfiles.length} survey from the local Database Storage");

      for (var surveyWithFiles in surveywithfiles) {
        print(
            'Pushing Survey_id ${surveyWithFiles.survey.id} to MongoDB');
        try {
          double longitude = surveyWithFiles.survey.longitude;
          double latitude = surveyWithFiles.survey.latitude;
          String altitude = surveyWithFiles.survey.altitude;
          String speed = surveyWithFiles.survey.speed;
          String timestamp = surveyWithFiles.survey.timestamp;
          String description = surveyWithFiles.survey.description;
          List<File> files =
              surveyWithFiles.files.map((file) => File(file.filePath)).toList();

          await pushDataToMongoDB([longitude, latitude], altitude, speed, timestamp,
              description, files);

          print(
              'Pushed Survey survey_Id :${surveyWithFiles.survey.id} Successfully');

          // if successfully delete data from local
          await _databaseServices.markSynced(surveyWithFiles.survey.id);

          print(
              'marked synced Survey survey_id ${surveyWithFiles.survey.id} in local Storage');
        } catch (e) {
          print(
              'Fail to Push Survey id: ${surveyWithFiles.survey.id} Error : $e');
          print('Error for Syncing survey $e');
        }
      }
    }
}