import 'package:survi_app/models/assets_list.dart';
import 'package:survi_app/models/assets_sub_type_list.dart';
import 'package:survi_app/models/department_list.dart';
import 'package:survi_app/models/owners_list.dart';
import 'package:survi_app/models/regions_list.dart';
import 'package:survi_app/services/master_database_service.dart';

class FetchMasterTable {
  static final FetchMasterTable _instance = FetchMasterTable._constructor();

  static FetchMasterTable get instance => _instance;

  final MasterDatabaseService _masterDatabaseService =
      MasterDatabaseService.instance;

  static List<RegionsList>? _regionsList;
  static List<Department>? _deptList;
  static List<Owners>? _ownerList;
  static List<AssetList>? _assetList;
  static List<AssetsSubTypeList>? _assetsSubTypeList;

  FetchMasterTable._constructor();

  Future<List<RegionsList>> getRegionsList() async {
    _regionsList = await _masterDatabaseService.getRegionsList();
    return _regionsList!;
  }

  Future<List<Department>> getDepartmentList(String owner) async {
    _deptList = await _masterDatabaseService.getDeparmentLists(owner);
    return _deptList!;
  }

  Future<List<Owners>> getOwnersList(String region) async {
    _ownerList = await _masterDatabaseService.getOwnersList(region);
    return _ownerList!;
  }

  Future<List<AssetList>> getAssetList(String department) async {
    _assetList = await _masterDatabaseService.getAssetsList(department);
    return _assetList!;
  }

  Future<List<AssetsSubTypeList>> getAssetsSubTypeList(String asset) async {
    _assetsSubTypeList = await _masterDatabaseService.getAssetsSubTypeList(asset);
    return _assetsSubTypeList!;
  }
}
