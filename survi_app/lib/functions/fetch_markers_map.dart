import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/services/markers_database.dart';

Future<void> storeRoutes(
  Map<String, dynamic> data,
) async {
  final MarkersDatabase _markersDatabase = MarkersDatabase.instance;
  final prefs = await SharedPreferences.getInstance();
  String userId = (prefs.getString('user_id')).toString();

  for (var route in data['routes']) {
    String agentId = route['agentId'];
    double startLat = route['route'][0]["lat"];
    double startLng = route['route'][0]["lng"];
    double endLat = route['route'][1]["lat"];
    double endLng = route['route'][1]["lng"];

    print("agentId $agentId, startLat: $startLat, startLng: $startLng, endLat: $endLat, endLng: $endLng");

    Map<String, dynamic> routeData = {
      'user_id': userId,
      'agent_id': agentId,
      'startLat': startLat,
      'startLng': startLng,
      'endLat': endLat,
      'endLng': endLng
    };

     _markersDatabase.insertRoute(routeData);
    print("Data inserted");
  }
}
