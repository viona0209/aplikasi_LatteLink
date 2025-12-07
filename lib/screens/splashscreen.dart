import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aplikasi_lattelink/screens/user/Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), _navigateToLogin);
  }

  void _navigateToLogin() {
    if (!_navigated) {
      _navigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToLogin,
      child: const Scaffold(
        backgroundColor: Color(0xFF6E200D),
        body: Center(
          child: Image(
            image: AssetImage('assets/image/logoAplikasi.png'),
            width: 358,
          ),
        ),
      ),
    );
  }
}
