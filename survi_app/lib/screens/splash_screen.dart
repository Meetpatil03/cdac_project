import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    print("Checking for Cookies...");
    final prefs = await SharedPreferences.getInstance();
    final cookies = prefs.getString('cookies');
    print("Cookies: $cookies");

    if (cookies != null) {
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
