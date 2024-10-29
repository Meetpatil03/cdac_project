

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:survi_app/apis/web_services.dart';
import 'package:survi_app/functions/device_info.dart';

Future<void> sendLiveLocation(double longitude, double latitude) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    String routeId = "66ff77b42b5c08322d7bb4c9";
    String agentID = "66ed3d6ccd24616c17914dce";
  String? deviceId = await getDeviceId();

    Dio dio = Dio();

    WebService webService = WebService();

    // Ensure the cookie jar is initialized
    await webService.ensureInitialized();

    final cookieJar = webService.cookieJar;

    dio.interceptors.add(CookieManager(cookieJar));

    print("My Cookie: $cookieJar");

    Map<String, dynamic> body = {
      "routeId": routeId,
      "route": [
        {"lat": latitude, "lng": longitude}
      ]
    };

    Map<String, String> header = {
      "deviceId": deviceId.toString(),
      "Content-Type": "application/json",
      "ngrok-skip-browser-warning": "69420",
    };

    print("Header: $header");

    String url = 
        "https://3cc3-2409-40c2-104c-c07b-18f8-e889-ca55-9ccc.ngrok-free.app/auth/update/$agentID";

    final response = await dio.patch(url, data:body, options: Options(headers: header));

    if (response.statusCode == 200) {
      print(response.data);
      
      print("Location Send Successfully");
    } else {
      print("Response StatusCode : ${response.statusCode}");
    }
  } catch (e) {
    print(e.toString());
  }
}
