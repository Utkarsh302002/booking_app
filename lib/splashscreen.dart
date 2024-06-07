//
//
// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'homescreen.dart';
// import 'loginscreen.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }
//
//   Future<void> _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool? isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//     // Give a small delay for the splash screen to be visible
//     await Future.delayed(Duration(seconds: 2));
//
//     if (isLoggedIn && FirebaseAuth.instance.currentUser != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomeScreen(userUid: FirebaseAuth.instance.currentUser!.uid),
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => LoginScreen(),
//         ),
//       );
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context){
//     return AnimatedSplashScreen(splash:
//     Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children:[
//         Center(
//           child: LottieBuilder.asset("assets/Lottie/Animation - 1714375224985.json"),
//         )
//       ],
//     ),
//         nextScreen: const LoginScreen(),
//         splashIconSize:400,
//         backgroundColor: Colors.white);
//
//
//   }
// }
//
//


import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';
import 'loginscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Give a small delay for the splash screen to be visible
    await Future.delayed(Duration(seconds: 2));

    if (isLoggedIn && FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userUid: FirebaseAuth.instance.currentUser!.uid),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Center(
            child: LottieBuilder.asset("assets/Lottie/Animation - 1714375224985.json"),
          )
        ],
      ),
      nextScreen: const LoginScreen(),
      splashIconSize:400,
      backgroundColor: Colors.white,
    );
  }
}
