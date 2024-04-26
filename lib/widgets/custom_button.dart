import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
              Colors.red), // Red button background color
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0)), // square shape
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white), // White text color for button
        ),
      ),
    );
  }
}
