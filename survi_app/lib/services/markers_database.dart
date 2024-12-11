import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:survi_app/models/task_list.dart';

class MarkersDatabase {
  static Database? _db;
  static final MarkersDatabase instance = MarkersDatabase._contructor();

  final String _tablesName = 'markers';
  final String _idColumn = 'id';
  final String _userIdColumn = 'user_id';
  final String _taskIdColumn = 'task_id';
  final String _agentIdColumn = 'agent_id';
  final String _routeIdColumn = 'route_id';
  final String _latitudeColumn = 'latitude';
  final String _longitudeColumn = 'longitude';
  final String _statusColumn = 'status';

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
      $_idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
      $_taskIdColumn REAL,
      $_userIdColumn TEXT,
      $_agentIdColumn TEXT,
      $_routeIdColumn TEXT,
      $_latitudeColumn REAL,
      $_longitudeColumn REAL,
      $_statusColumn INTEGER
    )
''');
  }

  Future<void> insertRoute(Map<String, dynamic> route) async {
    print(route);
    final db = await database;
    await db.insert(_tablesName, route);
    print("inserted in SQLite $route");
  }

  Future<List<TaskList>> getAllRoutes() async {
    final db = await database;
    final data = await db.query(_tablesName);

    List<TaskList> routes = data
        .map(
          (e) => TaskList(
            id: e[_idColumn] as int,
            taskId: (e[_taskIdColumn] as num).toInt(),
            agentId: e[_agentIdColumn] as String,
            routeId: e[_routeIdColumn] as String,
            latitude: (e[_latitudeColumn] as num).toDouble(),
            longitude: (e[_longitudeColumn] as num).toDouble(),
            status: (e[_statusColumn] as num).toInt(),
            userId: e[_userIdColumn] as String,
          ),
        )
        .toList();

    return routes;
  }

  Future<List<TaskList>> getParticularTasksRoute(int taskId) async {
    final db = await database;
    final data =
        await db.query(_tablesName, where: '$taskId = ?', whereArgs: [taskId]);

    List<TaskList> stops = data
        .map(
          (e) => TaskList(
            id: e[_idColumn] as int,
            taskId: (e[_taskIdColumn] as num).toInt(),
            agentId: e[_agentIdColumn] as String,
            routeId: e[_routeIdColumn] as String,
            latitude: (e[_latitudeColumn] as num).toDouble(),
            longitude: (e[_longitudeColumn] as num).toDouble(),
            status: (e[_statusColumn] as num).toInt(),
            userId: e[_userIdColumn] as String,
          ),
        )
        .toList();

    return stops;
  }

}
