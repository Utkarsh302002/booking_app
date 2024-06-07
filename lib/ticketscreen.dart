//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class TicketScreen extends StatefulWidget {
//   final String userId;
//
//   const TicketScreen({Key? key, required this.userId}) : super(key: key);
//
//   @override
//   _TicketScreenState createState() => _TicketScreenState();
// }
//
// class _TicketScreenState extends State<TicketScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('tickets')
//             .where('userId', isEqualTo: widget.userId)
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No tickets available'));
//           }
//           return ListView(
//             padding: EdgeInsets.all(16),
//             children: snapshot.data!.docs.map((DocumentSnapshot document) {
//               Map<String, dynamic> ticketData = document.data() as Map<String, dynamic>? ?? {};
//               List<dynamic> selectedSeats = ticketData['selectedSeats'] ?? [];
//
//               // Parse the show date and time
//               DateTime? showDateTime;
//               try {
//                 showDateTime = DateFormat('dd MMMM yyyy HH:mm').parse(
//                   '${ticketData['showDate']} ${ticketData['startTime']}',
//                 );
//               } catch (e) {
//                 return ListTile(
//                   title: Text('Error parsing date/time: ${e.toString()}'),
//                 );
//               }
//
//               // Get the current date and time
//               DateTime now = DateTime.now();
//
//               // Determine if the show has already passed
//               bool isPastShow = showDateTime.isBefore(now);
//
//               return Card(
//                 elevation: 4,
//                 margin: EdgeInsets.symmetric(vertical: 10),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Movie: ${ticketData['movieName']}',
//                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
//                       ),
//                       SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Icon(Icons.calendar_today, color: Colors.grey[600]),
//                           SizedBox(width: 8),
//                           Text(
//                             'Date: ${ticketData['showDate']}',
//                             style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             'Time: ${ticketData['startTime']}',
//                             style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Icon(Icons.event_seat, color: Colors.grey[600]),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Wrap(
//                               spacing: 5,
//                               children: selectedSeats.map<Widget>((seat) {
//                                 return Text(
//                                   seat.toString(),
//                                   style: TextStyle(fontSize: 16, color: Colors.black),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       if (ticketData.containsKey('username'))
//                         Row(
//                           children: [
//                             Icon(Icons.person, color: Colors.grey[600]),
//                             SizedBox(width: 8),
//                             Text(
//                               'Username: ${ticketData['username']}',
//                               style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       if (ticketData.containsKey('phone'))
//                         Row(
//                           children: [
//                             Icon(Icons.phone, color: Colors.grey[600]),
//                             SizedBox(width: 8),
//                             Text(
//                               'Phone: ${ticketData['phone']}',
//                               style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: isPastShow ? null : () => deleteTicket(document.id, ticketData),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: isPastShow ? Colors.grey : Colors.red,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                           padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
//                           textStyle: TextStyle(fontSize: 18),
//                         ),
//                         child: Text(
//                           'Cancel Ticket',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> deleteTicket(String ticketId, Map<String, dynamic> ticketData) async {
//     // Add ticket data to cancel_tickets collection
//     await FirebaseFirestore.instance.collection('cancel_tickets').doc(ticketId).set(ticketData);
//
//     // Delete ticket from tickets collection
//     await FirebaseFirestore.instance.collection('tickets').doc(ticketId).delete();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketScreen extends StatefulWidget {
  final String userId;

  const TicketScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Your Tickets'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tickets available'));
          }

          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

          // Sort documents by showDate and startTime
          docs.sort((a, b) {
            DateTime dateTimeA = parseDateTime(a);
            DateTime dateTimeB = parseDateTime(b);
            return dateTimeB.compareTo(dateTimeA);
          });

          return ListView(
            padding: EdgeInsets.all(16),
            children: docs.map((DocumentSnapshot document) {
              Map<String, dynamic> ticketData = document.data() as Map<String, dynamic>? ?? {};
              List<dynamic> selectedSeats = ticketData['selectedSeats'] ?? [];

              DateTime showDateTime = parseDateTime(document);

              // Get the current date and time
              DateTime now = DateTime.now();

              // Determine if the show has already passed
              bool isPastShow = showDateTime.isBefore(now);

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Movie: ${ticketData['movieName']}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            'Date: ${ticketData['showDate']}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Time: ${ticketData['startTime']}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.event_seat, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              spacing: 5,
                              children: selectedSeats.map<Widget>((seat) {
                                return Text(
                                  seat.toString(),
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (ticketData.containsKey('username'))
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Username: ${ticketData['username']}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      if (ticketData.containsKey('phone'))
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Phone: ${ticketData['phone']}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isPastShow ? null : () => deleteTicket(document.id, ticketData),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPastShow ? Colors.grey : Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text(
                          'Cancel Ticket',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  DateTime parseDateTime(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String showDate = data['showDate'];
    String startTime = data['startTime'];
    return DateFormat('dd MMMM yyyy HH:mm').parse('$showDate $startTime');
  }

  Future<void> deleteTicket(String ticketId, Map<String, dynamic> ticketData) async {
    // Add ticket data to cancel_tickets collection
    await FirebaseFirestore.instance.collection('cancel_tickets').doc(ticketId).set(ticketData);

    // Delete ticket from tickets collection
    await FirebaseFirestore.instance.collection('tickets').doc(ticketId).delete();
  }
}
