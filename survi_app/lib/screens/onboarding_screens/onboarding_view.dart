import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:survi_app/screens/login_page.dart';
import 'package:survi_app/screens/onboarding_screens/screen1.dart';
import 'package:survi_app/screens/onboarding_screens/screen2.dart';
import 'package:survi_app/screens/onboarding_screens/screen3.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController pageController = PageController();
  int currentPage = 0;
  void _goToNextPage() {
    if (currentPage < 2) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 1500), curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = size.height * 0.032;
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            controller: pageController,
            scrollDirection: Axis.vertical,
            children: const [
              Center(
                child: Screen1(),
              ),
              Center(
                child: Screen2(),
              ),
              Center(
                child: Screen3(),
              ),
            ],
          ),
          Positioned(
            bottom: bottomPadding,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: Text(
                        currentPage != 2 ? 'skip' : 'Login',
                        style: const TextStyle(fontSize: 18),
                      )),
                  SizedBox(
                    width: size.width * 0.2,
                  ),
                  SmoothPageIndicator(controller: pageController, count: 3),
                  SizedBox(
                    width: size.width * 0.2,
                  ),
                  currentPage != 2
                      ? IconButton(
                          onPressed: _goToNextPage,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 45,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
