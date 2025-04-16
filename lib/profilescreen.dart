 import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'loginscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_flutter_project/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
const ProfileScreen({super.key});

@override
_ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
double screenHeight = 0;
double screenWidth = 0;
Color primary = const Color(0xFFEDBA4B);
String birth = "Date of birth";

TextEditingController firstNameController = TextEditingController();
TextEditingController lastNameController = TextEditingController();
TextEditingController addressController = TextEditingController();

void pickUploadProfilePic() async {
final picker = ImagePicker();
final image = await picker.pickImage(
source: ImageSource.gallery,
maxHeight: 512,
maxWidth: 512,
imageQuality: 90,
);
Reference ref = FirebaseStorage.instance
    .ref()
    .child("${User.employeeId.toLowerCase()}_profilepic.jpg");
await ref.putFile(File(image!.path));

ref.getDownloadURL().then((value) async {
setState(() {
User.profilePiclink = value;
});
await FirebaseFirestore.instance
    .collection("Employee")
    .doc(User.id)
    .update({
'profilePic': value,
});
});
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
  GestureDetector(
    onTap: () {
      // يمكن هنا إضافة أي وظيفة أخرى لو أردت تغيير الصورة
      // مثلًا، لن تحتاج هنا إلى pickUploadProfilePic
    },
    child: Container(
      margin: const EdgeInsets.only(top: 80, bottom: 24),
      height: 120,
      width: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: primary,
      ),
      child: Center(
        // هنا نستخدم صورة ثابتة من assets
        child: Image.asset(
          'assets/images/logo.jpg', // ضع مسار الصورة هنا
          fit: BoxFit.cover, // لضبط حجم الصورة داخل الإطار
        ),
      ),
    ),
  ),

Align(
alignment: Alignment.center,
child: Text(
"Employee ${User.employeeId}",
style: const TextStyle(
fontFamily: "Poppins-Bold",
fontSize: 18,
),
),
),
const SizedBox(height: 24),
User.canEdit
? textField("First Name", "First name", firstNameController)
    : field("First Name", User.firstName),
User.canEdit
? textField("Last Name", "Last name", lastNameController)
    : field("Last Name", User.lastName),
User.canEdit
? GestureDetector(
onTap: () {
showDatePicker(
context: context,
initialDate: DateTime.now(),
firstDate: DateTime(1950),
lastDate: DateTime.now(),
builder: (context, child) {
return Theme(
data: Theme.of(context).copyWith(
colorScheme: ColorScheme.light(
primary: primary,
secondary: primary,
onSecondary: Colors.white,
),
textButtonTheme: TextButtonThemeData(
style: TextButton.styleFrom(
foregroundColor: primary,
),
),
textTheme: const TextTheme(
headlineMedium: TextStyle(
fontFamily: "Poppins-Bold",
),
labelSmall: TextStyle(
fontFamily: "Poppins-Bold",
),
labelLarge: TextStyle(
fontFamily: "Poppins-Bold",
),
),
),
child: child!,
);
},
).then((value) {
if (value != null) {
setState(() {
birth = DateFormat("MM/dd/yyyy").format(value);
});
}
});
},
child: field("Date of Birth", birth),
)
    : field("Date of Birth", User.birthdate),
User.canEdit
? textField("Address", "Address", addressController)
    : field("Address", User.address),
User.canEdit
? GestureDetector(
onTap: () async {
String firstName = firstNameController.text;
String lastName = lastNameController.text;
String address = addressController.text;
String birthDate = birth;

if (User.canEdit) {
if (firstName.isEmpty) {
showSnackBar("Please enter your first name!");
} else if (lastName.isEmpty) {
showSnackBar("Please enter your last name!");
} else if (birthDate.isEmpty) {
showSnackBar("Please enter your birth date!");
} else if (address.isEmpty) {
showSnackBar("Please enter your address!");
} else {
await FirebaseFirestore.instance
    .collection("Employee")
    .doc(User.id)
    .update({
'firstName': firstName,
'lastName': lastName,
'birthDate': birthDate,
'address': address,
'canEdit': false,
}).then((value) {
setState(() {
User.canEdit = false;
User.firstName = firstName;
User.lastName = lastName;
User.birthdate = birthDate;
User.address = address;
});
});
}
} else {
showSnackBar("you can't edit anymore, please contact support team.");
}
},
child: Container(
height: kToolbarHeight,
width: screenWidth,
margin: const EdgeInsets.only(bottom: 12),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(4),
color: primary,
border: Border.all(
color: Colors.black45,
),
),
child: const Center(
child: Text(
"SAVE",
style: TextStyle(
color: Colors.white,
fontFamily: "Poppins-Bold",
fontSize: 16,
),
),
),
),
)
    : const SizedBox(),

// Spacer
const SizedBox(height: 20),

// ✅ زر تسجيل الخروج
//           ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.amber,
//               foregroundColor: Colors.white,
//               minimumSize: Size(double.infinity, 50),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: () async {
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               await prefs.remove('employeeId'); // حسب ما خزّنته بعد تسجيل الدخول
//
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => const LoginScreen()),
//                     (route) => false,
//               );
//
//             },
//             icon: Icon(Icons.logout),
//             label: Text(
//               "تسجيل الخروج",
//               style: TextStyle(
//                 fontFamily: "Poppins-Bold",
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

ElevatedButton.icon(
style: ElevatedButton.styleFrom(
backgroundColor: Colors.amber,
foregroundColor: Colors.white,
minimumSize: const Size(double.infinity, 50),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(8),
),
),
onPressed: () async {
final prefs = await SharedPreferences.getInstance();

// Check if 'employeeId' exists before removing it (optional, but safe)
if (prefs.containsKey('EmployeeId')) {
await prefs.remove('EmployeeId');
}

// Optional: Clear more data if needed (like username, session, etc.)

// Make sure context is valid before navigating
if (context.mounted) {
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (context) => const LoginScreen()),
(route) => false,
);
}
},
icon: const Icon(Icons.logout),
label: const Text(
"تسجيل الخروج",
style: TextStyle(
fontFamily: "Poppins-Bold",
fontSize: 16,
),
),
),
],
),),);}

Widget field(String title, String text) {
return Column(
children: [
Align(
alignment: Alignment.centerLeft,
child: Text(
title,
style: const TextStyle(
fontFamily: "Poppins-Bold",
color: Colors.black87,
),
),
),
Container(
height: kToolbarHeight,
width: screenWidth,
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.only(left: 11),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(4),
border: Border.all(
color: Colors.black45,
),
),
child: Align(
alignment: Alignment.centerLeft,
child: Text(
text,
style: const TextStyle(
color: Colors.black54,
fontFamily: "Poppins-Bold",
fontSize: 16,
),
),
),
),
],
);
}

Widget textField(String hint, String title, TextEditingController controller) {
return Column(
children: [
Align(
alignment: Alignment.centerLeft,
child: Text(
title,
style: const TextStyle(
fontFamily: "Poppins-Bold",
color: Colors.black87,
),
),
),
Container(
margin: const EdgeInsets.only(bottom: 12),
child: TextFormField(
controller: controller,
cursorColor: Colors.black45,
maxLines: 1,
decoration: InputDecoration(
hintText: hint,
hintStyle: const TextStyle(
color: Colors.black54,
fontFamily: "Poppins-Bold",
),
enabledBorder: const OutlineInputBorder(
borderSide: BorderSide(
color: Colors.black45,
),
),
focusedBorder: const OutlineInputBorder(
borderSide: BorderSide(
color: Colors.black45,
),
),
),
),
),
],
);
}

void showSnackBar(String text) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
behavior: SnackBarBehavior.floating,
content: Text(text),
),
);
}
}