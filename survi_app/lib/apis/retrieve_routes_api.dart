import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/constants.dart';
import 'package:survi_app/functions/device_info.dart';
import 'package:survi_app/functions/fetch_markers_map.dart';

Future<void> retrieveRoutesApi() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id').toString();
    String url = '$baseUrl/admin/route/$userId';
    print(url);
    String token = prefs.getString('authToken').toString();
    token = "Token $token";
    String? deviceId = await getDeviceId();

    Map<String, String> header = {
      'Authorization': token,
      'deviceId': deviceId ?? 'null'
    };

    print(header);
    final response = await http.get(Uri.parse(url), headers: header);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      storeRoutes(data);
      print("Data fetched successfully : $data");
    } else {
      print(
          "Failed to load data, Response statusCode : ${response.statusCode}");
    }
  } catch (e) {
    print(e.toString());
  }
}
