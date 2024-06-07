

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'confirmationscreen.dart';

enum SeatState {
  empty,
  selected,
  occupied,
  locked,
}

class SeatLayoutScreen extends StatefulWidget {
  final String movieName;
  final String showDate;
  final String startTime;

  SeatLayoutScreen({
    required this.movieName,
    required this.showDate,
    required this.startTime,
  });

  @override
  _SeatLayoutScreenState createState() => _SeatLayoutScreenState();
}

class _SeatLayoutScreenState extends State<SeatLayoutScreen> {
  late List<List<SeatState>> seatStates = [];
  bool _seatsSelected = false;
  bool _confirmationVisible = false;
  List<String> selectedSeats = [];

  @override
  void initState() {
    super.initState();
    _initializeSeatStates();
  }

  void _initializeSeatStates() async {
    List<String> occupiedSeats = await loadOccupiedSeats(widget.movieName, widget.showDate, widget.startTime);
    List<String> lockedSeats = await loadLockedSeats(widget.movieName, widget.showDate, widget.startTime);

    setState(() {
      seatStates = List.generate(13, (int rowIndex) {
        int numSeats = rowIndex == 12 ? 17 : 15;
        return List.generate(numSeats, (int seatIndex) {
          String seatId = '${String.fromCharCode(77 - rowIndex)}${seatIndex + 1}';
          if (occupiedSeats.contains(seatId)) {
            return SeatState.occupied;
          } else if (lockedSeats.contains(seatId)) {
            return SeatState.locked;
          } else {
            return SeatState.empty;
          }
        });
      });
    });

    String movieShowId = '${widget.movieName}-${widget.showDate}-${widget.startTime}';
    DocumentReference seatsRef = FirebaseFirestore.instance.collection('Seats').doc(movieShowId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(seatsRef);

      if (!snapshot.exists) {
        transaction.set(seatsRef, {
          'movieName': widget.movieName,
          'showDate': widget.showDate,
          'startTime': widget.startTime,
          'totalSeats': 197,
          'occupiedSeats': occupiedSeats.length,
          'emptySeats': 197 - occupiedSeats.length,
        });
      } else {
        int occupiedSeatsCount = snapshot['occupiedSeats'];
        int newOccupiedSeatsCount = occupiedSeats.length;
        if (occupiedSeatsCount != newOccupiedSeatsCount) {
          transaction.update(seatsRef, {
            'occupiedSeats': newOccupiedSeatsCount,
            'emptySeats': 197 - newOccupiedSeatsCount,
          });
        }
      }
    });
  }

  Color _getSeatColor(SeatState state) {
    switch (state) {
      case SeatState.empty:
        return Colors.grey[300]!;
      case SeatState.locked:
      case SeatState.selected:
        return Colors.blue;
      case SeatState.occupied:
        return Colors.red;
    }
  }

  Widget generateRow(int rowIndex, int numSeats, bool includeAisle, String rowLabel) {
    List<Widget> seats = [];
    if (seatStates.isEmpty || rowIndex >= seatStates.length) {
      return Container();
    }

    List<SeatState> rowSeats = seatStates[rowIndex];
    for (int i = 0; i < numSeats; i++) {
      if (includeAisle && i == 7) {
        seats.add(SizedBox(width: 20));
      }
      if (rowSeats.isEmpty || i >= rowSeats.length) {
        return Container();
      }

      SeatState seatState = rowSeats[i];
      Color seatColor = _getSeatColor(seatState);
      seats.add(
        Expanded(
          child: GestureDetector(
            onTap: () async {
              try {
                if (seatState == SeatState.empty) {
                  await lockSeat('${String.fromCharCode(77 - rowIndex)}${i + 1}');
                  setState(() {
                    seatStates[rowIndex][i] = SeatState.locked;
                    selectedSeats.add('${String.fromCharCode(77 - rowIndex)}${i + 1}');
                    _seatsSelected = selectedSeats.isNotEmpty;
                  });
                } else if (seatState == SeatState.locked) {
                  await unlockSeat('${String.fromCharCode(77 - rowIndex)}${i + 1}');
                  setState(() {
                    seatStates[rowIndex][i] = SeatState.empty;
                    selectedSeats.remove('${String.fromCharCode(77 - rowIndex)}${i + 1}');
                    _seatsSelected = selectedSeats.isNotEmpty;
                  });
                }
              } catch (e) {
                // Show a message if the seat is locked by another user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              }
            },
            child: Container(
              height: 25,
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: seatColor,
                border: Border.all(color: Colors.black.withOpacity(0.2)),
              ),
              child: Center(child: Text('${i + 1}', style: TextStyle(fontSize: 10))),
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 18,
          alignment: Alignment.center,
          child: Text(rowLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffef7590))),
        ),
        ...seats,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');
    final String formattedShowDate = dateFormat.format(DateTime.parse(widget.showDate));

    return Scaffold(
      appBar: AppBar(
        title: Text('Book your seats'),
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
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: ListTile(
                    leading: Icon(Icons.movie, color: Color(0xffef7590)),
                    title: Text(widget.movieName, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Date: $formattedShowDate | Time: ${widget.startTime}"),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text('Screen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 13,
                  itemBuilder: (context, index) {
                    int rowIndex = index;
                    String rowLabel = String.fromCharCode(77 - index);
                    int numSeats = rowIndex == 12 ? 17 : 15;
                    bool includeAisle = rowIndex != 12;
                    return generateRow(rowIndex, numSeats, includeAisle, rowLabel);
                  },
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Selected Seats: ${selectedSeats.length}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: _seatsSelected
                      ? () async {
                    try {
                      // Save selected seats to Firebase
                      await saveSelectedSeats(
                        selectedSeats,
                        widget.movieName,
                        formattedShowDate,
                        widget.startTime,
                        FirebaseAuth.instance.currentUser!,
                      );

                      // Update the UI
                      setState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Seats confirmed successfully!'),
                        ),
                      );

                      // Toggle visibility of confirmation panel
                      setState(() {
                        _confirmationVisible = true;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                        ),
                      );
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffe50B9F4),
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                  ),
                  child: Text('Confirm Seats', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              _buildLegend(),
            ],
          ),
          if (_confirmationVisible)
            Container(
              color: Colors.grey.withOpacity(0.5),
              child: Center(
                child: Text(
                  'Seat Layout Screen (Inactive)',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          if (_confirmationVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height / 2,
              child: ConfirmationScreen(
                movieName: widget.movieName,
                showDate: formattedShowDate,
                startTime: widget.startTime,
                selectedSeats: selectedSeats,
                user: FirebaseAuth.instance.currentUser!,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _colorIndicator('Available', Colors.grey),
            _colorIndicator('Selected', Colors.blue),
            _colorIndicator('Occupied', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _colorIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 8, height: 30),
        Text(label),
      ],
    );
  }

  Future<void> saveSelectedSeats(
      List<String> selectedSeats,
      String movieName,
      String showDate,
      String startTime,
      User user,
      ) async {
    // Check that all selected seats are still locked by the current user
    List<String> lockedByOthers = [];

    for (String seat in selectedSeats) {
      String row = seat.substring(0, 1);
      int col = int.parse(seat.substring(1));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('locks')
          .where('seat.row', isEqualTo: row)
          .where('seat.col', isEqualTo: col)
          .where('lockedBy', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        lockedByOthers.add(seat);
      }
    }

    if (lockedByOthers.isNotEmpty) {
      throw Exception('Some seats are already booked. Please select other seats.');
    }

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    String username = userSnapshot['username'];
    String phoneNumber = userSnapshot['phone'];

    List<Map<String, dynamic>> seatsFormatted = selectedSeats.map((seat) {
      return {
        'row': seat.substring(0, 1),
        'col': int.parse(seat.substring(1)),
      };
    }).toList();

    await FirebaseFirestore.instance.collection('tickets').add({
      'userId': user.uid,
      'username': username,
      'phoneNumber': phoneNumber,
      'movieName': movieName,
      'showDate': showDate,
      'startTime': startTime,
      'selectedSeats': seatsFormatted,
    });

    String movieShowId = '$movieName-$showDate-$startTime';
    DocumentReference seatsRef = FirebaseFirestore.instance.collection('Seats').doc(movieShowId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(seatsRef);

      if (!snapshot.exists) {
        transaction.set(seatsRef, {
          'movieName': movieName,
          'showDate': showDate,
          'startTime': startTime,
          'totalSeats': 197,
          'occupiedSeats': seatsFormatted.length,
          'emptySeats': 197 - seatsFormatted.length,
        });
      } else {
        int occupiedSeats = snapshot['occupiedSeats'] + seatsFormatted.length;
        transaction.update(seatsRef, {
          'occupiedSeats': occupiedSeats,
          'emptySeats': 197 - occupiedSeats,
        });
      }
    });

    await clearLocks(selectedSeats);
  }

  Future<void> clearLocks(List<String> seats) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (String seat in seats) {
      String row = seat.substring(0, 1);
      int col = int.parse(seat.substring(1));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('locks')
          .where('seat.row', isEqualTo: row)
          .where('seat.col', isEqualTo: col)
          .where('lockedBy', isEqualTo: userId)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
  }

  Future<void> lockSeat(String seat) async {
    String row = seat.substring(0, 1);
    int col = int.parse(seat.substring(1));
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Check if the seat is already locked
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('locks')
        .where('seat.row', isEqualTo: row)
        .where('seat.col', isEqualTo: col)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Compare timestamps
      DocumentSnapshot lockDoc = querySnapshot.docs.first;
      Timestamp lockedAt = lockDoc['lockedAt'];
      String lockedBy = lockDoc['lockedBy'];

      if (lockedBy != userId && lockedAt != null) {
        // If locked by another user, show a message
        return Future.error('Seat already locked by another user. Please select another seat.');
      } else {
        // If locked by the current user, update the timestamp
        await lockDoc.reference.update({'lockedAt': Timestamp.now()});
      }
    } else {
      // If the seat is not locked, lock it for the current user
      DocumentReference lockRef = await FirebaseFirestore.instance.collection('locks').add({
        'seat': {'row': row, 'col': col},
        'lockedBy': userId,
        'lockedAt': Timestamp.now(),
      });

      // Set a timer to unlock the seat after 2 minutes if not confirmed
      Timer(Duration(minutes: 2), () async {
        DocumentSnapshot lockSnapshot = await lockRef.get();
        if (lockSnapshot.exists) {
          // Check if the seat is still locked and not confirmed
          await unlockSeat(seat);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session expired '),
            ),
          );
          // Refresh the seat layout
          setState(() {
            _initializeSeatStates();
          });
          // Redirect to the home screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    }
  }

  Future<void> unlockSeat(String seat) async {
    String row = seat.substring(0, 1);
    int col = int.parse(seat.substring(1));
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('locks')
        .where('seat.row', isEqualTo: row)
        .where('seat.col', isEqualTo: col)
        .where('lockedBy', isEqualTo: userId)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<String>> loadOccupiedSeats(String movieName, String showDate, String startTime) async {
    List<String> occupiedSeats = [];

    try {
      final DateFormat dateFormat = DateFormat('dd MMMM yyyy');
      final String formattedShowDate = dateFormat.format(DateTime.parse(showDate));

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .where('movieName', isEqualTo: movieName)
          .where('showDate', isEqualTo: formattedShowDate)
          .where('startTime', isEqualTo: startTime)
          .get();

      querySnapshot.docs.forEach((doc) {
        List<dynamic> seats = doc['selectedSeats'];
        seats.forEach((seat) {
          try {
            String row = seat['row'];
            int col;
            if (seat['col'] is String) {
              col = int.parse(seat['col']);
            } else if (seat['col'] is int) {
              col = seat['col'];
            } else {
              throw Exception('Invalid type for column: ${seat['col']}');
            }
            String seatString = '$row$col';
            print("Occupied Seat: $seatString");
            occupiedSeats.add(seatString);
          } catch (e) {
            print("Error processing seat: $seat, Error: $e");
          }
        });
      });
    } catch (e) {
      print("Error loading occupied seats: $e");
    }

    return occupiedSeats;
  }

  Future<List<String>> loadLockedSeats(String movieName, String showDate, String startTime) async {
    List<String> lockedSeats = [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('locks')
          .where('movieName', isEqualTo: movieName)
          .where('showDate', isEqualTo: showDate)
          .where('startTime', isEqualTo: startTime)
          .get();

      querySnapshot.docs.forEach((doc) {
        lockedSeats.add(doc['seat']);
      });
    } catch (e) {
      print("Error loading locked seats: $e");
    }

    return lockedSeats;
  }
}
