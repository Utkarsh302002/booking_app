

import 'dart:async';
import 'package:booking_app/seatlayoutscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookMovieScreen extends StatefulWidget {
  final String movieName;

  BookMovieScreen({required this.movieName});

  @override
  _BookMovieScreenState createState() => _BookMovieScreenState();
}

class _BookMovieScreenState extends State<BookMovieScreen> {
  double _opacity = 0.1;
  Map<String, List<Map<String, dynamic>>> showsByDate = {};
  String? selectedDate;
  Map<String, dynamic>? selectedShow; // To hold the selected show time
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchShows();
    _animateText();
  }

  void _animateText() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted) {  // Check if the widget is still in the tree
        setState(() {
          _opacity = _opacity == 0.1 ? 1.0 : 0.1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();  // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  Future<void> fetchShows() async {
    try {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day); // Get today's date without time

      var snapshot = await FirebaseFirestore.instance
          .collection('shows')
          .where('movie', isEqualTo: widget.movieName)
          .get();

      Map<String, List<Map<String, dynamic>>> tempShowsByDate = {};

      for (var doc in snapshot.docs) {
        var data = doc.data();
        DateTime? startDate = data['startDate'] is Timestamp ? data['startDate'].toDate() : DateTime.tryParse(data['startDate']);

        if (startDate != null && (startDate.isAfter(today) || startDate.isAtSameMomentAs(today))) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
          Map<String, dynamic> showData = {
            'movie': data['movie'] ?? 'No Movie',
            'startAt': data['startAt'] ?? 'No Time',
            'startDate': startDate,
            'cinema': data['cinema'] ?? 'No Cinema',
          };

          if (!tempShowsByDate.containsKey(formattedDate)) {
            tempShowsByDate[formattedDate] = [];
          }
          tempShowsByDate[formattedDate]?.add(showData);
        }

      }

      setState(() {
        showsByDate = tempShowsByDate;
        selectedDate = showsByDate.keys.isNotEmpty ? showsByDate.keys.first : null;
      });
    } catch (e) {
      print('Error fetching shows: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> dates = showsByDate.keys.toList();
    dates.sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Movie Ticket'),
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
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 2),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xffef7590), Color(0xfffcf264)],
                    ).createShader(bounds);
                  },
                  child: Text(
                    "Let's Book...!!!",
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              if (showsByDate.keys.isNotEmpty)
                Container(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: showsByDate.keys.map((date) =>
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                              selectedShow = null;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: selectedDate == date
                                  ? Color(0xffe50B9F4)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(date, style: TextStyle(
                                  color: selectedDate == date
                                      ? Colors.white
                                      : Colors.black)),
                            ),
                          ),
                        )).toList(),
                  ),
                ),
              if (selectedDate != null && showsByDate[selectedDate] != null)
                Expanded(
                  child: ListView.builder(
                    itemCount: showsByDate[selectedDate]!.length,
                    itemBuilder: (context, index) {
                      var show = showsByDate[selectedDate]![index];
                      bool isSelected = selectedShow == show;
                      return ListTile(
                        title: Text(show['movie']),
                        subtitle: Text("${show['startAt']} - ${show['cinema']}"),
                        tileColor: isSelected ? Color(0xffF7EB83) : Colors.white,
                        onTap: () {
                          setState(() {
                            selectedShow = isSelected ? null : show;
                          });
                        },
                      );
                    },
                  ),
                )
              else
                Expanded(

                    child: Text(
                      '                No shows available',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ),

            ],
          ),





          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      selectedShow != null ? Color(0xffF26085) : Color(0xff0B9F4),
                      selectedShow != null ? Color(0xffF26085) : Color(0xff0B9F4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: selectedShow != null ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeatLayoutScreen(
                          movieName: selectedShow!['movie'],
                          showDate: DateFormat('yyyy-MM-dd').format(selectedShow!['startDate']),
                          startTime: selectedShow!['startAt'],
                        ),
                      ),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Text('Book Now', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
