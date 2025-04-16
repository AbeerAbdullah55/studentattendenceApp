import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:my_flutter_project/services/DashboardWithLogo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginscreen.dart';
import 'homescreen.dart';
import 'model/user.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Dashboardwithlogo(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool userAvailable = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final savedEmployeeId = sharedPreferences.getString('employeeId');

    print("القيمة المحفوظة: $savedEmployeeId");

    setState(() {
      if (savedEmployeeId != null) {
        User.employeeId = savedEmployeeId;
        userAvailable = true;
      } else {
        userAvailable = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return userAvailable ? const HomeScreen() : const LoginScreen();
  }
}
