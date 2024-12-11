import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survi_app/provider_services/workmanager_services.dart';
import 'package:survi_app/screens/login_screens/login_page.dart';
import 'package:survi_app/screens/splash_screen.dart';
import 'package:survi_app/services/log_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LogService.init();

  runApp(ChangeNotifierProvider(
      create: (_) => WorkManagerState(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asset Tracker',
      // theme: ThemeData.dark().copyWith(
      //   scaffoldBackgroundColor: const Color.fromRGBO(13, 16, 34, 1),
      //   appBarTheme: const AppBarTheme().copyWith(
      //     backgroundColor: const Color.fromRGBO(13, 16, 34, 1),
      //   ),
      // ),
      home: LoginScreen(),
    );
  }
}
