import 'package:flutter/material.dart';
import 'package:survi_app/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asset Tracker',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromRGBO(13, 16, 34, 1),
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: const Color.fromRGBO(13, 16, 34, 1),
        )
      ),
      home: const SplashScreen(),
    );
  }
}


// changes to be made again home : SplashScreen()