
import 'package:booking_app/ticketscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  final String movieName;
  final String showDate;
  final String startTime;
  final List<String> selectedSeats;
  final User user;

  ConfirmationScreen({
    required this.movieName,
    required this.showDate,
    required this.startTime,
    required this.selectedSeats,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users')
            .doc(user?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            var username = userData['username'] ?? 'N/A';
            var phone = userData['phone'] ?? 'N/A';


            return Scaffold(
              body: Stack(
                children: [
                  // SeatLayoutScreen


                  // ConfirmationScreen
                  Container(
                    color: Colors.white, // Set background color to white
                    child: SingleChildScrollView( // Wrap with SingleChildScrollView to handle overflow
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 20, right: 20),
                        // Adjust padding to move content upward
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.movie, size: 20,
                                        color: Color(0xff100004)),
                                    SizedBox(width: 10),
                                    Text(
                                      'Movie: ',
                                      style: TextStyle(fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xffe50B9F4)),
                                    ),
                                    Text(
                                      movieName,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                      Icons.close, color: Color(0xff090909)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 20,
                                    color: Color(0xff100004)),
                                SizedBox(width: 10),
                                Text(
                                  'Date: ',
                                  style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffe50B9F4)),
                                ),
                                Text(
                                  showDate,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 20,
                                    color: Color(0xff100004)),
                                SizedBox(width: 10),
                                Text(
                                  'Time: ',
                                  style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffe50B9F4)),
                                ),
                                Text(
                                  startTime,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(Icons.person, size: 20, color: Color(0xff100004)),
                                SizedBox(width: 10),
                                Text(
                                  'Username:',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffe50B9F4)),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  username,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 20, color: Color(0xff100004)),
                                SizedBox(width: 10),
                                Text(
                                  'Phone Number:',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffe50B9F4)),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  phone,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(Icons.event_seat, size: 20,
                                    color: Color(0xff100004)),
                                SizedBox(width: 10),
                                Text(
                                  'Seats: ',
                                  style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffe50B9F4)),
                                ),
                                Expanded(
                                  child: Wrap(
                                    spacing: 5,
                                    children: selectedSeats.map((seat) {
                                      return Text( // Use Text widget directly instead of Chip
                                        seat,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        // builder: (context) => BookMovieScreen()),
                                        builder: (context) => TicketScreen(userId: user?.uid ?? '',),
                                      ),
                                    );
                                    // Handle continue logic here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    backgroundColor: Color(0xffee365f),
                                  ),
                                  child: Text('Continue', style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
    );
  }
}


