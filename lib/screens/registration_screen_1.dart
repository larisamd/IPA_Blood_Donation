// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:larisa_app/widgets/custom_text_field.dart';
import 'package:larisa_app/widgets/custom_button.dart';
import '../services/authentication_service.dart';

class RegistrationScreen1 extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthenticationService _authService = AuthenticationService();

  RegistrationScreen1({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        title: const Text(
          'Registration',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              CustomTextField(label: 'Email', controller: _emailController),
              CustomTextField(
                  label: 'Password',
                  isPassword: true,
                  controller: _passwordController),
              CustomTextField(
                  label: 'Confirm Password',
                  isPassword: true,
                  controller: _confirmPasswordController),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Next',
                onPressed: () {
                  _navigateToRegistrationScreen2(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToRegistrationScreen2(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }
    // validate email
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email address'),
        ),
      );
      return;
    }
    // validate password
    if (!isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Password must contain at least one uppercase letter, one lowercase letter, one digit, one special character, and be at least 8 characters long'),
        ),
      );
      return;
    }

    // find if email exists in Firestore
    bool emailExists = await emailExistsInFirestore(email);
    if (emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email address is already registered'),
        ),
      );
      return;
    }
    Navigator.pushNamed(context, '/registration2', arguments: {
      'email': email,
      'password': password,
    });
  }

  bool isValidEmail(String email) {
    //  email validation format, checking for @ and domain name and stops other character
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPassword(String password) {
    // password must contain at least one uppercase letter, one lowercase letter, one digit, one special character, and be at least 8 characters long
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#&*?.+-~])(?!.*?[\\/,<>])[A-Za-z0-9!@#&*?.+-~]{8,}$')
        .hasMatch(password);
  }

  Future<bool> emailExistsInFirestore(String email) async {
    try {
      return await _authService.emailExistsInFirestore(
          email); // Call method from the AuthenticationService
    } catch (e) {
      //print('Error checking email existence in Firestore: $e');
      return true; // return true in case of error to prevent registration
    }
  }
}
