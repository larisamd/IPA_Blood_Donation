import 'package:flutter/material.dart';
import 'package:larisa_app/screens/appointment.dart';
import 'package:larisa_app/screens/donor_notification.dart';
import 'package:larisa_app/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusScreen extends StatelessWidget {
  final String userId;

  const StatusScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        title: const Text(
          'Status',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('donor')
            .doc(userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    child: Image.asset('assets/nobook.png'),
                  ),
                  const Positioned(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 250.0), // padding to the top of the text
                      child: Text(
                        'No bookings available',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final booking = snapshot.data!.data() as Map<String, dynamic>?;
            if (booking != null && booking.containsKey('booking')) {
              final bookingValue = booking['booking'];
              if (bookingValue is String) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('appointment')
                      .doc(
                          bookingValue) // use booking value to get the corresponding appointment document
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<DocumentSnapshot> appointmentSnapshot) {
                    if (appointmentSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!appointmentSnapshot.hasData ||
                        !appointmentSnapshot.data!.exists) {
                      return Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              child: Image.asset('assets/nobook.png'),
                            ),
                            const Positioned(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top:
                                        250.0), // padding to the top of the text
                                child: Text(
                                  'No bookings available',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      final appointmentData = appointmentSnapshot.data!.data()
                          as Map<String, dynamic>;
                      final date = appointmentData['date'] as String;
                      final timeSlot = appointmentData['time_slot'] as String;
                      final status = appointmentData['status'] as String;

                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: _buildBookingRow(date, timeSlot, status),
                      );
                    }
                  },
                );
              } else {
                return const Center(child: Text('Invalid booking format'));
              }
            } else {
              return Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      child: Image.asset('assets/nobook.png'),
                    ),
                    const Positioned(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 250.0), // padding to the top of the text
                        child: Text(
                          'No bookings available',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Status',
          ),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(userId: userId)),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DonorNotification(userId: userId)),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AppointmentScreen(userId: userId)),
              );
              break;
            case 3:
              break;
          }
        },
      ),
    );
  }

  Widget _buildBookingRow(String date, String timeSlot, String status) {
    double maxHeight = status.toLowerCase() == 'approved' ? 250.0 : 150.0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      constraints:
          BoxConstraints(maxHeight: maxHeight), // box height based on status
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Booking Date', date),
            _buildInfoRow('Time Slot', timeSlot),
            _buildInfoRow('Status', status),
            if (status.toLowerCase() == 'approved')
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please be at the Central Blood Bank half an hour before your appointment',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            value,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
