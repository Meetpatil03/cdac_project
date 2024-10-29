import 'dart:async';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/constants.dart';
import 'package:survi_app/functions/device_info.dart';
import 'package:survi_app/functions/store_master_table.dart';
import 'package:survi_app/screens/home_page.dart';
import 'package:survi_app/screens/login_screens/reset_password_screen.dart';
import 'package:survi_app/services/master_database_service.dart';

class WebService {
  WebService() {
    _completer = Completer<void>();
    _initialize(); // Initialize variables in the constructor
  }

  final dio = Dio();
  late PersistCookieJar
      cookieJar; // Declare it as late to ensure it's initialized later
  late Completer<void> _completer;

  Future<void> _initialize() async {
    // Get the application documents directory path
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path; // Initialize appDocPath

    // Initialize the cookie jar
    cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(appDocPath + "/.cookies/"), // Correct usage
    );

    // Set base options and SSL certificate handling
    dio.options = BaseOptions(
      validateStatus: (status) {
        return status != null && status < 500; // Accept all responses < 500
      },
    );

    // Create a new IOHttpClientAdapter with createHttpClient
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // Create the HttpClient
        final client = HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) =>
                  true; // Allow invalid certificates
        return client;
      },
    );

    // Add the log interceptor
    dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
      requestHeader: true,
    ));

    // Add CookieManager to Dio
    dio.interceptors.add(CookieManager(cookieJar));
    _completer.complete();
  }

  Future<void> ensureInitialized() async {
    await _completer.future;
  }

  Future<void> loginFunction(
    String email,
    String password,
    String identifier,
    BuildContext context,
  ) async {
    print("Login initiated...");
    Response response;
    try {
      final deviceDetails = await getDeviceInfo();
      Map<String, dynamic> body = {
        "email": email,
        "password": password,
        "deviceId": identifier,
        "deviceDetails": deviceDetails,
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final MasterDatabaseService masterDatabaseService =
          MasterDatabaseService.instance;

      // Perform login request
      response = await dio.post(
        "$baseUrl/auth/login",
        data: body,
        options: Options(
          contentType: "application/json",
          headers: {"ngrok-skip-browser-warning": "69420"},
        ),
      );

      if (response.statusCode == 200) {
        print("Login successful");
        await prefs.setString('user_id', response.data['user_id']);
        storeMasterTable(
          response.data['regions'],
          response.data['department_name'],
          response.data['owners_name'],
          response.data['assets_types'],
          response.data['assets_sub_types'],
        );
        // Retrieve cookies manually from response headers
        final setCookies = response.headers['set-cookie'];
        if (setCookies != null) {
          print("Cookies from login: $setCookies");

          // Parse and store cookies manually
          List<Cookie> cookies = [];

          for (var setCookie in setCookies) {
            cookies.add(Cookie.fromSetCookieValue(
                setCookie)); // Use add instead of addAll
          }

          // Manually store cookies in the cookie jar
          final uri = Uri.parse("$baseUrl");
          cookieJar.saveFromResponse(
              uri, cookies); // Save cookies to cookie jar
          print("Cookies saved to CookieJar: $cookies");
        }

        if (response.data["password_reset"] == false) {
          // tell User to Reset Password
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ResetPassword(
                  role: response.data['role'],
                  userId: response.data['user_id']),
            ),
          );
        } else {
          // Navigate to the next screen if necessary
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        print("Failed: ${response.statusCode}");
        print("Error Message: ${response.data}");
      }
    } catch (errorMessage) {
      print("Error during login: $errorMessage");
    }
  }
}
