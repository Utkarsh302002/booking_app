//
// import 'dart:ui';
//
// import 'package:booking_app/profilescreen.dart';
// import 'package:booking_app/ticketscreen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:bottom_navy_bar/bottom_navy_bar.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'moviedetailscreen.dart';
//
// class HomeScreen extends StatefulWidget {
//   final String userUid;
//
//   const HomeScreen({Key? key, required this.userUid}) : super(key: key);
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
//
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//   PageController _pageController = PageController();
//   List<Map<String, String>> _movies = [];
//   List<String> _pageTitles = [
//     'Movies', // Title for the Movies page
//     'Profile', // Title for the Profile page
//     'Passes', // Title for the Tickets page
//     // 'Logout' // Title for the Logout page or another appropriate title
//   ];
//
//   List<IconData> _pageIcons = [
//     Icons.movie,
//     Icons.person,
//     Icons.card_giftcard,
//     // Icons.exit_to_app
//   ];
//
//   // Initialize directly if all widgets are stateless or don't depend on the context.
//   List<Widget> getPages() {
//     return [
//       buildMoviesGrid(),
//       // This will now be correctly called within the build context
//       ProfileScreen(),
//       TicketScreen(userId: widget.userUid),
//
//       Center(child: Text("Passes")),
//
//       // Center(child: Text("Logout"))
//     ];
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     fetchMovies(); // Fetch movies from Firestore
//   }
//
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//
//   Future<void> fetchMovies() async {
//     try {
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
//           'movies').get();
//       List<Map<String, String>> fetchedMovies = [];
//       for (var doc in querySnapshot.docs) {
//         var data = doc.data() as Map<String, dynamic>;
//         List<dynamic> posterUrls = data['poster'] ?? [];
//         String firstPosterUrl = posterUrls.isNotEmpty && posterUrls[0] is String
//             ? posterUrls[0]
//             : 'https://via.placeholder.com/150';
//         bool isActive = data['active'] ??
//             false; // Assuming 'active' is a boolean field
//
//         if (data.containsKey('name') && data['name'] is String &&
//             isActive) { // Only add movie if it's active
//           fetchedMovies.add({
//             'title': data['name'],
//             'poster': firstPosterUrl
//           });
//         }
//       }
//       setState(() {
//         _movies = fetchedMovies;
//       });
//     } catch (error) {
//       print("Error fetching movie data: $error");
//     }
//   }
//
// // Directly initializing where declared.
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Icon(_pageIcons[_currentIndex], color: Colors.black),
//             // Icon for the AppBar
//             SizedBox(width: 8),
//             // Space between icon and text
//             Text(_pageTitles[_currentIndex],
//                 style: TextStyle(color: Colors.black)),
//             // Text for the AppBar
//           ],
//         ),
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.centerRight,
//               end: Alignment.centerLeft,
//               colors: [Color(0xffef7590), Color(0xfffcf264)],
//             ),
//           ),
//         ),
//         elevation: 0,
//       ),
//
//       body: IndexedStack(
//         index: _currentIndex,
//         children: getPages(),
//       ),
//       bottomNavigationBar: BottomNavyBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: (index) async {
//           if (index == 3) {
//             await FirebaseAuth.instance.signOut();
//             Navigator.of(context).popUntil((route) => route.isFirst);
//           } else {
//             setState(() {
//               _currentIndex = index;
//             });
//           }
//         },
//         items: [
//           BottomNavyBarItem(
//             icon: Icon(Icons.home),
//             title: Text('Home'),
//             activeColor: Colors.red,
//           ),
//           BottomNavyBarItem(
//             icon: Icon(Icons.person),
//             title: Text('Profile'),
//             activeColor: Colors.purpleAccent,
//           ),
//           BottomNavyBarItem(
//             icon: Icon(Icons.card_giftcard),
//             title: Text('Passes'),
//             activeColor: Colors.pink,
//           ),
//           // BottomNavyBarItem(
//           //   icon: Icon(Icons.exit_to_app),
//           //   title: Text('Logout'),
//           //   activeColor: Colors.blue,
//           // ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget buildMoviesGrid() {
//     return Column(
//       children: [
//         Expanded(
//           child: GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 1, // Adjust this as needed
//             ),
//             itemCount: _movies.length,
//             itemBuilder: (context, index) {
//               Map<String, String> movie = _movies[index];
//               return GestureDetector(
//                 onTap: () {
//                   if (movie != null && movie.isNotEmpty) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MovieDetailScreen(movie: movie),
//                       ),
//                     );
//                   } else {
//                     // Showing a dialog if the movie data is not available
//                     showDialog(
//                       context: context,
//                       builder: (ctx) =>
//                           AlertDialog(
//                             title: Text("Error"),
//                             content: Text("Invalid or missing movie data."),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.of(ctx).pop(),
//                                 child: Text("OK"),
//                               )
//                             ],
//                           ),
//                     );
//                   }
//                 },
//                 child: Card(
//                   child: Stack(
//                     children: [
//                       // Background with glass effect
//                       Positioned.fill(
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               image: DecorationImage(
//                                 image: NetworkImage(
//                                   movie['poster'] ??
//                                       'https://via.placeholder.com/150',
//                                 ),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             child: BackdropFilter(
//                               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                               child: Container(
//                                 color: Colors.black.withOpacity(0.2),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       // Foreground content (poster image and title)
//                       Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
//                             Expanded(
//                               child: Padding(
//                                 padding: EdgeInsets.all(8.0),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: Image.network(
//                                     movie['poster'] ??
//                                         'https://via.placeholder.com/150',
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error,
//                                         stackTrace) =>
//                                         Center(
//                                             child: Text('Image not available')),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text(
//                                 movie['title'] ?? 'No title available',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.all(16.0),
//           color: Colors.white,
//           // Background color for the contact information section
//           child: Text(
//             'Any query Contact Prachiti Chandekar : 7219443054',
//             style: TextStyle(fontSize: 16),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'dart:ui';

import 'package:booking_app/profilescreen.dart';
import 'package:booking_app/ticketscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'moviedetailscreen.dart';

class HomeScreen extends StatefulWidget {
  final String userUid;

  const HomeScreen({Key? key, required this.userUid}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  PageController _pageController = PageController();
  List<Map<String, String>> _movies = [];
  List<String> _pageTitles = [
    'Movies', // Title for the Movies page
    'Profile', // Title for the Profile page
    'Passes', // Title for the Tickets page
  ];

  List<IconData> _pageIcons = [
    Icons.movie,
    Icons.person,
    Icons.card_giftcard,
  ];

  List<Widget> getPages() {
    return [
      buildMoviesGrid(),
      ProfileScreen(),
      TicketScreen(userId: widget.userUid),
      Center(child: Text("Passes")),
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchMovies(); // Fetch movies from Firestore
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchMovies() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('movies').get();
      List<Map<String, String>> fetchedMovies = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        List<dynamic> posterUrls = data['poster'] ?? [];
        String firstPosterUrl = posterUrls.isNotEmpty && posterUrls[0] is String
            ? posterUrls[0]
            : 'https://via.placeholder.com/150';
        bool isActive = data['active'] ?? false;

        if (data.containsKey('name') && data['name'] is String && isActive) {
          fetchedMovies.add({
            'title': data['name'],
            'poster': firstPosterUrl
          });
        }
      }
      setState(() {
        _movies = fetchedMovies;
      });
    } catch (error) {
      print("Error fetching movie data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(_pageIcons[_currentIndex], color: Colors.black),
            SizedBox(width: 8),
            Text(_pageTitles[_currentIndex],
                style: TextStyle(color: Colors.black)),
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
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: getPages(),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) async {
          if (index == 3) {
            // Log out
            await FirebaseAuth.instance.signOut();
            // Update login state in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('isLoggedIn', false);
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Colors.red,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile'),
            activeColor: Colors.purpleAccent,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.card_giftcard),
            title: Text('Passes'),
            activeColor: Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget buildMoviesGrid() {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
            ),
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              Map<String, String> movie = _movies[index];
              return GestureDetector(
                onTap: () {
                  if (movie != null && movie.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Error"),
                        content: Text("Invalid or missing movie data."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text("OK"),
                          )
                        ],
                      ),
                    );
                  }
                },
                child: Card(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  movie['poster'] ?? 'https://via.placeholder.com/150',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    movie['poster'] ?? 'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Center(child: Text('Image not available')),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                movie['title'] ?? 'No title available',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.white,
          child: Text(
            'Any query Contact Prachiti Chandekar : 7219443054',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
