import 'package:flutter/material.dart';
import 'package:larisa_app/screens/bloodbank_homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BankAppointment extends StatefulWidget {
  final String userId;

  const BankAppointment({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _BankAppointmentState createState() => _BankAppointmentState();
}

class _BankAppointmentState extends State<BankAppointment> {
  late Future<QuerySnapshot> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture =
        FirebaseFirestore.instance.collection('appointment').get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        title: const Text(
          'Appointments',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: _appointmentsFuture,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final appointments = snapshot.data!.docs;
            // sort appointments based on date
            appointments.sort((a, b) {
              final aDate =
                  (a.data() as Map<String, dynamic>)['date'] as String;
              final bDate =
                  (b.data() as Map<String, dynamic>)['date'] as String;
              final aDateTime = _parseDateTimeFromString(aDate);
              final bDateTime = _parseDateTimeFromString(bDate);
              return aDateTime.compareTo(bDateTime);
            });
            return RefreshIndicator(
              onRefresh: _refreshAppointments,
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final data = appointment.data() as Map<String, dynamic>;
                    final date = data['date'];
                    final timeSlot = data['time_slot'];
                    final userUid = data['user_uid'];
                    final status = data['status'];

                    // check if the appointment status is pending
                    if (status == 'pending') {
                      return GestureDetector(
                        onTap: () {
                          _showDialog(context, appointment.reference, userUid);
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: _getColorForIndex(index),
                          child: ListTile(
                            title: Text(
                                'Date: $date, Time: $timeSlot, Status: $status'),
                            //subtitle: Text('User ID: $userUid'),
                          ),
                        ),
                      );
                    } else {
                      // return empty container if status is not pending
                      return Container();
                    }
                  },
                ),
              ),
            );
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
            icon: Icon(Icons.calendar_month),
            label: 'Appointment',
          ),
        ],
        selectedItemColor: Colors.red, 
        unselectedItemColor: Colors.grey, 
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0: 
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BloodBankHomeScreen(userId: widget.userId)),
              );
              break;
            case 1: 
              break;
          }
        },
      ),
    );
  }

  Color _getColorForIndex(int index) {
    return Colors.white;
  }

  DateTime _parseDateTimeFromString(String dateString) {
    final parts = dateString.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  Future<void> _refreshAppointments() async {
    setState(() {
      _appointmentsFuture =
          FirebaseFirestore.instance.collection('appointment').get();
    });
  }

  Future<void> _showDialog(BuildContext context,
      DocumentReference appointmentRef, String userUid) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Approval'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to approve or reject this booking?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _updateAppointmentStatus(appointmentRef, 'approved');
                Navigator.of(context).pop();
              },
              child: const Text('Approve'),
            ),
            TextButton(
              onPressed: () {
                _updateAppointmentStatus(appointmentRef, 'rejected', userUid);
                Navigator.of(context).pop();
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAppointmentStatus(
      DocumentReference appointmentRef, String newStatus,
      [String? userUid]) async {
    try {
      await appointmentRef.update({'status': newStatus});
      //print('Status updated successfully.');

      // If status is 'rejected', remove booking from donor collection
      if (newStatus == 'rejected' && userUid != null) {
        // get donor document reference
        final donorRef =
            FirebaseFirestore.instance.collection('donor').doc(userUid);

        // update donor document to remove booking field
        await donorRef.update({'booking': FieldValue.delete()});
        //print('Booking removed from donor collection.');
      }

      // Refresh appointments
      await _refreshAppointments();
    } catch (error) {
      //print('Error updating status: $error');
      // Handle error
    }
  }
}
