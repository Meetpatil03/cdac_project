import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:survi_app/models/assets_list.dart';
import 'package:survi_app/models/assets_sub_type_list.dart';

import 'package:survi_app/models/department_list.dart';
import 'package:survi_app/models/owners_list.dart';

class MasterDatabaseService {
  static Database? _db;
  static final MasterDatabaseService instance =
      MasterDatabaseService._constructor();

  final String _deparmentsTable = "department_name";
  final String _deptColumnName = "name";
  final String _deptColumnDescription = "description";

  final String _ownersTable = "owners_name";
  final String _ownersColumnName = "name";
  final String _ownersColumnDescription = "description";

  final String _assetsTable = "assets_types";
  final String _assetsColumnName = "name";
  final String _assetsColumnDescription = "description";
  final String _assetsColumnGeometry = "geometry";

  final String _assetsSubTypeTable = "assets_sub_types";
  final String _assetsSubTypeColumnName = "name";
  final String _assetsSubTypeColumnDescription = "description";
  // final String _assetsSubTypeColumnAssetType = "asset_type";

  MasterDatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    _db = await getDatabase();

    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_database.db');
    final database =
        await openDatabase(databasePath, version: 1, onCreate: _onCreate);

    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE $_deparmentsTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        $_deptColumnName TEXT UNIQUE,
        $_deptColumnDescription TEXT
        )
''');

    await db.execute('''
    CREATE TABLE $_ownersTable(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      $_ownersColumnName TEXT UNIQUE,
      $_ownersColumnDescription TEXT
    )
''');

    await db.execute('''
    CREATE TABLE $_assetsTable(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      $_assetsColumnName TEXT UNIQUE,
      $_assetsColumnDescription TEXT,
      $_assetsColumnGeometry TEXT
    )
''');

    await db.execute('''
    CREATE TABLE $_assetsSubTypeTable(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      $_assetsSubTypeColumnName TEXT UNIQUE,
      $_assetsSubTypeColumnDescription TEXT
    )
''');
  }

  Future<void> insertOrUpdateDepartment(
      Map<String, dynamic> departmentItem) async {
    final database = await getDatabase();
    await database.insert(_deparmentsTable, departmentItem,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertOrUpdateOwner(Map<String, dynamic> ownersItem) async {
    final database = await getDatabase();
    await database.insert(_ownersTable, ownersItem,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertOrUpdateAsset(Map<String, dynamic> assetsItem) async {
    final database = await getDatabase();
    await database.insert(_assetsTable, assetsItem,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertOrUpdateAssetSubType(
      Map<String, dynamic> assetSubTypeItem) async {
    final database = await getDatabase();
    await database.insert(_assetsSubTypeTable, assetSubTypeItem,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Department>> getDeparmentLists() async {
    final db = await getDatabase();
    final data = await db.query(_deparmentsTable);

    List<Department> departmentlist = data
        .map((e) => Department(
            id: e['id'] as int,
            name: e[_deptColumnName] as String,
            description: e[_deptColumnDescription] as String))
        .toList();

    print("Department List : ${departmentlist}");
    return departmentlist;
  }

  Future<List<Owners>> getOwnersList() async {
    final db = await getDatabase();
    final data = await db.query(_ownersTable);

    List<Owners> ownerslist = data
        .map((e) => Owners(
            id: e['id'] as int,
            name: e[_ownersColumnName] as String,
            description: e[_ownersColumnDescription] as String))
        .toList();

    print("Owners List : ${ownerslist}");
    return ownerslist;
  }

  Future<List<AssetList>> getAssetsList() async {
    final db = await getDatabase();
    final data = await db.query(_assetsTable);

    List<AssetList> assetslist = data
        .map((e) => AssetList(
            id: e['id'] as int,
            name: e[_assetsColumnName] as String,
            description: e[_assetsColumnDescription] as String,
            geometry: e[_assetsColumnGeometry] as String))
        .toList();

    print("assets List : ${assetslist}");

    return assetslist;
  }

  Future<List<AssetsSubTypeList>> getAssetsSubTypeList() async {
    final db = await getDatabase();
    final data = await db.query(_assetsSubTypeTable);

    List<AssetsSubTypeList> assetsubtypelist = data
        .map((e) => AssetsSubTypeList(
            id: e['id'] as int,
            name: e[_assetsSubTypeColumnName] as String,
            description: e[_assetsSubTypeColumnDescription] as String))
        .toList();

    print('Assets Sub Type : ${assetsubtypelist}');

    return assetsubtypelist;
  }
}
