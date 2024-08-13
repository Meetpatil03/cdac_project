import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'package:survi_app/screens/home_page.dart';

import 'package:unique_identifier/unique_identifier.dart';

Future<void> resetPassword(String password, BuildContext context,String token) async {
  Map<String, String> body = {'password': password};

  String jsonString = jsonEncode(body);
  // final prefs = await SharedPreferences.getInstance();
  // final token = prefs.getString('authToken');

  String finalToken = "Token ";
  finalToken += token.toString();
  print(finalToken);

  String deviceid = (await UniqueIdentifier.serial)!;

  var uri = Uri.parse(
      'https://65bd-2409-4081-2d16-299-243e-5e45-9ea-7da9.ngrok-free.app/auth/update/resetPassword');

  var hearders = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': '69420',
    'authorization': finalToken,
    'deviceid': deviceid
  };

  var response = await http.put(uri, headers: hearders, body: jsonString);

  if (response.statusCode == 200) {
    print(response.body.toString());
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
