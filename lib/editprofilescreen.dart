

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late User? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user!.uid).get().then((snapshot) {
        if (snapshot.exists) {
          setState(() {
            userData = snapshot.data() as Map<String, dynamic>?;
            _usernameController.text = userData!['username'] ?? '';
            _phoneController.text = userData!['phone'] ?? '';
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

  void _updateProfile() async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'username': _usernameController.text,
          'phone': _phoneController.text,
        });
        // Update local userData
        setState(() {
          userData!['username'] = _usernameController.text;
          userData!['phone'] = _phoneController.text;
        });
        // Navigate back to the profile screen
        Navigator.of(context).pop();
      } catch (error) {
        print("Error updating profile: $error");
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.edit), // Icon
            SizedBox(width: 8), // Add spacing between icon and title
            Text('Edit Profile'), // Title
          ],
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xffef7590), Color(0xfffcf264)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,

              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffef7590), // Set button background color
              ),

              child: Text(
                'Update Profile',
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
            ),

          ],
        ),
      ),
    );
  }
}
