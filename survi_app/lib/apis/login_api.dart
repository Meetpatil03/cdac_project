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
    };

    http.Response response = await http.post(
        Uri.parse('https://d28e-2409-4081-2c01-3dd6-6108-af72-1527-fda.ngrok-free.app/auth/login'),
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
