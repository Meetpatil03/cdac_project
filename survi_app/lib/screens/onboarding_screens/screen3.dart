import 'package:flutter/material.dart';

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> with SingleTickerProviderStateMixin{
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
        Image.asset('assets/images/uploading_image.png'),
        SizedBox(
          height: size.height * 0.02,
        ),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(stops: [
              _animation.value - 0.5,
              _animation.value,
              _animation.value + 0.5,
            ], colors: const [
              Color(0xFFFF00FF), // Neon Magenta
              Color(0xFF00FFFF), // Neon Cyan
              Color(0xFFFFFF00), // Neon Yellow
            ]).createShader(bounds);
          },
          child: const Text(
            'Submit with Confidence',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Send your surveys directly to the admin with a single tap. Ensure your data is secure and promptly delivered.',
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