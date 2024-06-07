


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  void _changePassword() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Confirm that the new password and confirmation match
        if (_newPasswordController.text == _confirmNewPasswordController.text) {
          // Reauthenticate user with current password
          AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: _currentPasswordController.text);
          await user.reauthenticateWithCredential(credential);

          // Change password
          await user.updatePassword(_newPasswordController.text);

          // Password updated successfully
          // Navigate back to the profile screen or any other screen
          Navigator.of(context).pop();
        } else {
          // Passwords do not match
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
        }
      } catch (error) {
        print("Error changing password: $error");
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to change password. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
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
              controller: _currentPasswordController,
              decoration: InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmNewPasswordController,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xfff35f80), // Set button background color
                foregroundColor: Colors.white, // Set text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
