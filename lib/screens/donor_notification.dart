import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // intl package to format date 
import 'package:larisa_app/screens/appointment.dart';
import 'package:larisa_app/screens/home_screen.dart';
import 'package:larisa_app/screens/status.dart';

class DonorNotification extends StatelessWidget {
  final String userId; 

  const DonorNotification(
      {super.key, required this.userId}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 65.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .doc(userId)
              .collection('messages')
              .orderBy('date',
                  descending: true) // sort by date in descending order
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching notifications'));
            } else if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      child: Image.asset('assets/nonotif.png'),
                    ),
                    const Positioned(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 250.0), // padding to top of the text added
                        child: Text(
                          'No notifications available',
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
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final notification = snapshot.data!.docs[index];
                  //print('Document data: ${notification.data()}');

                  // to access fields safely
                  final alert = notification.get('alert') ?? 'No alert';
                  final timestamp = notification.get('date') ?? Timestamp.now();

                  // formatting timestamp as string
                  final date = DateFormat.yMMMMd()
                      .add_jm()
                      .format((timestamp as Timestamp).toDate());

                  // change the background color based on the index
                  final color = index.isEven ? Colors.red[100] : Colors.white;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: color,
                    child: ListTile(
                      title: Text(alert),
                      subtitle: Text(date),
                    ),
                  );
                },
              );
            }
          },
        ),
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
        currentIndex: 1,
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
              break;
            case 2: 
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AppointmentScreen(userId: userId)),
              );
              break;
            case 3: 
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StatusScreen(userId: userId)),
              );
              break;
          }
        },
      ),
    );
  }
}
