import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:larisa_app/screens/bloodbank_homescreen.dart';
import 'package:larisa_app/widgets/custom_text_field.dart';
import 'package:larisa_app/screens/home_screen.dart';
import '../services/authentication_service.dart';
import 'package:larisa_app/models/donor.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red, 
        automaticallyImplyLeading: false,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white), 
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(label: 'Email', controller: _emailController),
            CustomTextField(
                label: 'Password',
                isPassword: true,
                controller: _passwordController),
            const SizedBox(height: 20),
            SizedBox(
              width: 200, 
              height: 50,
              child: ElevatedButton(
                key: const Key(
                    'login_button'), // unique key to the login button for test
                onPressed: () {
                  _login(context);
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
                  'Login',
                  style: TextStyle(
                      color: Colors.white), 
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registration');
              },
              child: const Text(
                'Create an account',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
        ),
      );
      return;
    }
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('login failed'),
        ),
      );
      return;
    }

    AuthenticationService()
        .signInWithEmailAndPassword(email, password)
        .then((Donor? donor) {
      if (donor != null) {
        // check if the user is a donor by querying the "donor" collection
        FirebaseFirestore.instance
            .collection('donor')
            .doc(donor.id)
            .get()
            .then((donorData) {
          if (donorData.exists) {
            // if user is a donor, navigate to donor home screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(userId: donor.id),
              ),
            );
          } else {
            // user not found in the "donor" collection
            // Check if the user is a blood bank by querying the "bloodbank" collection
            FirebaseFirestore.instance
                .collection('bloodbank')
                .doc(donor.id)
                .get()
                .then((bloodBankData) {
              if (bloodBankData.exists) {
                // User is a blood bank, navigate to blood bank home screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BloodBankHomeScreen(userId: donor.id),
                  ),
                );
              } else {
                // User is neither a donor nor a blood bank
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User data not found'),
                  ),
                );
              }
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error retrieving blood bank data'),
                ),
              );
            });
          }
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error retrieving donor data'),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed'),
          ),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing in: $error'),
        ),
      );
    });
  }

  bool isValidEmail(String email) {
    //  email validation format, checking for @ and domain name and stops other character
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
