import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:survi_app/models/assets_list.dart';
import 'package:survi_app/models/assets_sub_type_list.dart';

import 'package:survi_app/models/department_list.dart';
import 'package:survi_app/models/owners_list.dart';
import 'package:survi_app/models/regions_list.dart';

class MasterDatabaseService {
  static Database? _db;
  static final MasterDatabaseService instance =
      MasterDatabaseService._constructor();

  final String _regionsTalbe = "regions";
  final String _regionsColumnName = "region_name";

  final String _deparmentsTable = "department";
  final String _deptColumnName = "department_name";
  final String _deptColumnRefernce = "ref_owner";

  final String _ownersTable = "owners";
  final String _ownersColumnName = "owners_name";
  final String _ownersColumnReference = "ref_region";

  final String _assetsTable = "assets";
  final String _assetsColumnName = "asset_types_name";
  final String _assetsColumnReference = 'ref_department';

  final String _assetsSubTypeTable = "assets_sub_types";
  final String _assetsSubTypeColumnName = "assets_sub_type_name";
  final String _assetSubTypeColumnReference = "ref_assets";
  final String _assetSubTypeColumnDescription = "description";

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
      CREATE TABLE $_regionsTalbe(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        $_regionsColumnName TEXT UNIQUE
      )
''');
    await db.execute('''
        CREATE TABLE $_deparmentsTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        $_deptColumnName TEXT UNIQUE,
        $_deptColumnRefernce TEXT
        )
''');

    await db.execute('''
    CREATE TABLE $_ownersTable(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      $_ownersColumnName TEXT UNIQUE,
      $_ownersColumnReference TEXT
    )
''');

    await db.execute('''
    CREATE TABLE $_assetsTable(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      $_assetsColumnName TEXT UNIQUE,
      $_assetsColumnReference TEXT
     
    )
''');

    await db.execute('''
    CREATE TABLE $_assetsSubTypeTable(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      $_assetsSubTypeColumnName TEXT UNIQUE,
      $_assetSubTypeColumnReference TEXT,
      $_assetSubTypeColumnDescription TEXT
    )
''');
  }

  Future<void> insertorUdateRegions(
    Map<String, dynamic> regionItems,
  ) async {
    final database = await getDatabase();
    await database.insert(_regionsTalbe, regionItems,
        conflictAlgorithm: ConflictAlgorithm.replace);
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

  Future<List<RegionsList>> getRegionsList() async {
    final db = await getDatabase();
    final data = await db.query(_regionsTalbe);
    List<RegionsList> regionsList = data
        .map((e) => RegionsList(
            id: e['id'] as int, regionsName: e[_regionsColumnName] as String))
        .toList();

    print("Region List : ${regionsList}");
    return regionsList;
  }

  Future<List<Department>> getDeparmentLists() async {
    final db = await getDatabase();
    final data = await db.query(_deparmentsTable);

    List<Department> departmentlist = data
        .map((e) => Department(
              id: e['id'] as int,
              departmentName: e[_deptColumnName] as String,
              referenceTable: e[_deptColumnRefernce] as String,
            ))
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
              ownerName: e[_ownersColumnName] as String,
              reference: e[_ownersColumnReference] as String,
            ))
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
            assetsName: e[_assetsColumnName] as String,
            reference: e[_assetsColumnReference] as String))
        .toList();

    print("assets List : ${assetslist}");

    return assetslist;
  }

  Future<List<AssetsSubTypeList>> getAssetsSubTypeList() async {
    final db = await getDatabase();
    final data = await db.query(_assetsSubTypeTable);

    List<AssetsSubTypeList> assetsubtypelist = data
        .map((e) => AssetsSubTypeList(
            assetsSubTypeName: e[_assetsSubTypeColumnName] as String,
            reference: e[_assetSubTypeColumnReference] as String,
            description: e[_assetSubTypeColumnDescription] as String,
            id: e['id'] as int))
        .toList();

    print('Assets Sub Type : ${assetsubtypelist}');

    return assetsubtypelist;
  }
}
