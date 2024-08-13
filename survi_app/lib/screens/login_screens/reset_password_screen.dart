import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:survi_app/apis/reset_password_api.dart';
import 'package:survi_app/widgets/custom_text.dart';
import 'package:survi_app/widgets/custom_text_field.dart';

class ResetPassword extends StatefulWidget {
  final String role;
  final String userId;
  final String token;
  const ResetPassword({super.key, required this.role, required this.userId,required this.token});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  late TextEditingController p1Controller = TextEditingController();
  late TextEditingController p2Controller = TextEditingController();

  Artboard? mainArtBoard;
  StateMachineController? _stateMachineController;
  SMITrigger? clicked;

  @override
  void initState() {
    super.initState();
    RiveFile.initialize().then((_) {
      rootBundle.load('assets/rive/button_animation.riv').then((byteData) {
        var riveFile = RiveFile.import(byteData);
        var mArtBoard = riveFile.mainArtboard;
        _stateMachineController =
            StateMachineController.fromArtboard(mArtBoard, 'State Machine 1');

        if (_stateMachineController != null) {
          mArtBoard.addController(_stateMachineController!);
          mainArtBoard = mArtBoard;
          clicked = _stateMachineController!.findSMI('CLICK');
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    p1Controller.dispose();
    p2Controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          body: mainArtBoard != null
              ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomText(
                          fontSize: 70,
                          text: "Reset Password",
                        ),
                        SizedBox(
                          height: size.height * 0.1,
                        ),
                        Text(
                          "role : ${widget.role}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          "userId : ${widget.userId}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: p1Controller,
                          label: 'Enter-Password',
                          suffixIcons: const Icon(Icons.lock),
                          obscureText: true,
                          textInputType: TextInputType.visiblePassword,
                          
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        CustomTextField(
                          controller: p2Controller,
                          label: 'Re-Enter-Password',
                          suffixIcons: const Icon(Icons.lock),
                          obscureText: true,
                          textInputType: TextInputType.visiblePassword,
                          
                        ),
                        SizedBox(
                          height: size.height * 0.03,
                        ),
                        GestureDetector(
                          onTap: () {
                          

                            if (p1Controller.text.isNotEmpty && p2Controller.text.isNotEmpty &&  p1Controller.text == p2Controller.text) {
                              resetPassword(
                                  p1Controller.text.toString(), context,widget.token);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Password Doesn't Match"),
                                ),
                              );
                            }
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: size.width * 0.7,
                              height: size.height * 0.3,
                              child: Rive(
                                artboard: mainArtBoard!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const CircularProgressIndicator.adaptive(),),
    );
  }
}
