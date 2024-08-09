import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/functions/device_info.dart';
import 'package:survi_app/functions/store_master_table.dart';
import 'package:survi_app/screens/login_screens/login_page.dart';
import 'package:survi_app/screens/login_screens/reset_password_screen.dart';

Future<void> loginUser(BuildContext context, String email, String password,
    String identifier) async {
  try {
    final deviceDetials = await getDeviceInfo();
    final body = jsonEncode({
      "email": email,
      "password": password,
      "deviceId": identifier,
      "deviceDetails": deviceDetials
    });
    final headers = {
      'Content-Type': 'application/json',
      "ngrok-skip-browser-warning": "69420",
    };

    http.Response response = await http.post(
        Uri.parse(
            'https://f811-2409-40c2-101a-6dfb-c099-36eb-2a49-3190.ngrok-free.app/auth/login'),
        headers: headers,
        body: body);

    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String token = responseBody['token'];
      bool passwordReset = responseBody['password_reset'];

      // updating the existing token
      // final prefs = await SharedPreferences.getInstance();
      // final oldtoken = prefs.getString('authToken');
      // await prefs.setString('authToken', token);
      // print('Old Token : $oldtoken');
      // print('Updated Token : $token');
      storeMasterTable(
        responseBody['regions'],
        responseBody['department_name'],
        responseBody['owners_name'],
        responseBody['assets_types'],
        responseBody['assets_sub_types']
      );
      if (!passwordReset) {
         
        String role = responseBody['role'];
        String userId = responseBody['user_id'];
        tellUserToResetPassword(context, role, userId,token);
      } else {
         final prefs = await SharedPreferences.getInstance();
      final oldtoken = prefs.getString('authToken');
      await prefs.setString('authToken', token);
      print('Old Token : $oldtoken');
      print('Updated Token : $token');
        pushUsertoHome(context);
      }
    } else {
      print('Response StatusCode : ${response.statusCode}');
      print('Response Body : ${response.body}');
    }
  } catch (e) {
    print(e.toString());
  }
}

void tellUserToResetPassword(BuildContext context, String role, String userId,String token) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => ResetPassword(
        role: role,
        userId: userId, token: token,
      ),
    ),
  );
}
