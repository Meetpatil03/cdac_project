import 'dart:async';
import 'package:survi_app/functions/push_local_to_mongodb.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
     await pushLocalDataToMongoDB();

    return Future.value(true);
  });
}
