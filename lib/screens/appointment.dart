// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:larisa_app/screens/donor_notification.dart';
import 'package:larisa_app/screens/home_screen.dart';
import 'package:larisa_app/screens/status.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentScreen extends StatefulWidget {
  final String userId;

  const AppointmentScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<dynamic>> _events;
  DateTime? _selectedTime;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {}; 
  }

  //  generate time slots dynamically based on current time and selected day
  List<Widget> generateTimeSlots() {
    List<Widget> slots = [];
    final DateTime now = DateTime.now();
    for (int index = 0; index < 10; index++) {
      final startTime = TimeOfDay(hour: 8 + index, minute: 0);
      final selectedDateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        startTime.hour,
        startTime.minute,
      );
      // look if time slot is in the future based on selected day and current time
      if (selectedDateTime.isAfter(now)) {
        final endTime = TimeOfDay(hour: 9 + index, minute: 0);
        slots.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTime = selectedDateTime;
                });
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _selectedTime != null &&
                          _selectedTime?.hour == startTime.hour
                      ? Colors.red
                      : Colors.grey[200],
                ),
                child: Text(
                  '${startTime.format(context)} - ${endTime.format(context)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedTime != null &&
                            _selectedTime?.hour == startTime.hour
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime lastAllowedDay =
        today.add(const Duration(days: 90)); // Three months ahead

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        title: const Text(
          'Make an Appointment',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: today,
              lastDay: lastAllowedDay,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                return _events[day] ?? [];
              },
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 30.0), // Hide all days of the week
                      child: Text(
                        DateFormat.E().format(day),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, date, events) => Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red, 
                  ),
                  child: Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true, //  format button
              ),
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  'Select a timing slot:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: generateTimeSlots(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 70.0), //space below the button
                child: ElevatedButton(
                  onPressed: _checkExistingBookingAndProceed,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text('Book Appointment',
                      style: TextStyle(fontSize: 18)), 
                ),
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
            icon: Icon(Icons.calendar_today),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Status',
          ),
        ],
        selectedItemColor: Colors.red, 
        unselectedItemColor: Colors.grey, 
        currentIndex: 2, 
        onTap: (index) {
          switch (index) {
            case 0: 
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(userId: widget.userId)),
              );
              break;
            case 1: 
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DonorNotification(userId: widget.userId)),
              );
              break;
            case 2: 
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

  void _checkExistingBookingAndProceed() async {
    // see if a time slot has been chosen
    if (_selectedTime == null) {
      // display message saying no time slot has been chosen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No time slot has been chosen')),
      );
      return;
    }

    final donorRef =
        FirebaseFirestore.instance.collection('donor').doc(widget.userId);

    // to see if user already has a booking
    final donorDoc = await donorRef.get();
    final booking = donorDoc.data()?['booking'];

    // fetch document name for selected date and time
    String documentName = getDocumentName();

    // see if document exists in appointment collection
    final appointmentRef =
        FirebaseFirestore.instance.collection('appointment').doc(documentName);
    final appointmentSnapshot = await appointmentRef.get();

    //print('Selected document name: $documentName');
    //print('Existing appointment snapshot: ${appointmentSnapshot.exists}');

    // message if document exists
    if (appointmentSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This time slot is already taken')),
      );
      return;
    }

    // continue with booking appointment
    if (booking != null && booking.length == 8) {
      // parse existing booking date with the format "ddMMyyHH"
      String bookingDateString = booking.substring(0, 8);
      int day = int.parse(bookingDateString.substring(0, 2));
      int month = int.parse(bookingDateString.substring(2, 4));
      int year = int.parse(bookingDateString.substring(4, 6));
      int hour = int.parse(bookingDateString.substring(6, 8));
      DateTime bookingDate = DateTime(2000 + year, month, day,
          hour); //  years in range 2000-2099

      DateTime selectedDate =
          DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

      //print('Existing booking date: $bookingDate');
      //print('Selected appointment date: $selectedDate');

      // Calculate difference in days between selected date and existing booking date
      int daysDifference = selectedDate.difference(bookingDate).inDays;
      //print('Days difference: $daysDifference');

      if (daysDifference < 0) {
        // user has already booked for a date, show the snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'You have already booked for ${DateFormat('dd/MM/yyyy').format(bookingDate)}.')),
        );
      } else if (daysDifference >= 90) {
        // continue with appointment booking if selected date is more than 90 days after the existing booking date
        _confirmAppointment(donorRef);
      } else {
        // user cannot make another booking within 90 days since the last booking
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('You cannot have more than one donation in 3 months')),
        );
      }
    } else {
      // invalid booking format or no existing booking
      //print('Invalid booking date or no existing booking: $booking');
      _confirmAppointment(donorRef);
    }
  }

  void _confirmAppointment(
      DocumentReference<Map<String, dynamic>> donorRef) async {
    // display confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Appointment"),
          content: Text("Are you sure you want to book an appointment for "
              "${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year} "
              "at ${_selectedTime?.hour}:${_selectedTime?.minute.toString().padLeft(2, '0')}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // handle appointment booking
                String documentName = getDocumentName();
                final appointmentRef = FirebaseFirestore.instance
                    .collection('appointment')
                    .doc(documentName);
                final appointmentData = {
                  'user_uid': widget.userId,
                  'status': 'pending',
                  'date':
                      '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  'time_slot':
                      '${_selectedTime?.hour}:${_selectedTime?.minute.toString().padLeft(2, '0')}',
                };
                await appointmentRef.set(appointmentData);

                // update donor with booking details
                await donorRef.update({'booking': documentName});

                // close dialog
                Navigator.of(context).pop();

                // display snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Please await confirmation for your booking')),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  String getDocumentName() {
    // format document name as ddMMyyyyHH
    String day = _selectedDay.day.toString().padLeft(2, '0');
    String month = _selectedDay.month.toString().padLeft(2, '0');
    String year = _selectedDay.year.toString();
    String? hour = _selectedTime?.hour.toString().padLeft(2, '0');
    return hour != null
        ? "$day$month${year.substring(2)}$hour"
        : ""; // returns an empty string if hour is null
  }
}
