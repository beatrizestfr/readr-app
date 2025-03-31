import 'package:flutter/material.dart';

class BienvScreen extends StatelessWidget {
  const BienvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/logo1.webp', width: 400),
          const SizedBox(height: 50),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/auth');
            },
            child: const Text(
              "Pulsa para comenzar",
              style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 0, 0, 0),
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
