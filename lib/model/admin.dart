import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('حضور المتدربين لليوم'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('Employee')
            .where('role', isEqualTo: 'user')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('لا يوجد موظفين.'));
          }

          final employees = snapshot.data!.docs;

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              final employeeData = employee.data() as Map<String, dynamic>;
              final employeeId = employeeData['id'] ?? 'غير معروف';
              final firstName = employeeData['firstName'] ?? 'غير معروف';
              final lastName = employeeData['lastName'] ?? '';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Employee')
                    .doc(employee.id)
                    .collection('Record')
                    .doc(todayDate)
                    .get(),
                builder: (context, recordSnapshot) {
                  if (!recordSnapshot.hasData) {
                    return ListTile(
                      title: Text('$firstName $lastName ($employeeId)'),
                      subtitle: Text('جاري التحميل...'),
                    );
                  }

                  if (!recordSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('$firstName $lastName ($employeeId)'),
                      subtitle: Text('لم يسجل حضور اليوم'),
                    );
                  }

                  final data = recordSnapshot.data!.data() as Map<String, dynamic>;
                  final checkIn = data['checkIn'] ?? '---';
                  final checkOut = data['checkOut'] ?? '---';
                  final location = data['location'] ?? 'معهد التعليم الرقمي العالي';

                  return ListTile(
                    title: Text('$firstName $lastName ($employeeId)'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الدخول: $checkIn'),
                        Text('الخروج: $checkOut'),
                        Text('الموقع: $location'),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton.icon(
          icon: Icon(Icons.logout),
          label: Text('تسجيل الخروج'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ),
    );
  }
}
