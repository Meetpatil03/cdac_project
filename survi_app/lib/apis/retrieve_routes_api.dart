import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/apis/web_services.dart';
import 'package:survi_app/constants.dart';
import 'package:survi_app/functions/device_info.dart';
import 'package:survi_app/functions/fetch_markers_map.dart';


Future<void> retrieveRoutesApi() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id').toString();
    String url =
        '$baseUrl/admin/route/$userId';
    print(url);

    Dio dio = Dio();

    WebService webService = WebService();

    // Ensure the cookie jar is initialized
    await webService.ensureInitialized();

    final cookieJar = webService.cookieJar;

    dio.interceptors.add(CookieManager(cookieJar));

    String? deviceId = await getDeviceId();

    Map<String, String> header = {
      'deviceId': deviceId ?? 'null',
      'ngrok-skip-browser-warning': '69420'
    };

    print(header);
    final response = await dio.get(url, options: Options(headers: header));

    if (response.statusCode == 200) {
      var data = response.data;
      storeRoutes(data["routes"]);
      print("Data fetched successfully : $data");
    } else {
      print(
          "Failed to load data, Response statusCode : ${response.statusCode}");
    }
  } catch (e) {
    print(e.toString());
  }
}
