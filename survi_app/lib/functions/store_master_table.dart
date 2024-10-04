import 'package:survi_app/services/master_database_service.dart';

final MasterDatabaseService _masterDatabaseService =
    MasterDatabaseService.instance;
void storeMasterTable(
  List<dynamic> regionsList,
  List<dynamic> departmentList,
  List<dynamic> ownersList,
  List<dynamic> assetslist,
  List<dynamic> assetsSubTypeList,
) async {
  for (var region in regionsList) {
    Map<String, dynamic> data = {"region_name": region['name']};
    await _masterDatabaseService.insertorUdateRegions(data);
    print("inserted regions : $data");
  }

  // insert all department list into department table
  for (var department in departmentList) {
    Map<String, dynamic> data = {
      "department_name": department['department_name'],
      "ref_owner": department['owner_name'],
    };
    await _masterDatabaseService.insertOrUpdateDepartment(data);
    print("inserted department : $data");
  }

  for (var owners in ownersList) {
    Map<String, dynamic> data = {
      "owners_name": owners['owner_name'],
      "ref_region": owners['region_name'],
    };
    await _masterDatabaseService.insertOrUpdateOwner(data);
    print("inserted owner : $data");
  }

  for (var assets in assetslist) {
    Map<String, dynamic> data = {
      "asset_types_name": assets['asset_type_name'],
      "ref_department": assets['department_name'],
    };
    await _masterDatabaseService.insertOrUpdateAsset(data);
    print("inserted assets : $data");
  }

  for (var assetsSubType in assetsSubTypeList) {
    Map<String, dynamic> data = {
      "assets_sub_type_name": assetsSubType['asset_sub_type_name'],
      "ref_assets": assetsSubType['asset_type_name'],
      "description": assetsSubType['description']
    };
    await _masterDatabaseService.insertOrUpdateAssetSubType(data);
    print("inserted assetsSubType : $data");
  }

  print("MasterTable successfully inserted or updated");
}
