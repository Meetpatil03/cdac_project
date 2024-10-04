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

Future<void> startWorkManager() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  await Workmanager().registerPeriodicTask("syncTask", "syncTask",
      frequency: const Duration(minutes: 15));
}

Future<void> stopWorkManager() async {
  await Workmanager().cancelByUniqueName("syncTask");
}
