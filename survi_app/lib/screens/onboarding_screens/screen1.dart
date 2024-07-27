import 'package:flutter/material.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> with SingleTickerProviderStateMixin{
    late AnimationController _animationController;

 late Animation _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _animationController.forward();
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
     final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/boy_image.png'),
        SizedBox(
          height: size.height * 0.02,
        ),
        ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ], colors: [
                Color(int.parse("0xFF00c3ff")),
                Color(int.parse("0xFFffff1c")),
                Color(int.parse("0xFF00c3ff")),
              ]).createShader(bounds);
            },
            child: const Text(
              'Welcome! to Assets-Tracker',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            )),
        const SizedBox(
          height: 20,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Discover a new way to conduct surveys effortlessly. Whether it’s an object, instrument, place, or monument, we make it easy for you.',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}