import 'package:flutter/material.dart';
import 'package:larisa_app/models/donor.dart';
import 'package:larisa_app/screens/appointment.dart';
import 'package:larisa_app/screens/status.dart';
import 'package:larisa_app/screens/donor_notification.dart';
import 'package:larisa_app/services/authentication_service.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Donor? _donor; // declare as nullable
  bool _showDetails = false;
  bool _showDonationInfo = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() async {
    Donor? donor =
        await AuthenticationService().getUserFromFirestore(widget.userId);
    if (donor != null) {
      setState(() {
        _donor = donor;
      });
    } else {
      
    }
  }

  void _logout() {
    AuthenticationService().signOut().then((_) {
      Navigator.pushNamedAndRemoveUntil(context, '/sign_out', (route) => false);
    }).catchError((error) {
      //print('Error logging out: $error');
    });
  }

  String _getEligibleBloodTypes(String bloodType) {
    switch (bloodType) {
      case 'A+':
        return 'A+, AB+';
      case 'A-':
        return 'A+, A-, AB+, AB-';
      case 'B+':
        return 'B+, AB+';
      case 'B-':
        return 'B+, B-, AB+, AB-';
      case 'AB+':
        return 'AB+';
      case 'AB-':
        return 'AB+, AB-';
      case 'O+':
        return 'O+, A+, B+, AB+';
      case 'O-':
        return 'Everyone';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                _donor != null
                    ? 'Hello ${_donor!.name} ${_donor!.lastName}'
                    : '',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Every donation impacts up to three lives',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Consider donating today',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/home.png',
                      width: 300,
                      height: 192,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AppointmentScreen(userId: widget.userId)),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Schedule an appointment'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
                height: 10), // some space added between containers
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildRow(Icons.notifications, 'See your notifications', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DonorNotification(userId: widget.userId)),
                    );
                  }),
                  const SizedBox(height: 5), // space between rows
                  _buildRow(Icons.person, 'See your details', () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  }),
                  if (_showDetails) _buildDetailsDropdown(_donor!),
                  const SizedBox(height: 5), // space between rows
                  _buildRow(Icons.info, 'What to expect when you donate', () {
                    setState(() {
                      _showDonationInfo = !_showDonationInfo;
                    });
                  }),
                  if (_showDonationInfo) _buildDonationInfoDropdown(),
                ],
              ),
            ),
          ],
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
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DonorNotification(
                        userId: widget
                            .userId)), 
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AppointmentScreen(userId: widget.userId)),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StatusScreen(userId: widget.userId)),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildRow(IconData icon, String text, VoidCallback onTap,
      {Widget? dropdown}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.red,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        if (dropdown != null) dropdown,
      ],
    );
  }

  Widget _buildDetailsDropdown(Donor donor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${donor.name} ${donor.lastName},'),
          Text('Email: ${donor.email}'),
          Text('City: ${donor.city}'),
          Text('Blood Type: ${donor.bloodType}'),
          Text('You can donate to: ${_getEligibleBloodTypes(donor.bloodType)}'),
        ],
      ),
    );
  }

  Widget _buildDonationInfoDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When you arrive at the Donor Center:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
              '1. You must present your CPR Card. Information is gathered which will positively identify you and each of your donations.'),
          Text(
              '2. A technician will do a quick fingerstick to make sure you are not too anemic. Current pulse, blood pressure, and hemoglobin levels are also determined.'),
          Text(
              '3. A blood bank physician or nurse will review your health history and interview you in private. Please disclose any diseases related to your heart or lungs at this stage.'),
          Text(
              '4. A unit of blood (approximately 500 ml) will be withdrawn from an arm vein. The blood draw takes about 10 minutes.'),
          Text(
              '5. After your blood is drawn, you will be asked to relax in the donor lounge and have some juice and cookies to help your body replace the lost volume.'),
          SizedBox(height: 5),
          Text(
            'The entire process will take between 45 minutes to an hour. Your blood will be tested and if it has been found to have traces of a disease, you will be informed.',
          ),
        ],
      ),
    );
  }
}
