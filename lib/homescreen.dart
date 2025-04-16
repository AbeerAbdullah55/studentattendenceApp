import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_flutter_project/calendarscreen.dart';
import 'package:my_flutter_project/profilescreen.dart';
import 'package:my_flutter_project/services/location_service.dart';
import 'package:my_flutter_project/todayscreen.dart';
import 'model/user.dart'; // استيراد User class

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  String id = '';
  final Color primary = const Color(0xFFEDBA4B);
  int currentIndex = 1;

  final List<IconData> navigationIcons = [
    FontAwesomeIcons.calendarAlt,
    FontAwesomeIcons.check,
    FontAwesomeIcons.user,
  ];
  @override
  void initState() {

    super.initState();
    _startLocationService();
    getId().then((value) {
      _getCredentials();
      _getProfilePic();
    });
  }
  void  _getCredentials()async{
    try{
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Employee").doc(User.id).get();
      setState(() {
        User.canEdit = doc['canEdit'];
        User.firstName = doc['firstName'];
        User.lastName = doc['lastName'];
        User.birthdate = doc['birthdate'];
        User.address = doc['address '];
      });
    }catch(e) {
      return;
    }
  }
  void  _getProfilePic()async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection(
        "Employee").doc(User.id).get();
    setState(() {
      User.profilePiclink = doc['profilePic'];
    });
  }
  void _startLocationService() async{
    LocationService().initialize();

    LocationService().getLongitude().then((value){
      setState(() {
        User.long = value!;

      });
      LocationService().getLatitude().then((value){
        setState(() {
          User.lat = value!;
        });
      });
    });
  }
  Future<void>getId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Employee")
        .where('id', isEqualTo: User.employeeId)
        .get();

    setState(() {
      User.id = snap.docs[0].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${User.employeeId}'),  // عرض اسم المستخدم هنا
        backgroundColor: primary,
      ),
      body: IndexedStack(
        index: currentIndex,
        children:  [
          new CalendarScreen(),
          new TodayScreen(),
          new ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: navigationIcons.asMap().entries.map((entry) {
              int i = entry.key;
              IconData icon = entry.value;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = i;
                    });
                  },
                  child: Container(
                    height: screenHeight,
                    width: screenWidth,
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          color: i == currentIndex ? primary : Colors.black54,
                          size: i == currentIndex ? 30 : 26,
                        ),
                        if (i == currentIndex)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            height: 3,
                            width: 22,
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

