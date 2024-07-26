import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/screens/login_page.dart';

Future<void> loginUser(BuildContext context, String email, String password,
    String identifier) async {
  try {
    final body = jsonEncode(
        {"email": email, "password": password, "deviceId": identifier});
    final headers = {
      'Content-Type': 'application/json',
      "ngrok-skip-browser-warning": "69420",
    };

    http.Response response = await http.post(
        Uri.parse('https://7566-2409-40c2-3045-2d45-8c3d-396d-17c0-3883.ngrok-free.app/auth/login'),
        headers: headers,
        body: body);

    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String token = responseBody['token'];

      // updating the existing token
      final prefs = await SharedPreferences.getInstance();
      final oldtoken = prefs.getString('authToken');
      await prefs.setString('authToken', token);
      print('Old Token : $oldtoken');
      print('Updated Token : $token');
      pushUsertoHome(context);
    } else {
      print('Response StatusCode : ${response.statusCode}');
      print('Response Body : ${response.body}');
    }
  } catch (e) {
    print(e.toString());
  }
}
