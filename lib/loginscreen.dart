import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:my_flutter_project/model/admin.dart';
import 'package:my_flutter_project/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';
import 'model/user.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xFFEDBA4B);
  late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              isKeyboardVisible
                  ? SizedBox(height: screenHeight / 16)
                  : Container(
                height: screenHeight / 2.5,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(70),
                  ),
                ),
                // child: Center(
                //   child: Icon(
                //     Icons.person,
                //     color: Colors.white,
                //     size: screenWidth / 5,
                //   ),
                // ),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  width: screenWidth / 1,
                  height: screenWidth / 1,
                  fit: BoxFit.contain,
                ),


              ),
              Container(
                margin: EdgeInsets.only(
                  top: screenHeight / 15,
                  bottom: screenHeight / 20,
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: screenWidth / 18,
                    fontFamily: "Poppins-Bold",
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(horizontal: screenWidth / 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fieldTitle("Student ID"),
                    customField("Enter your Employee ID", idController, false),
                    fieldTitle("Password"),
                    customField("Enter your Password", passController, true),
                    GestureDetector(
                      onTap: _login,
                      child: Container(
                        height: 60,
                        width: screenWidth,
                        margin: EdgeInsets.only(top: screenHeight / 40),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius:
                          const BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Center(
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                              fontFamily: "Poppins-Bold",
                              fontSize: screenWidth / 26,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget fieldTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth / 26,
          fontFamily: "Poppins-Bold",
        ),
      ),
    );
  }

  Widget customField(
      String hint, TextEditingController controller, bool obscure) {
    return Container(
      width: screenWidth,
      margin: EdgeInsets.only(bottom: screenHeight / 50),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth / 6,
            child: Icon(
              Icons.person,
              color: primary,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 12),
              child: TextFormField(
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: screenHeight / 35),
                  border: InputBorder.none,
                  hintText: hint,
                ),
                maxLines: 1,
                obscureText: obscure,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    String id = idController.text.trim();
    String password = passController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    // التحقق من الموقع
    LocationService locationService = LocationService();
    await locationService.initialize();
    final locationData = await locationService.getLocation();
    const double allowedLatitude = 24.594572;
    const double allowedLongitude = 46.594713;
    const double allowedRadiusInMeters = 100;

    double distance = _calculateDistanceInMeters(
      locationData.latitude ?? 0.0,
      locationData.longitude ?? 0.0,
      allowedLatitude,
      allowedLongitude,
    );

    if (distance > allowedRadiusInMeters) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Invalid lccation"),
          content: const Text("You must be at the work site to log in."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Acceptable"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: id)
          .get();

      if (snap.docs.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student ID does not exist!")),
        );
        return;
      }

      String storedPassword = snap.docs[0]['password'];

      if (password == storedPassword) {
        User.employeeId = snap.docs[0]['id'];

        sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString('employeeId', id);

  //       if (!context.mounted) return;
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const HomeScreen()),
  //       );
  //     } else {
  //       if (!context.mounted) return;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Password is not correct!")),
  //       );
  //     }
  //   } catch (e) {
  //     if (!context.mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("An error occurred: $e")),
  //     );
  //   }
  // }
        String role = snap.docs[0]['role']; // تحقق من نوع المستخدم

        if (!context.mounted) return;
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password is not correct!")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }
  double _calculateDistanceInMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000; // in meters
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }
}
