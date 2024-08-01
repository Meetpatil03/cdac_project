import 'package:survi_app/services/master_database_service.dart';

final MasterDatabaseService _masterDatabaseService =
    MasterDatabaseService.instance;
void storeMasterTable(
  List<dynamic> departmentList,
  List<dynamic> ownersList,
  List<dynamic> assetslist,
  List<dynamic> assetsSubTypeList,
) async {
  // insert all department list into department table
  for (var department in departmentList) {
    Map<String, dynamic> data = {
      "name": department['name'],
      "description": department['description'],

    };
    await _masterDatabaseService.insertOrUpdateDepartment(data);
    print("inserted department : ${data}");
  }

  for (var owners in ownersList) {
     Map<String, dynamic> data = {
      "name": owners['name'],
      "description": owners['description'],

    };
    await _masterDatabaseService.insertOrUpdateOwner(data);
    print("inserted owner : ${data}");
  }

  for (var assets in assetslist) {
     Map<String, dynamic> data = {
      "name": assets['name'],
      "description": assets['description'],
      "geometry": assets['geometry']

    };
    await _masterDatabaseService.insertOrUpdateAsset(data);
    print("inserted assets : ${data}");
  }

  for (var assetsSubType in assetsSubTypeList) {
     Map<String, dynamic> data = {
      "name": assetsSubType['name'],
      "description": assetsSubType['description'],

    };
    await _masterDatabaseService.insertOrUpdateAssetSubType(data);
    print("inserted assetsSubType : ${data}");
  }

  print("MasterTable successfully inserted or updated");
}
