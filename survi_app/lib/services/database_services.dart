import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:survi_app/models/survey_file_list.dart';
import 'package:survi_app/models/survey_list.dart';
import 'package:survi_app/models/survey_with_files.dart';

class DatabaseServices {
  static Database? _db;
  static final DatabaseServices instance = DatabaseServices._constructor();

  final String _tablesName = "surveys";
  final String _filesTablesName = "files";
  final String _columnRegionName = "regions";
  final String _columnDescriptionName = "remark";
  final String _columnLongitudeName = "longitude";
  final String _columnLatitudeName = "latitude";
  final String _columnTimeStampName = "timestamp";
  final String _columnSpeedName = "speed";
  final String _columnAltitudeName = "altitude";
  final String _columnSubDepartmentName = "subdepartment";
  final String _columnAssetOwnerName = "assetowner";
  final String _columnProjectName = "projectName";
  final String _columnAssetTypeName = "assettype";
  final String _columnSubTypeName = "subtype";
  final String _columnAssetYearName = "assetyear";
  final String _columnAssetName = "assetname";
  final String _columnPurposeName = "purpose";
  final String _columnSurveyIdName = "survey_id";
  final String _columnFilePathName = "file_path";
  final String _columnSendStatus = "send_status";

  DatabaseServices._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'survey_app.db');
    final database =
        await openDatabase(databasePath, version: 1, onCreate: _onCreate);
    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
 CREATE TABLE $_tablesName(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  $_columnRegionName TEXT,
  $_columnDescriptionName TEXT,
  $_columnLongitudeName REAL,
  $_columnLatitudeName REAL,
  $_columnTimeStampName TEXT,
  $_columnSpeedName TEXT,
  $_columnAltitudeName TEXT,
  $_columnSubDepartmentName TEXT,
  $_columnAssetOwnerName TEXT,
  $_columnProjectName TEXT,
  $_columnAssetTypeName TEXT,
  $_columnSubTypeName TEXT,
  $_columnAssetYearName TEXT,
  $_columnAssetName TEXT,
  $_columnPurposeName TEXT,
  $_columnSendStatus INTEGER DEFAULT 0
 )
''');

    await db.execute('''
      CREATE TABLE $_filesTablesName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnSurveyIdName INTEGER,
        $_columnFilePathName TEXT,
        FOREIGN KEY ($_columnSurveyIdName) REFERENCES $_tablesName (id)
      )
''');
  }

  Future<int> insertSurvey(Map<String, dynamic> surveyData) async {
    final db = await database;
    int id = await db.insert(_tablesName, surveyData);
    return id;
  }

  Future<int> insertFile(Map<String, dynamic> fileData) async {
    final db = await database;
    return await db.insert(_filesTablesName, fileData);
  }

  Future<List<SurveyList>> getSurveys() async {
    final db = await database;
    final data = await db.query(_tablesName);
    List<SurveyList> surveyList = data
        .map((e) => SurveyList(
              id: e['id'] as int,
              sendstatus: e[_columnSendStatus] as int,
              description: e[_columnDescriptionName] as String,
              longitude: e[_columnLongitudeName] as double,
              latitude: e[_columnLatitudeName] as double,
              timestamp: e[_columnTimeStampName] as String,
              speed: e[_columnSpeedName] as String,
              altitude: e[_columnAltitudeName] as String,
              subdepartment: e[_columnSubDepartmentName] as String,
              assetowner: e[_columnAssetOwnerName] as String,
              projectName: e[_columnProjectName] as String,
              assettype: e[_columnAssetTypeName] as String,
              subtype: e[_columnSubTypeName] as String,
              assetyear: e[_columnAssetYearName] as String,
              assetname: e[_columnAssetName] as String,
              purpose: e[_columnPurposeName] as String,
              region: e[_columnRegionName] as String,
            ))
        .toList();

    return surveyList;
  }

  Future<List<Map<String, dynamic>>> getFiles(int surveyId) async {
    final db = await database;
    final data = await db.query(_filesTablesName,
        where: '$_columnSurveyIdName = ?', whereArgs: [surveyId]);
    return data;
  }

  Future<List<SurveyWithFiles>> getSurveysWithFiles() async {
    final db = await database;
    final surveyData = await db.query(_tablesName);

    List<SurveyWithFiles> surveysWithFiles = [];

    for (var survey in surveyData) {
      int surveyId = survey['id'] as int;
      final fileData = await db.query(
        _filesTablesName,
        where: '$_columnSurveyIdName = ?',
        whereArgs: [surveyId],
      );

      List<SurveyFileList> files = fileData
          .map((e) => SurveyFileList(
              id: e['id'] as int,
              surveyId: e['survey_id'] as int,
              filePath: e['file_path'] as String))
          .toList();

      SurveyList surveyItem = SurveyList(
        id: surveyId,
        sendstatus: survey[_columnSendStatus] as int,
        description: survey[_columnDescriptionName] as String,
        longitude: survey[_columnLongitudeName] as double,
        latitude: survey[_columnLatitudeName] as double,
        timestamp: survey[_columnTimeStampName] as String,
        speed: survey[_columnSpeedName] as String,
        altitude: survey[_columnAltitudeName] as String,
        subdepartment: survey[_columnSubDepartmentName] as String,
        assetowner: survey[_columnAssetOwnerName] as String,
        projectName: survey[_columnProjectName] as String,
        assettype: survey[_columnAssetTypeName] as String,
        subtype: survey[_columnSubTypeName] as String,
        assetyear: survey[_columnAssetYearName] as String,
        assetname: survey[_columnAssetName] as String,
        purpose: survey[_columnPurposeName] as String,
        region: survey[_columnRegionName] as String,
      );

      surveysWithFiles.add(SurveyWithFiles(survey: surveyItem, files: files));
    }

    return surveysWithFiles;
  }

  Future<List<SurveyWithFiles>> getUnsyncedSurveyWithFiles() async {
    final db = await database;
    final surveyData = await db.query(
      _tablesName,
      where: '$_columnSendStatus = ?',
      whereArgs: [0], // means not yet send to the mongoDB
    );

    List<SurveyWithFiles> surveyWithFiles = [];

    for (var survey in surveyData) {
      int surveyId = survey['id'] as int;
      final fileData = await db.query(
        _filesTablesName,
        where: '$_columnSurveyIdName = ?',
        whereArgs: [surveyId],
      );

      List<SurveyFileList> files = fileData
          .map((e) => SurveyFileList(
              id: e['id'] as int,
              surveyId: e['survey_id'] as int,
              filePath: e['file_path'] as String))
          .toList();

      SurveyList surveyItem = SurveyList(
        id: survey['id'] as int,
        sendstatus: survey[_columnSendStatus] as int,
        description: survey[_columnDescriptionName] as String,
        longitude: survey[_columnLongitudeName] as double,
        latitude: survey[_columnAltitudeName] as double,
        timestamp: survey[_columnTimeStampName] as String,
        speed: survey[_columnSpeedName] as String,
        altitude: survey[_columnAltitudeName] as String,
        subdepartment: survey[_columnSubDepartmentName] as String,
        assetowner: survey[_columnAssetOwnerName] as String,
        projectName: survey[_columnProjectName] as String,
        assettype: survey[_columnAssetTypeName] as String,
        subtype: survey[_columnSubTypeName] as String,
        assetyear: survey[_columnAssetYearName] as String,
        assetname: survey[_columnAssetName] as String,
        purpose: survey[_columnPurposeName] as String,
        region: survey[_columnRegionName] as String,
      );

      surveyWithFiles.add(SurveyWithFiles(survey: surveyItem, files: files));
    }

    return surveyWithFiles;
  }

  Future<void> markSynced(int surveyId) async {
    final db = await database;
    await db.update(
      _tablesName,
      {_columnSendStatus: 1},
      where: 'id = ?',
      whereArgs: [surveyId],
    );
  }

  Future<int> deleteSurvey(int id) async {
    final db = await database;
    await db.delete(
      _filesTablesName,
      where: '$_columnSurveyIdName = ?',
      whereArgs: [id],
    );

    return await db.delete(_tablesName, where: 'id = ?', whereArgs: [id]);
  }
}
