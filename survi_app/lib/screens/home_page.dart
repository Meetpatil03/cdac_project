import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/screens/form_page.dart';
import 'package:survi_app/screens/login_page.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> _logout() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      print('Removing Token....');
      await prefs.remove('authToken');
      print('You Logged out Successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: _logout, icon: const Icon(Icons.logout_outlined))
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const FormPage(),
              ),
            );
          },
          
          child: const Text('Survey Form',style: TextStyle(fontSize: 20),),
        ),
      ),
    );
  }
}
