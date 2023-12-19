import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:sjuapp/trip_history.dart';
import 'dart:convert';

import 'global_vars.dart';
class Driver {
  final int id;
  final int user_id;
  final bool available;
  final int current_trip;
  final double current_location_latitude;
  final double current_location_longitude;

  Driver({
    required this.id,
    required this.user_id,
    required this.available,
    required this.current_trip,
    required this.current_location_latitude,
    required this.current_location_longitude,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? 0, // Use default value or handle accordingly
      user_id: json['user_id'] ?? 0, // Use default value or handle accordingly
      available: json['available'] ?? false, // Use default value or handle accordingly
      current_trip: json['current_trip'] ?? 0, // Use default value or handle accordingly
      current_location_latitude: json['current_location_latitude'] ?? 0.0, // Use default value or handle accordingly
      current_location_longitude: json['current_location_longitude'] ?? 0.0, // Use default value or handle accordingly
    );
  }
}

class CurrentRidePage extends StatefulWidget {
  final int tripId;

  CurrentRidePage({required this.tripId});

  @override
  _CurrentRidePageState createState() => _CurrentRidePageState();
}

class _CurrentRidePageState extends State<CurrentRidePage> {
  late GoogleMapController mapController;
  Trip? currentTrip;
  bool isCancelling = false;

  static const Duration locationUpdateInterval = Duration(seconds: 2);
  late Timer locationUpdateTimer;
  LatLng driverLocation = LatLng(0,0); // Initial driver location

  @override
  void initState() {
    super.initState();
    _fetchCurrentTrip();
    startLocationUpdates();
  }

  @override
  void dispose() {
    locationUpdateTimer.cancel();
    super.dispose();
  }

  Future<void> sendLocationToServer(double latitude, double longitude, int userId) async {
    final url = Uri.parse('http://$ip/drivers/location/$userId/$latitude/$longitude');
    final response = await http.put(url);

    if (response.statusCode == 200) {
      print('Location updated successfully');
    } else {
      print('Failed to update location. Status code: ${response.statusCode}');
      // Handle the error as needed
    }
  }
  void startLocationUpdates() {
    locationUpdateTimer = Timer.periodic(locationUpdateInterval, (timer) {
      getDriverLocation(); // Call the function to get driver's location periodically
    });
  }

  Future<void> getDriverLocation() async {
    final int driverId = current_user_id;

    try {
      final url = Uri.parse('http://$ip/drivers/location/$driverId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final Driver driver = Driver.fromJson(responseData);

        // Update the driver's location on the map
        setState(() {
          driverLocation = LatLng(
            driver.current_location_latitude,
            driver.current_location_longitude,
          );
          print("Got Driver Location");
          sendLocationToServer(driver.current_location_latitude, driver.current_location_longitude, driverId);
          _updateMapPosition(driver.current_location_latitude, driver.current_location_longitude);
        });
      } else {
        print('Failed to get driver location. Status code: ${response.statusCode}');
        // Handle the error as needed
      }
    } catch (e) {
      print('Error getting driver location: $e');
      // Handle errors
    }
  }


  // Function to update driver location
  Future<void> updateDriverLocation() async {
    Location location = Location();

    final int driverId = current_user_id;

    try {
      LocationData currentLocation = await location.getLocation();
      double latitude = currentLocation.latitude!;
      double longitude = currentLocation.longitude!;

      // Send a request to FastAPI server with latitude and longitude
      await sendLocationToServer(latitude, longitude, driverId);
    } catch (e) {
      print("Error getting location: $e");
      // Handle errors, such as location services being disabled or permission denied
    }
  }

  Future<Trip?> fetchCurrentTrip(int tripId) async {
    final url = Uri.parse('http://'+ip+'/trips/$tripId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Trip.fromJson(responseData);
    } else {
      // Handle error or no current trips
      debugPrint('Failed to fetch trip: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _fetchCurrentTrip() async {
    final tripDetails = await fetchCurrentTrip(widget.tripId);
    if (tripDetails != null) {
      setState(() {
        currentTrip = tripDetails;
      });

      _updateMapPosition(tripDetails.startLocationLatitude,
          tripDetails.startLocationLongitude);
    }
  }

  void _updateMapPosition(double latitude, double longitude) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 12.0,
        ),
      ),
    );
  }

  Future<Trip?> fetchCurrentTripByUserId(int userId) async {
    final url = Uri.parse('http://'+ip+'/trips/current-trips/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Trip.fromJson(responseData);
    } else {
      // Handle error or no current trips
      return null;
    }
  }

  Future<void> cancelTrip() async {
    if (currentTrip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No current trip to cancel.')),
      );
      return;
    }

    setState(() {
      isCancelling = true;
    });

    final url = Uri.parse('http://'+ip+'/trips/${currentTrip!.id}');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip cancelled successfully!')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel the trip.')),
      );
    }

    setState(() {
      isCancelling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentTrip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Current Ride')),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Current Ride')),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: (controller) {
                  mapController = controller;
                  // Set initial driver's location on the map
                  _updateMapPosition(driverLocation.latitude, driverLocation.longitude);
                },
                initialCameraPosition: CameraPosition(
                  target: driverLocation, // Use driver's location
                  zoom: 12.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("driver"),
                    position: driverLocation, // Use driver's location
                    infoWindow: const InfoWindow(title: "Driver Location"),
                  ),
                  Marker(
                    markerId: const MarkerId("dropoff"),
                    position: LatLng(
                        currentTrip!.endLocationLatitude,
                        currentTrip!.endLocationLongitude
                    ),
                    infoWindow: const InfoWindow(title: "Dropoff Location"),
                  ),
                },
              ),
            ),
            const ListTile(
              title: Text('ETA for Driver'),
              subtitle: Text('10 minutes'), // Use actual data
            ),
            const ListTile(
              title: Text('Estimated Trip Time'),
              subtitle: Text('25 minutes'), // Use actual data
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: isCancelling ? null : () async { await cancelTrip();},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: isCancelling
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text('Cancel Trip'),
              ),
            ),
          ],
        ),
      );
    }
  }
}