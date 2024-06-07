import 'package:flutter/material.dart';

import 'bookmovie.dart';

class MovieDetailScreen extends StatelessWidget {
  final Map<String, String> movie;

  MovieDetailScreen({required this.movie});



  @override
  Widget build(BuildContext context) {
    String imageUrl = movie['poster'] ?? 'https://via.placeholder.com/200';
    String title = movie['title'] ?? 'N/A';
    // String releaseDate = movie['release'] ?? 'Unknown Release Date';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 500,
              errorBuilder: (context, error, stackTrace) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 50),
                  Text("Failed to load image: $error"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            // Text(
            //   "Release Date: $releaseDate",
            //   style: TextStyle(fontSize: 18),
            // ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     // Logic to handle ticket booking
            //     print('Book Ticket Clicked');
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.red,
            //     foregroundColor: Colors.white,
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            //     child: Text('Book Ticket', style: TextStyle(fontSize: 16)),
            //   ),
            // ),

            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xffef3664),
                    Color(0xfff18ea6)],
                ),
                borderRadius: BorderRadius.circular(30), // Optional, for rounded corners
              ),
              child: ElevatedButton(
                onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(
        // builder: (context) => BookMovieScreen()),
      builder: (context) => BookMovieScreen(movieName: movie['title'] ?? 'No Title'),
    ),
    );
    print('Navigate to BookMovieScreen');
    },
                  // Add your button press functionality here

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Making the button background transparent
                  shadowColor: Colors.transparent, // Removing button shadow (if needed)
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Book Ticket',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white, // Foreground color
                  ),
                ),
              ),
            )


          ],
        ),
      ),
    );
  }
}
