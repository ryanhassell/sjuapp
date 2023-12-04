import 'package:flutter/material.dart';
import 'pickup_ride_page.dart'; // Make sure to import your PickupRidePage

class DriverPage extends StatelessWidget {
  Widget _buildMainButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _buildMainButton(
            label: 'Current Ride Requests',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PickupRidePage()), // Replace with your PickupRidePage
              );
            },
          ),
        ),
      ),
    );
  }
}
