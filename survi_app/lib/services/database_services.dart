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
  final String _columnDescriptionName = "description";
  final String _columnLongitudeName = "longitude";
  final String _columnLatitudeName = "latitude";
  final String _columnTimeStampName = "timestamp";
  final String _columnSpeedName = "speed";
  final String _columnAltitudeName = "altitude";
  final String _columnSurveyIdName = "survey_id";
  final String _columnFilePathName = "file_path";

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
  $_columnDescriptionName TEXT,
  $_columnLongitudeName REAL,
  $_columnLatitudeName REAL,
  $_columnTimeStampName TEXT,
  $_columnSpeedName TEXT,
  $_columnAltitudeName TEXT
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
            description: e['description'] as String,
            longitude: e['longitude'] as double,
            latitude: e['latitude'] as double,
            timestamp: e['timestamp'] as String,
            speed: e['speed'] as String,
            altitude: e['altitude'] as String))
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
          description: survey['description'] as String,
          longitude: survey['longitude'] as double,
          latitude: survey['latitude'] as double,
          timestamp: survey['timestamp'] as String,
          speed: survey['speed'] as String,
          altitude: survey['altitude'] as String);

      surveysWithFiles.add(SurveyWithFiles(survey: surveyItem, files: files));
    }

    return surveysWithFiles;
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
