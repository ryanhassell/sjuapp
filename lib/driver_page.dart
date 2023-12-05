import 'package:flutter/material.dart';
import 'pickup_ride_page.dart';

class DriverPage extends StatelessWidget {
  Widget _buildMainButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[700], // Button background color
        foregroundColor: Colors.white, // Text and icon color
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text('Driver Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: _buildMainButton(
            label: 'Current Ride Requests',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PickupRidePage()),
              );
            },
          ),
        ),
      ),
    );
  }
}
