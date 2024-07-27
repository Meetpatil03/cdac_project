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
    _checkAuthToken();
  }

  Future<void> _checkAuthToken() async {
    print("Checking for auth token...");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    print("Token: $token");

    if (token != null) {
      print("Token found, navigating to HomeScreen...");
      // Navigate to home screen if token exists
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      print("No token found, navigating to SignUpScreen...");
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
