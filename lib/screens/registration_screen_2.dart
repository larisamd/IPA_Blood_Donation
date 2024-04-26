// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:larisa_app/widgets/custom_text_field.dart';
import 'package:larisa_app/widgets/custom_button.dart';
import '../services/authentication_service.dart';
import 'package:date_time_picker/date_time_picker.dart';

class RegistrationScreen2 extends StatefulWidget {
  const RegistrationScreen2({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationScreen2State createState() => _RegistrationScreen2State();
}

class _RegistrationScreen2State extends State<RegistrationScreen2> {
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];
  final List<String> cities = [
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _selectedBloodType;
  String? _selectedCity;
  String? _selectedBirthday;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String email = args['email'];
    final String password = args['password'];

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
              const SizedBox(height: 60),
              CustomTextField(label: 'Name', controller: _nameController),
              CustomTextField(
                  label: 'Last Name', controller: _lastNameController),
              _buildBirthdayPicker(),
              const SizedBox(height: 20),
              _buildDropdown('Blood Type', bloodTypes),
              const SizedBox(height: 20),
              _buildDropdown('City', cities),
              const SizedBox(height: 50),
              CustomButton(
                text: 'Register',
                onPressed: () {
                  _register(context, email, password);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdayPicker() {
    bool isPlaceholderVisible =
        _selectedBirthday == null || _selectedBirthday!.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 330,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DateTimePicker(
              type: DateTimePickerType.date,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onChanged: (date) {
                setState(() {
                  _selectedBirthday = date;
                });
              },
              decoration: InputDecoration(
                hintText: isPlaceholderVisible ? 'Birthday' : '',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return SizedBox(
      width: 330,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: label == 'Blood Type' ? _selectedBloodType : _selectedCity,
            decoration: InputDecoration(
              hintText: 'Select $label',
              border: const OutlineInputBorder(),
            ),
            isExpanded: true,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                if (label == 'Blood Type') {
                  _selectedBloodType = newValue;
                } else {
                  _selectedCity = newValue;
                }
              });
            },
            menuMaxHeight: 200,
          ),
        ],
      ),
    );
  }

  void _register(BuildContext context, String email, String password) async {
    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();

    // Validate name and last name with regular expressions
    if (!_isValidName(name) || !_isValidName(lastName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please enter a valid name and last name. Only twenty letters are allowed.'),
        ),
      );
      return;
    }

    if (name.isEmpty ||
        lastName.isEmpty ||
        _selectedBloodType == null ||
        _selectedCity == null ||
        _selectedBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
        ),
      );
      return;
    }

    // calculate age
    final age = _calculateAge(DateTime.parse(_selectedBirthday!));

    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are too young to donate blood. '),
        ),
      );
      return;
    }

    AuthenticationService()
        .registerWithEmailAndPassword(email, password, name, lastName,
            _selectedBloodType!, _selectedCity!)
        .then((user) async {
      if (user != null) {
        await _sendVerificationEmail(context, email);
        Navigator.pushReplacementNamed(context, '/sign_out');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed'),
          ),
        );
      }
    });
  }

  int _calculateAge(DateTime birthday) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthday.year;
    if (currentDate.month < birthday.month ||
        (currentDate.month == birthday.month &&
            currentDate.day < birthday.day)) {
      age--;
    }
    return age;
  }

  bool _isValidName(String value) {
    // allow only small and big letters 20 chars limit
    return RegExp(r'^[a-zA-Z]{1,20}$').hasMatch(value);
  }

  Future<void> _sendVerificationEmail(
      BuildContext context, String email) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInAnonymously();
        user = userCredential.user;
      }

      await user!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Verification email has been sent to $email. Please check your email inbox.'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send verification email: $error'),
        ),
      );
    }
  }
}
