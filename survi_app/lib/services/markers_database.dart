import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:survi_app/models/task_list.dart';

class MarkersDatabase {
  static Database? _db;
  static final MarkersDatabase instance = MarkersDatabase._contructor();

  final String _tablesName = 'markers';
  final String userIdColumn = 'user_id';
  final String agentIdColumn = 'agent_id';
  final String startLatColumn = 'startLat';
  final String startLngColumn = 'startLng';
  final String endLatColumn = 'endLat';
  final String endLngColumn = 'endLng';

  MarkersDatabase._contructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'routes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $_tablesName(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      $userIdColumn TEXT,
      $agentIdColumn TEXT,
      $startLatColumn REAL,
      $startLngColumn REAL,
      $endLatColumn REAL,
      $endLngColumn REAL
    )
''');
  }

  Future<void> insertRoute(Map<String, dynamic> route) async {
    print(route);
    final db = await database;
    await db.insert(_tablesName, route);
  }

  Future<List<TaskList>> getRoutesByUserId(String userId) async {
    final db = await database;
    final data = await db
        .query(_tablesName, where: '$userIdColumn = ?', whereArgs: [userId]);

    print(" raw data from the database $data");

    List<TaskList> taskList = data
        .map((e) => TaskList(
            id: e['id'] as int,
            userId: e[userIdColumn] as String,
            agentId: e[agentIdColumn] as String,
            startLat: e[startLatColumn] as double,
            startLng: e[startLngColumn] as double,
            endLat: e[endLatColumn] as double,
            endLng: e[endLngColumn] as double))
        .toList();
    print(taskList);
    return taskList;
  }

  Future<void> deleteRoutesByUserId(String userId) async {
    final db = await database;
    await db
        .delete(_tablesName, where: '$userIdColumn = ?', whereArgs: [userId]);
  }
}
