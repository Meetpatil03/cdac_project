import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:survi_app/apis/login_api.dart';
import 'package:survi_app/screens/home_page.dart';
import 'package:survi_app/widgets/custom_text.dart';
import 'package:unique_identifier/unique_identifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

void pushUsertoHome(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) =>  const HomeScreen(),
    ),
  );
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Artboard? mainArtBoard;
  StateMachineController? _stateMachineController;
  SMIBool? isChecking;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;
  SMIInput<double>? look;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  String _identifier = '';

  @override
  void initState() {
    super.initState();

    _initUniqueIdentifierState();
    RiveFile.initialize().then((_) {
       rootBundle
        .load('assets/rive/animated_login_character.riv')
        .then((byteData) {
      var riveFile = RiveFile.import(byteData);
      var mArtBoard = riveFile.mainArtboard;
      _stateMachineController =
          StateMachineController.fromArtboard(mArtBoard, 'Login Machine');

      if (_stateMachineController != null) {
        mArtBoard.addController(_stateMachineController!);
        mainArtBoard = mArtBoard;
        isChecking = _stateMachineController!.findSMI('isChecking');
        isHandsUp = _stateMachineController!.findSMI('isHandsUp');
        trigSuccess = _stateMachineController!.findSMI('trigSuccess');
        trigFail = _stateMachineController!.findSMI('trigFail');
        look =
            _stateMachineController!.findInput<double>('numLook') as SMINumber;

        setState(() {});
      }
    });
    });

   
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           
            mainArtBoard != null
                ? SizedBox(
                    height: 300,
                    width: size.width,
                    child: Rive(
                      artboard: mainArtBoard!,
                    ))
                : Container(),
            const CustomText(fontSize: 80, text: 'Login'),
            SizedBox(
              height: size.height * 0.05,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    isChecking?.value = true;

                    int stringCount = value.length;
                    look!.change((stringCount * 100) / 35);
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    isChecking?.value = false;
                  });
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 5, color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(width: 2, color: Colors.purple),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  suffixIcon: const Icon(Icons.mail),
                  label: const Text(
                    'Enter-Email',
                    style: TextStyle(fontSize: 20),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  setState(() {
                    isHandsUp!.value = true;
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    isHandsUp!.value = false;
                  });
                },
                obscuringCharacter: '*',
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 5, color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(width: 2, color: Colors.purple),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  suffixIcon: const Icon(Icons.key),
                  label: const Text(
                    'Enter-Password',
                    style: TextStyle(fontSize: 20),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            ElevatedButton(
              onPressed: () {
                loginUser(context, emailController.text.toString(),
                    passwordController.text.toString(), _identifier);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(size.width / 3, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            SizedBox(
              height: size.height * 0.08,
            ),
          ],
        ),
      ),
    );
  }
}
