import 'package:flutter/material.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> with SingleTickerProviderStateMixin{

  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
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
        Image.asset('assets/images/agents_image.png'),
        SizedBox(
          height: size.height * 0.02,
        ),
        ShaderMask(
            shaderCallback: (Rect bounds) {
              return  LinearGradient(stops: [
              //  _animation.value - 0.3,
              //   _animation.value + 0.3,
                // _animation.value - 0.8,
                _animation.value - 0.5,
                _animation.value,
                // _animation.value - 0.8,
                _animation.value + 0.5,
              ], colors: const [
                // Color(0xFFFF0000), // Neon Red
                Color(0xFFFFA500), // Neon Orange
                // Color(0xFFFFFF00), // Neon Yellow
                Color(0xFF39FF14), // Neon Green
                Color(0xFF00FFFF), // Neon Cyan
                // Color(0xFF0000FF), // Neon Blue
                // Color(0xFFFF00FF), // Neon Magenta
              ]).createShader(bounds);
            },
            child: const Text(
              'Seamless Surveying',
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
            'Capture and record surveys at any location with ease. Use your camera, track locations, and gather accurate data on the go.',
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