//
// import 'package:booking_app/homescreen.dart';
// import 'package:flutter/material.dart';
// import 'package:booking_app/registerscreen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _passwordVisible = false;
//   Future<void> _signIn() async {
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       // If sign-in is successful, get the user's UID
//       String uid = userCredential.user!.uid;
//
//       // Proceed with navigation or any other logic
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Login Successful!"))
//       );
//       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(userUid: uid)));
//
//     }
//     on FirebaseAuthException catch (e) {
//       String message = "Unable to login please check login credentials";
//       switch (e.code) {
//         case 'user-not-found':
//         case 'invalid-email':
//           message = "Invalid email address. Please check and try again.";
//           break;
//         case 'wrong-password':
//           message = "Incorrect password. Please try again.";
//           break;
//         default:
//           break;
//       }
//
//       // Display a Snackbar with the specific error message
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(message))
//       );
//     } catch (e) {
//       // Handle any other errors that might occur
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to sign in: $e"))
//       );
//     }
//   }
//
//   void _navigateToRegister() {
//     Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             height: double.infinity,
//             width: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xfff35f80),
//                   Color(0xfff8f07b),
//                 ],
//               ),
//             ),
//           ),
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(top: 90.0, left: 22, right: 22),
//                   child: Text(
//                     'Hello\nSign In!',
//                     style: TextStyle(
//                         fontSize: 35,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 SizedBox(height: 50),
//                 Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: Column(
//                     children: [
//                       TextField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           labelText: 'Email Address',
//                           prefixIcon: Icon(Icons.email, color: Color(0xffef3664)),
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                       ),
//                       SizedBox(height: 20),
//                       TextField(
//                         controller: _passwordController,
//                         obscureText: !_passwordVisible,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           prefixIcon: Icon(Icons.lock, color: Color(0xffef3664)),
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(vertical: 12),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _passwordVisible ? Icons.visibility : Icons.visibility_off,
//                               color: Colors.grey,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _passwordVisible = !_passwordVisible;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 40),
//                       GestureDetector(
//                         onTap: _signIn,
//                         child: Container(
//                           height: 45,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(30),
//                             gradient: LinearGradient(
//                               colors: [
//                                 Color(0xffef3664),
//                                 Color(0xfff18ea6),
//                               ],
//                             ),
//                           ),
//                           child: Center(
//                             child: Text(
//                               'SIGN IN',
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 20,
//                                   color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       GestureDetector(
//                         onTap: _navigateToRegister,
//                         child: Text(
//                           "New user? Register",
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.blue,
//                             fontWeight: FontWeight.bold,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//

import 'package:booking_app/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:booking_app/registerscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // If sign-in is successful, get the user's UID
      String uid = userCredential.user!.uid;

      // Store login state in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      // Proceed with navigation or any other logic
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Successful!"))
      );
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(userUid: uid)));

    } on FirebaseAuthException catch (e) {
      String message = "Unable to login please check login credentials";
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-email':
          message = "Invalid email address. Please check and try again.";
          break;
        case 'wrong-password':
          message = "Incorrect password. Please try again.";
          break;
        default:
          break;
      }

      // Display a Snackbar with the specific error message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message))
      );
    } catch (e) {
      // Handle any other errors that might occur
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to sign in: $e"))
      );
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xfff35f80),
                  Color(0xfff8f07b),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 90.0, left: 22, right: 22),
                  child: Text(
                    'Hello\nSign In!',
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email, color: Color(0xffef3664)),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Color(0xffef3664)),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      GestureDetector(
                        onTap: _signIn,
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xffef3664),
                                Color(0xfff18ea6),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'SIGN IN',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: _navigateToRegister,
                        child: Text(
                          "New user? Register",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

