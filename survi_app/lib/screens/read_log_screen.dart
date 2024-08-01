import 'package:flutter/material.dart';
import 'package:survi_app/models/assets_list.dart';
import 'package:survi_app/models/assets_sub_type_list.dart';
import 'package:survi_app/models/department_list.dart';
import 'package:survi_app/models/owners_list.dart';
import 'package:survi_app/services/master_database_service.dart';

class ReadLogs extends StatelessWidget {
   ReadLogs({super.key});

  final MasterDatabaseService _masterDatabaseService =
      MasterDatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Master Table'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Future.wait([
          _masterDatabaseService.getDeparmentLists(),
          _masterDatabaseService.getOwnersList(),
          _masterDatabaseService.getAssetsList(),
          _masterDatabaseService.getAssetsSubTypeList()
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final departmentlist = snapshot.data![0] as List<Department>;
          final ownerslist = snapshot.data![1] as List<Owners>;
          final assetslist = snapshot.data![2] as List<AssetList>;
          final assetsubtypelist = snapshot.data![3] as List<AssetsSubTypeList>;

          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dept = departmentlist[index];
                    return ListTile(
                      title: Text(dept.name),
                      subtitle: Text(dept.description),
                    );
                  },
                  childCount: departmentlist.length,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 5)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final owner = ownerslist[index];
                    return ListTile(
                      title: Text(owner.name),
                      subtitle: Text(owner.description),
                    );
                  },
                  childCount: ownerslist.length,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 5)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final asset = assetslist[index];
                    return ListTile(
                      title: Text(asset.name),
                      subtitle: Text(asset.geometry),
                    );
                  },
                  childCount: assetslist.length,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 5)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final assetsubtype = assetsubtypelist[index];
                    return ListTile(
                      title: Text(assetsubtype.name),
                      subtitle: Text(assetsubtype.description),
                    );
                  },
                  childCount: assetsubtypelist.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
