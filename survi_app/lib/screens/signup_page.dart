import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/screens/login_page.dart';
import 'package:survi_app/widgets/custom_text.dart';
import 'package:survi_app/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:unique_identifier/unique_identifier.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

Future<void> createUser(
  BuildContext context,
  String username,
  String email,
  String password,
  String firstName,
  String lastName,
  String phone,
  String address,
  String identifier,
) async {
  try {
    final body = jsonEncode({
      "username": username,
      "email": email,
      "password": password,
      "firstName": firstName,
      "lastName": lastName,
      "phone": phone,
      "address": address,
      "deviceId": identifier
    });

    final headers = {
      'Content-Type': 'application/json',
    };

    // print(body.toString());
    http.Response response = await http.post(
        Uri.parse('http://192.168.150.208:3000/auth/register'),
        headers: headers,
        body: body);

    print(response.body);

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      String token = responseBody['token'];
      print('Account created, Token ${token}');

      // storing token in shared_preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      pushToLoginScreen(context);
    } else {
      print('Response Status : ${response.statusCode}');
      print('response body : ${response.body}');
    }
  } catch (e) {
    print(e.toString());
  }
}

void pushToLoginScreen(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ),
  );
}

class _SignUpState extends State<SignUp> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String _identifier = '';

  @override
  void initState() {
    super.initState();
    _initUniqueIdentifierState();
  }

  Future<void> _initUniqueIdentifierState() async {
    String identifier = '';
    try {
      identifier = (await UniqueIdentifier.serial)!;
    } catch (e) {
      print('identifier failed to get IEMI Number');
      print(e.toString());
    }

    if (!mounted) return;

    setState(() {
      _identifier = identifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.1,
            ),
            const CustomText(
              fontSize: 50,
              text: 'Sign Up',
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            CustomTextField(
              textInputType: TextInputType.name,
              controller: firstnameController,
              label: 'First-Name',
              suffixIcons: const Icon(Icons.person),
              obscureText: false, function: () {  }, function2: () {  },
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextField(
              controller: lastnameController,
              label: 'Last-Name',
              suffixIcons: const Icon(Icons.person),
              obscureText: false,
              textInputType: TextInputType.name, function: () {  }, function2: () {  },
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextField(
              controller: usernameController,
              label: 'User-Name',
              suffixIcons: const Icon(Icons.edit_document),
              obscureText: false,
              textInputType: TextInputType.name, function: () {  }, function2: () {  },
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextField(
              controller: emailController,
              label: 'Email-ID',
              suffixIcons: const Icon(Icons.mail_rounded),
              obscureText: false,
              textInputType: TextInputType.emailAddress, function: () {  }, function2: () {  },
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 5, color: Colors.blue),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 2, color: Colors.purple),
                  borderRadius: BorderRadius.circular(15),
                ),
                suffixIcon: const Icon(Icons.dialpad),
                label: const Text(
                  'Phone',
                  style: TextStyle(fontSize: 20),
                ),
                contentPadding: const EdgeInsets.all(15),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextField(
                controller: passwordController,
                textInputType: TextInputType.text,
                label: 'Password',
                suffixIcons: const Icon(Icons.key_rounded),
                obscureText: true, function: () {  }, function2: () {  },),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: addressController,
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 5, color: Colors.blue),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 2, color: Colors.purple),
                  borderRadius: BorderRadius.circular(15),
                ),
                suffixIcon: const Icon(Icons.map_rounded),
                label: const Text(
                  'Address',
                  style: TextStyle(fontSize: 20),
                ),
                contentPadding: const EdgeInsets.all(15),
              ),
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            ElevatedButton(
              onPressed: () async {
                createUser(
                  context,
                  usernameController.text.toString(),
                  emailController.text.toString(),
                  passwordController.text.toString(),
                  firstnameController.text.toString(),
                  lastnameController.text.toString(),
                  phoneController.text.toString(),
                  addressController.text.toString(),
                  _identifier,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(size.width / 3, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              child: const Text(
                'Already have Account? Login',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
