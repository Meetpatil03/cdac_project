import 'package:survi_app/models/assets_list.dart';
import 'package:survi_app/models/assets_sub_type_list.dart';
import 'package:survi_app/models/department_list.dart';
import 'package:survi_app/models/owners_list.dart';
import 'package:survi_app/services/master_database_service.dart';

class FetchMasterTable {
  static final FetchMasterTable _instance = FetchMasterTable._constructor();

  static FetchMasterTable get instance => _instance;

  final MasterDatabaseService _masterDatabaseService =
      MasterDatabaseService.instance;

  static List<Department>? _deptList;
  static List<Owners>? _ownerList;
  static List<AssetList>? _assetList;
  static List<AssetsSubTypeList>? _assetsSubTypeList;

  FetchMasterTable._constructor();

  Future<List<Department>> getDepartmentList() async {
    _deptList = await _masterDatabaseService.getDeparmentLists();
    return _deptList!;
  }

  Future<List<Owners>> getOwnersList() async {
    _ownerList = await _masterDatabaseService.getOwnersList();
    return _ownerList!;
  }

  Future<List<AssetList>> getAssetList() async {
    _assetList = await _masterDatabaseService.getAssetsList();
    return _assetList!;
  }

  Future<List<AssetsSubTypeList>> getAssetsSubTypeList() async {
    _assetsSubTypeList = await _masterDatabaseService.getAssetsSubTypeList();
    return _assetsSubTypeList!;
  }
}
