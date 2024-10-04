import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:survi_app/constants.dart';
import 'package:survi_app/functions/device_info.dart';

class ApiService {
  Dio dio = Dio();
  CookieJar cookieJar = CookieJar();

  ApiService() {
    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<void> login(String email, String password, String identifier) async {
    final deviceDetails = await getDeviceInfo();

    print(baseUrl);

    final loginData = {
      "email": email,
      "password": password,
      "deviceId": identifier,
      "deviceDetails": deviceDetails
    };

    try {
      Response response = await dio.post(
        "$baseUrl/auth/login",
        data: loginData,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        // cookie automatically saved by cookie manager
        print("login Successfully");
        print(response.data);
      } else {
        print("login Failed: ${response.data}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
