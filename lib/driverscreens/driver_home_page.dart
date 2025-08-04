import 'package:flutter/material.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: Colors.grey[850],
      ),
      body: const Center(
        child: Text(
          'Welcome, Driver!',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
    );
  }
}
