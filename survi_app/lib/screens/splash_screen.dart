import 'dart:io';

import 'package:flutter/material.dart';
import 'package:survi_app/apis/web_services.dart';
import 'package:survi_app/constants.dart';
import 'package:survi_app/screens/home_page.dart';
import 'package:survi_app/screens/onboarding_screens/onboarding_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkCookie();
  }

  Future<void> _checkCookie() async {
    WebService webService = WebService();

    // ensure cookiejar is initialized
    await webService.ensureInitialized();

    final uri = Uri.parse(baseUrl);

    // get cookies for specified Uri
    List<Cookie> cookies = await webService.cookieJar.loadForRequest(uri);

    if (cookies.isNotEmpty) {
      print("Token found, navigating to HomeScreen...");
      // Navigate to home screen if token exists
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      print("No Cookies found, navigating to OnBoarding...");
      // Navigate to login screen if no token

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
