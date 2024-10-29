import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:survi_app/apis/web_services.dart';
import 'package:survi_app/constants.dart';

import 'package:survi_app/screens/home_page.dart';

import 'package:unique_identifier/unique_identifier.dart';

Future<void> resetPassword(String password, BuildContext context) async {
  Map<String, String> body = {'password': password};

  Dio dio = Dio();
  WebService webService = WebService();

  // Ensure the cookie jar is initialized
  await webService.ensureInitialized();

  final cookieJar = webService.cookieJar;

  dio.interceptors.add(CookieManager(cookieJar));

  print("My Cookie: $cookieJar");

  String deviceid = (await UniqueIdentifier.serial)!;

  String url = '$baseUrl/auth/update/resetPassword';

  var headers = {'ngrok-skip-browser-warning': '69420', 'deviceid': deviceid};

  print(body);

  var response = await dio.put(url,
      data: body,
      options: Options(contentType: 'application/json', headers: headers));

  if (response.statusCode == 200) {
    // navigate to HomePage
    pushUserToHomePage(context);
  } else {
    print('Response StatusCode : ${response.statusCode}');
  }
}

// push User to Home Page

void pushUserToHomePage(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const HomeScreen(),
    ),
  );
}
