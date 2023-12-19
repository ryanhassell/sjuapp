import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'pickup_ride_page.dart';
import 'location_service.dart'; // Import the LocationService class

class DriverPage extends StatelessWidget {
  final LocationService _locationService = LocationService(); // Initialize LocationService

  Widget _buildMainButton(
      {required String label, required VoidCallback onPressed}) {
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


  Future<void> _enableLocationAccess(BuildContext context) async {
    LocationData? locationData = await _locationService.getCurrentLocation();
    if (locationData != null) {
      // Location access granted, update UI with location data
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location Data'),
            content: Text('Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Location access denied or not granted, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location data'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          alignment: Alignment.topCenter,  // This ensures top center alignment
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildMainButton(
                label: 'Current Ride Requests',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PickupRidePage()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildMainButton(
                label: 'Allow Location Access',
                onPressed: () {
                  _enableLocationAccess(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}