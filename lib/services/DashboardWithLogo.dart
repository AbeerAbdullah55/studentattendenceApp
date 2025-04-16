import 'dart:async';
import 'package:flutter/material.dart';
import '../loginscreen.dart';

class Dashboardwithlogo extends StatefulWidget {
  const Dashboardwithlogo({super.key});

  @override
  State<Dashboardwithlogo> createState() => _Dashboardwithlogo();
}

class _Dashboardwithlogo extends State<Dashboardwithlogo> {
  @override
  void initState() {
    super.initState();
    // ننتقل بعد 3 ثواني
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // لون الخلفية
      body: Center(
        child: Image.asset(
          'assets/images/logo.jpg', // مسار لوقو المعهد
          height: 150,
        ),
      ),
    );
  }
}
