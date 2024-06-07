
import 'package:booking_app/updatepasswordscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'editprofilescreen.dart';
import 'loginscreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user!.uid).get().then((snapshot) {
        if (snapshot.exists) {
          setState(() {
            userData = snapshot.data() as Map<String, dynamic>?;
          });
        } else {
          print("No document found for user.");
        }
      }).catchError((error) {
        print("Error fetching user data: $error");
      });
    } else {
      print("No user logged in");
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();

    // Navigate to the login screen and remove all previous routes.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()), // Adjust with your login screen
          (Route<dynamic> route) => false, // No routes will be left in the stack
    );
  }

  void _editProfile() {
    // Navigate to the edit profile screen
    // Example:
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProfileScreen()));
  }

  void _changePassword() {
    // Navigate to the change password screen
    // Example:
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
           Text(
  "User's Information",
  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
),
            SizedBox(height: 10),
            Card(
              elevation: 8,
              child: ListTile(
                title: Text("Username"),
                subtitle: Text(userData!['username'] ?? 'Not available'),
                leading: Icon(Icons.person, color: Colors.black),
              ),
            ),
            Card(
              elevation: 8,
              child: ListTile(
                title: Text("Email"),
                subtitle: Text(user!.email ?? 'Not available'),
                leading: Icon(Icons.email, color: Colors.black),
              ),
            ),
            Card(
              elevation: 8,
              child: ListTile(
                title: Text("Phone"),
                subtitle: Text(userData!['phone'] ?? 'Not available'),
                leading: Icon(Icons.phone, color: Colors.black),
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton.icon(
              icon: Icon(Icons.edit),
              label: Text("Edit Profile"),
              onPressed: _editProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffef7590), // Button background
                foregroundColor: Colors.white, // Button text color
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.lock_outline),
              label: Text("Change Password"),
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xfffcf264), // Button background
                foregroundColor: Colors.black, // Button text color
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.exit_to_app),
              label: Text("Logout"),
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffef3664), // Button background
                foregroundColor: Colors.white, // Button text color
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
