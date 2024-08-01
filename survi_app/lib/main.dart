import 'package:flutter/material.dart';
import 'package:survi_app/screens/form_page.dart';
import 'package:survi_app/screens/splash_screen.dart';
import 'package:survi_app/services/background_push_data_service.dart';
import 'package:survi_app/services/log_services.dart';
import 'package:workmanager/workmanager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await LogService.init();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager().registerPeriodicTask("syncTask", "syncTask",
      frequency: const Duration(minutes: 15));
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
          )),
      home:  const SplashScreen(),
    );
  }
}


