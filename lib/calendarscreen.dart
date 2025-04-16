import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_project/model/user.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  final Color primary = const Color(0xFFEDBA4B);

  DateTime selectedMonth = DateTime.now(); // التاريخ المختار

  // دالة اختيار الشهر والسنة فقط
  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: selectedMonth,
        firstDate: DateTime(2025),
        lastDate: DateTime(2099),
        helpText: 'Pick a Month',
        initialDatePickerMode: DatePickerMode.year,
        builder: (context,child){
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primary,
                secondary:primary,
                onSecondary: Colors.white,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: primary,

                ),
              ),
              textTheme:const TextTheme(
                headlineMedium:TextStyle(
                  fontFamily: "Poppins-Bold",
                ),
                labelSmall:TextStyle(
                  fontFamily: "Poppins-Bold",

                ),
                labelLarge:TextStyle(
                  fontFamily: "Poppins-Bold",

                ),
              ),
            ),
            child: child!,
          );
        }
    );
    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 32),
              child: Text(
                "My Attendance",
                style: TextStyle(
                  color: Colors.black45,
                  fontFamily: "Poppins-Bold",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 32),
                  child: Text(
                    DateFormat('MMMM yyyy').format(selectedMonth),
                    style: TextStyle(
                      fontFamily: "Poppins-Bold",
                      fontSize: screenWidth / 18,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 32),
                  child: GestureDetector(
                    onTap: _pickMonth,
                    child: Text(
                      "Pick a Month",
                      style: TextStyle(
                        fontFamily: "Poppins-Bold",
                        fontSize: screenWidth / 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight / 1.45,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Employee")
                    .doc(User.id)
                    .collection("Record")
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final snap = snapshot.data!.docs;

                    final filteredRecords = snap.where((doc) {
                      final date = doc['date'].toDate();
                      return date.month == selectedMonth.month &&
                          date.year == selectedMonth.year;
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final doc = filteredRecords[index];
                        final date = doc['date'].toDate();
                        return Container(
                          margin:  EdgeInsets.only(top: index > 0 ? 12 :0, left: 6, right: 6),
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
                                child: Container(
                                  margin:  EdgeInsets.only(),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      DateFormat('EE\ndd').format(date),
                                      style: TextStyle(
                                        fontFamily: "Poppins-Bold",
                                        fontSize: screenWidth / 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                                      doc['checkIn'],
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
                                      doc['checkOut'],
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
                        );
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



