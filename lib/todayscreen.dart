import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_project/model/user.dart';
import 'package:slide_to_act/slide_to_act.dart';


class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String checkIn = "--/--";
  String checkOut = "--/--";
  String location = " ";
  String scanResult =" ";
  String officeCode = " ";
  final Color primary = const Color(0xFFEDBA4B);

  @override
  void initState() {
    super.initState();
    _getRecord();
    _getOfficeCode();
  }
  void _getOfficeCode() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection("Attributes").doc("Office1").get();

    setState(() {
      officeCode = snap['code'];
    });
  }
  Future<void> checkInOrOutWithLocation() async {
    try {
      await _getLocation();

      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: User.employeeId)
          .get();

      if (snap.docs.isEmpty) {
        print("⚠️ No employee found with this ID.");
        return;
      }

      String docId = snap.docs[0].id;
      String todayDocId = DateFormat('dd MMMM yyyy').format(DateTime.now());

      DocumentReference recordRef = FirebaseFirestore.instance
          .collection("Employee")
          .doc(docId)
          .collection("Record")
          .doc(todayDocId);

      DocumentSnapshot recordSnap = await recordRef.get();

      List<dynamic> sessions = [];

      if (recordSnap.exists) {
        sessions = List.from(recordSnap['sessions'] ?? []);
      }

      if (sessions.isNotEmpty && sessions.last['checkOut'] == null) {
        // Check out
        sessions.last['checkOut'] = DateFormat('HH:mm').format(DateTime.now());

        await recordRef.update({
          'sessions': sessions,
          'date': Timestamp.now(),
        });

        setState(() {
          checkOut = sessions.last['checkOut'];
        });
      } else {
        // Check in
        String checkInTime = DateFormat('HH:mm').format(DateTime.now());

        Map<String, dynamic> newSession = {
          'checkIn': checkInTime,
          'checkOut': null,
          'location': location,
        };

        sessions.add(newSession);

        await recordRef.set({
          'date': Timestamp.now(),
          'sessions': sessions,
        }, SetOptions(merge: true));


        setState(() {
          checkIn = newSession['checkIn'];
          checkOut = newSession['checkOut'] ?? "--/--";
        });

      }
    } catch (e) {
      print("❗ Error: $e");
    }
  }

  Future<void> _getLocation() async {
    List<Placemark> placemark = await placemarkFromCoordinates(User.lat, User.long);

    setState(() {
      location = "${placemark[0].street},${placemark[0].administrativeArea},${placemark[0].postalCode},${placemark[0].country} ";
    });
  }

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: User.employeeId)
          .get();

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      List<dynamic> sessions = snap2['sessions'] ?? [];

      if (sessions.isNotEmpty) {
        setState(() {
          checkIn = sessions.last['checkIn'] ?? "--/--";
          checkOut = sessions.last['checkOut'] ?? "--/--";
        });
      }
    } catch (e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top: 32),
                child: Text(
                  "Welcome",
                  style: TextStyle(
                    color: Colors.black45,
                    fontFamily: "Poppins-Regular",
                    fontSize: screenWidth / 20,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Employee" + User.employeeId,
                  style: TextStyle(
                    fontFamily: "Poppins-Bold",
                    fontSize: screenWidth / 18,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top: 32),
                child: Text(
                  "Today's Status",
                  style: TextStyle(
                    color: Colors.black45,
                    fontFamily: "Poppins-Bold",
                    fontSize: screenWidth / 18,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 32),
                height: 150,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Check In",
                            style: TextStyle(
                              fontFamily: "Poppins-Regular",
                              fontSize: screenWidth / 20,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            checkIn,
                            style: TextStyle(
                              fontFamily: "Poppins-Bold",
                              fontSize: screenWidth / 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Check Out",
                            style: TextStyle(
                              fontFamily: "Poppins-Regular",
                              fontSize: screenWidth / 20,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            checkOut,
                            style: TextStyle(
                              fontFamily: "Poppins-Bold",
                              fontSize: screenWidth / 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                        text: DateTime
                            .now()
                            .day
                            .toString(),
                        style: TextStyle(
                          color: primary,
                          fontSize: screenWidth / 18,
                          fontFamily: "Poppins-Bold",
                        ),
                        children: [
                          TextSpan(
                              text: DateFormat(' MMMM yyyy').format(
                                  DateTime.now()),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth / 20,
                                fontFamily: "Poppins-Bold",
                              )
                          )
                        ]
                    ),
                  )
              ),
              StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('HH:mm:ss a').format(DateTime.now()),
                        style: TextStyle(
                          fontFamily: "Poppins-Regular",
                          fontSize: screenWidth / 20,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  }
              ),
              checkOut == "--/--" ? Container(
                margin: const EdgeInsets.only(top: 24, bottom: 32),
                child: Builder(
                  builder: (context) {
                    final GlobalKey<SlideActionState> key = GlobalKey();
                    return SlideAction(
                      text: checkIn == "--/--"
                          ? "Slide to Check In"
                          : "Slide to Check Out",
                      textStyle: TextStyle(
                        color: Colors.black45,
                        fontSize: screenWidth / 20,
                        fontFamily: "Poppins-Regular",
                      ),
                      outerColor: Colors.white,
                      innerColor: primary,
                      key: key,
                      onSubmit: () async {
                        if(User.lat !=0){
                          _getLocation();

                          print("🔍 Username: ${User.employeeId}");

                          QuerySnapshot snap = await FirebaseFirestore.instance
                              .collection("Employee")
                              .where('id', isEqualTo: User.employeeId)
                              .get();

                          DocumentSnapshot snap2 = await FirebaseFirestore
                              .instance
                              .collection("Employee")
                              .doc(snap.docs[0].id)
                              .collection("Record")
                              .doc(
                              DateFormat('dd MMMM yyyy').format(DateTime.now()))
                              .get();

                          try {
                            String checkIn = snap2['checkIn'];
                            setState(() {
                              checkOut = DateFormat('HH:mm').format(
                                  DateTime.now());
                            });
                            await FirebaseFirestore.instance
                                .collection("Employee")
                                .doc(snap.docs[0].id)
                                .collection("Record")
                                .doc(
                                DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                .update({
                              'date':Timestamp.now(),
                              'checkIn': checkIn,
                              'checkOut': DateFormat('HH:mm').format(
                                  DateTime.now()),
                              'location ': location,
                            });
                          } catch (e) {
                            setState(() {
                              checkIn = DateFormat('HH:mm').format(DateTime.now());

                            });
                            await FirebaseFirestore.instance
                                .collection("Employee")
                                .doc(snap.docs[0].id)
                                .collection("Record")
                                .doc(
                                DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                .set({
                              'date':Timestamp.now(),
                              'checkIn': DateFormat('HH:mm').format(
                                  DateTime.now()),
                              'checkOut':"--/--",
                              'location ': location,
                            });
                          }

                          key.currentState!.reset();

                        }else{
                          Timer(const Duration(seconds:  3), () async{
                            _getLocation();

                            print("🔍 Username: ${User.employeeId}");

                            QuerySnapshot snap = await FirebaseFirestore.instance
                                .collection("Employee")
                                .where('id', isEqualTo: User.employeeId)
                                .get();

                            DocumentSnapshot snap2 = await FirebaseFirestore
                                .instance
                                .collection("Employee")
                                .doc(snap.docs[0].id)
                                .collection("Record")
                                .doc(
                                DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                .get();

                            try {
                              String checkIn = snap2['checkIn'];
                              setState(() {
                                checkOut = DateFormat('HH:mm').format(
                                    DateTime.now());
                              });
                              await FirebaseFirestore.instance
                                  .collection("Employee")
                                  .doc(snap.docs[0].id)
                                  .collection("Record")
                                  .doc(
                                  DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                  .update({
                                'date':Timestamp.now(),
                                'checkIn': checkIn,
                                'checkOut': DateFormat('HH:mm').format(
                                    DateTime.now()),
                                'checkInLocation ': location,
                              });
                            } catch (e) {
                              setState(() {
                                checkIn = DateFormat('HH:mm').format(DateTime.now());

                              });
                              await FirebaseFirestore.instance
                                  .collection("Employee")
                                  .doc(snap.docs[0].id)
                                  .collection("Record")
                                  .doc(
                                  DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                  .set({
                                'date':Timestamp.now(),
                                'checkIn': DateFormat('HH:mm').format(
                                    DateTime.now()),
                                'checkOut':"--/--",
                                'checkOutLocation ': location,
                              });
                            }

                            key.currentState!.reset();

                          });
                        }

                      },
                    );
                  },
                ),
              ) : Container(
                margin: const EdgeInsets.only(top: 32),
                child: Text("You have completed this day!",
                  style: TextStyle(
                    fontFamily: "Poppins-Regular",
                    fontSize: screenWidth / 20,
                    color: Colors.black54,
                  ),
                ),
              ),
              location != " " ? Text(
                "Location: " +location,
              ): const SizedBox(),

            ],
          ),
        )
    );
  }
}
