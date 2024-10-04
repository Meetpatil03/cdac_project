import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/apis/dio_service.dart';
import 'package:survi_app/constants.dart';
import 'package:survi_app/functions/device_info.dart';
import 'package:survi_app/functions/store_master_table.dart';
import 'package:survi_app/screens/home_page.dart';

import 'package:survi_app/screens/login_screens/reset_password_screen.dart';

Future<void> loginUser(BuildContext context, String email, String password,
    String identifier) async {
  try {
    final deviceDetails = await getDeviceInfo();
    ApiService apiService = ApiService();

    apiService.login(email, password, identifier);

    // Initialize RequestPlus client with cookie handling enabled

    // final response = await http.post(
    //   Uri.parse('$baseUrl/auth/login'),
    //   headers: {
    //     "Content-Type": "application/json",
    //     "ngrok-skip-browser-warning": "69420",
    //   },
    //   body: jsonEncode({
    //     "email": email,
    //     "password": password,
    //     "deviceId": identifier,
    //     "deviceDetails": deviceDetails
    //   }),
    // );

    // if (response.statusCode == 200) {
    //   final Map<dynamic, dynamic> responseBody = jsonDecode(response.body);
    //   print(responseBody);

    //   String? cookies = response.headers['set-cookie'];
    //   if (cookies != null) {
    //     final prefs = await SharedPreferences.getInstance();
    //     await prefs.setString('cookies', cookies);
    //   }

    //   // Handle response data
    //   bool passwordReset = responseBody['password_reset'];
    //   storeMasterTable(
    //     responseBody['regions'],
    //     responseBody['department_name'],
    //     responseBody['owners_name'],
    //     responseBody['assets_types'],
    //     responseBody['assets_sub_types'],
    //   );

    //   final prefs = await SharedPreferences.getInstance();
    //   String userId = responseBody['user_id'];
    //   await prefs.setString('user_id', userId);

    //   // Handle password reset logic
    //   if (!passwordReset) {
    //     String role = responseBody['role'];
    //     tellUserToResetPassword(context, role, userId);
    //   } else {
    //     print('Login Successful, redirecting...');
    //     pushUsertoHome(context);
    //   }
    // } else {
    //   print('Response StatusCode: ${response.statusCode}');
    //   print('Response Body: ${response.body}');
    // }
  } catch (e) {
    print('Error occurred: $e');
  }
}

void tellUserToResetPassword(BuildContext context, String role, String userId) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => ResetPassword(role: role, userId: userId),
    ),
  );
}

void pushUsertoHome(BuildContext context) {
  // Navigate to the home screen
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) =>
          const HomeScreen(), // Replace HomePage with your home screen
    ),
  );
}
