import 'package:flutter/material.dart';
import 'package:larisa_app/screens/bank_appointment.dart';
import 'package:larisa_app/services/authentication_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BloodBankHomeScreen extends StatefulWidget {
  final String userId; 

  const BloodBankHomeScreen({super.key, required this.userId}); 
  @override
  // ignore: library_private_types_in_public_api
  _BloodBankHomeScreenState createState() => _BloodBankHomeScreenState();
}

class _BloodBankHomeScreenState extends State<BloodBankHomeScreen> {
  String selectedBloodType = 'A+';
  String selectedCity = 'All Cities';
  int eligibleDonors = 0;
  String hospital = '';

  List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  List<String> cities = [
    'All Cities',
    'Manama',
    'Riffa',
    'Muharraq',
    'Hamad Town',
    "A'ali",
    'Isa Town',
    'Sitra',
    'Budaiya',
    'Jidhafs',
    'Al-Malikiyah',
    'Jid Ali',
    'Sanabis',
    'Tubli',
    'Durrat Al Bahrain',
    'Gudaibiya',
    'Salmabad',
    'Jurdab',
    'Diyar Al Muharraq',
    'Amwaj Islands',
    'Al Hidd',
    'Arad',
    'Busaiteen',
    'Samaheej',
    'Al Dair',
    'Zinj',
  ];

  @override
  void initState() {
    super.initState();
    // call _getEligibleDonors() when page is initialized
    _getEligibleDonors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        title: const Text(
          'Blood Bank Home',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                menuMaxHeight: 250,
                value: selectedBloodType,
                onChanged: (newValue) {
                  setState(() {
                    selectedBloodType = newValue!;
                    _getEligibleDonors();
                  });
                },
                items: bloodTypes.map((bloodType) {
                  return DropdownMenuItem(
                    value: bloodType,
                    child: Text(bloodType),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select Blood Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                menuMaxHeight: 250,
                value: selectedCity,
                onChanged: (newValue) {
                  setState(() {
                    selectedCity = newValue!;
                    _getEligibleDonors();
                  });
                },
                items: cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text('Number of Eligible Donors: $eligibleDonors'), 
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showNotificationDialog();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Colors.red), 
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(0)), // square shape
                  ),
                ),
                child: const Text(
                  'Send Blood Alert',
                  style: TextStyle(color: Colors.white),
                ),
              ), 
            ],
          ),
        ),
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
        onTap: (index) {
          switch (index) {
            case 0: 
              break;
            case 1: 
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BankAppointment(
                        userId: widget
                            .userId)), 
              );
              break;
          }
        },
      ),
    );
  }

  void _logout(BuildContext context) {
    AuthenticationService().signOut().then((_) {
      Navigator.pushNamedAndRemoveUntil(context, '/sign_out', (route) => false);
    }).catchError((error) {
      //('Error logging out: $error');
      // handle error logging out
    });
  }

  void _getEligibleDonors() {
    CollectionReference donorsCollection =
        FirebaseFirestore.instance.collection('donor');
    Query query = donorsCollection.where('bloodType',
        whereIn: _getMatchingDonorBloodTypes(selectedBloodType));
    if (selectedCity != 'All Cities') {
      query = query.where('city', isEqualTo: selectedCity);
    }
    query.get().then((querySnapshot) {
      setState(() {
        eligibleDonors = querySnapshot.size;
      });
    }).catchError((error) {
      //print('Error retrieving eligible donors: $error');
      // handle error retrieving eligible donors
    });
  }

  List<String> _getMatchingDonorBloodTypes(String recipientBloodType) {
    switch (recipientBloodType) {
      case 'A+':
        return ['A+', 'A-', 'O+', 'O-'];
      case 'A-':
        return ['A-', 'O-'];
      case 'B+':
        return ['B+', 'B-', 'O+', 'O-'];
      case 'B-':
        return ['B-', 'O-'];
      case 'AB+':
        return ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      case 'AB-':
        return ['A-', 'B-', 'AB-', 'O-'];
      case 'O+':
        return ['O+', 'O-'];
      case 'O-':
        return ['O-'];
      default:
        return [];
    }
  }

  void _showNotificationDialog() {
    hospital = ''; // reset the hospital value each time the dialog is shown

    if (eligibleDonors == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No donors available in this area'),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text('Send Blood Alert'),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$eligibleDonors eligible donors of the selected blood type $selectedBloodType from $selectedCity will be sent a notification.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Hospital',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        // Update hospital value
                        hospital = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Check if hospital field is empty
                        if (hospital.isNotEmpty) {
                          _sendNotifications();
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please fill in the Hospital field'),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Colors.red), 
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(0)), 
                        ),
                      ),
                      child: const Text(
                        'Send alert to donors',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _sendNotifications() {
    // get eligible donors
    CollectionReference donorsCollection =
        FirebaseFirestore.instance.collection('donor');
    Query query = donorsCollection.where('bloodType',
        whereIn: _getMatchingDonorBloodTypes(selectedBloodType));
    if (selectedCity != 'All Cities') {
      query = query.where('city', isEqualTo: selectedCity);
    }
    query.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        // make a subcollection named 'messages' within donor's document
        CollectionReference messagesCollection = FirebaseFirestore.instance
            .collection('notifications')
            .doc(doc.id)
            .collection('messages');
        // add document to the 'messages' subcollection
        messagesCollection.add({
          'alert':
              '$hospital requires $selectedBloodType blood type from $selectedCity',
          'date': Timestamp.now(),
        }).then((messageDoc) {
          //print('Notification sent to donor ${doc.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alert sent'),
            ),
          );
        }).catchError((error) {
          //print('Error creating message document: $error');
        });
      }
    }).catchError((error) {
      //print('Error retrieving eligible donors: $error');
    });
  }
}
