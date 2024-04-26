import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:larisa_app/firebase_options.dart';
import 'package:larisa_app/screens/bloodbank_homescreen.dart';
import 'package:larisa_app/screens/home_screen.dart';
import 'package:larisa_app/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:larisa_app/screens/registration_screen_2.dart';
import 'package:larisa_app/screens/registration_screen_1.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BloodDonationApp());
}

class BloodDonationApp extends StatefulWidget {
  const BloodDonationApp({super.key});

  @override
  State<BloodDonationApp> createState() => _BloodDonationAppState();
}

class _BloodDonationAppState extends State<BloodDonationApp> {
  User? user;
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Donation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (context, child) => MediaQuery(
        //remove bold text for IOS
        data: MediaQuery.of(context).copyWith(boldText: false),
        child: child!,
      ),
      home: user != null ? _getHomeScreen(user!.uid) : LoginScreen(),
      routes: {
        '/registration': (context) => RegistrationScreen1(),
        '/registration2': (context) => const RegistrationScreen2(),
        '/sign_out': (context) => LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _getHomeScreen(String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donor')
          .doc(userId)
          .snapshots(),
      builder: (context, donorSnapshot) {
        if (donorSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (donorSnapshot.hasData && donorSnapshot.data!.exists) {
          // User exists in the "donor" collection
          return HomeScreen(userId: userId);
        } else {
          // Check if user exists in the "bloodbank" collection
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bloodbank')
                .doc(userId)
                .snapshots(),
            builder: (context, bloodBankSnapshot) {
              if (bloodBankSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (bloodBankSnapshot.hasData &&
                  bloodBankSnapshot.data!.exists) {
                // User exists in the "bloodbank" collection
                return BloodBankHomeScreen(userId: userId);
              } else {
                // User does not exist in either collection, show login screen
                return LoginScreen();
              }
            },
          );
        }
      },
    );
  }
}
