import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:survi_app/constants.dart';


import 'package:survi_app/screens/home_page.dart';

import 'package:unique_identifier/unique_identifier.dart';

Future<void> resetPassword(String password, BuildContext context) async {
  Map<String, String> body = {'password': password};

  String jsonString = jsonEncode(body);
  
  

  String deviceid = (await UniqueIdentifier.serial)!;

  var uri = Uri.parse(
      '$baseUrl/auth/update/resetPassword');

  var hearders = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': '69420',
    
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
      builder: (context) =>  const HomeScreen(),
    ),
  );
}
