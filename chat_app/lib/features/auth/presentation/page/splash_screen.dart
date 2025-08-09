import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/authwrapper');
    });

    return Scaffold(
      body: Stack(
          children: [Positioned.fill(
            child: Image.asset('assets/images/splash.png', 
            fit: BoxFit.cover),
          ),]
        ),
      );
  }
}