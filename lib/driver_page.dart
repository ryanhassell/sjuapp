import 'package:flutter/material.dart';
import 'package:location/location.dart'; // Import the Location service
import 'pickup_ride_page.dart';
import 'location_service.dart'; // Import the LocationService class


class LocationManager {
  static double? driverLatitude; // Static variable to store driver's latitude
  static double? driverLongitude; // Static variable to store driver's longitude

  static void updateDriverLocation(double? latitude, double? longitude) {
    driverLatitude = latitude;
    driverLongitude = longitude;
  }
}


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
      // Save latitude and longitude in the LocationManager
      LocationManager.updateDriverLocation(
          locationData.latitude,
          locationData.longitude,);
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
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  _enableLocationAccess(context); // Call function for location access
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
