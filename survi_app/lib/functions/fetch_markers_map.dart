import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/services/markers_database.dart';

Future<void> storeRoutes(
  List<dynamic> routes,
) async {
  final MarkersDatabase markersDatabase = MarkersDatabase.instance;
  final prefs = await SharedPreferences.getInstance();
  String userId = (prefs.getString('user_id')).toString();
  List<dynamic> route = [];
  for (int i = 0; i < routes.length; i++) {
    int taskId = i + 1;
    String routeId = routes[i]["_id"];
    String agentId = routes[i]["agentId"];
    route = routes[i]["route"];
    for (int j = 0; j < route.length; j++) {
      double latitude = route[j]["lat"];
      double longitude = route[j]["lng"];

      Map<String, dynamic> data = {
        "task_id": taskId,
        "user_id": userId,
        "agent_id": agentId,
        "route_id": routeId,
        "latitude": latitude,
        "longitude": longitude,
        "status": 0
      };

      markersDatabase.insertRoute(data);
    }
  }
  print("Data inserted");
}
