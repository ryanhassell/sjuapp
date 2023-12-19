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
      id: json['id'],
      user_id: json['user_id'],
      available: json['available'],
      current_trip: json['current_trip'],
      current_location_latitude: json['current_location_latitude'],
      current_location_longitude: json['current_location_latitude'],
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

  @override
  void initState() {
    super.initState();
    _fetchCurrentTrip();

    // Start location updates when the page is initialized
    startLocationUpdates();
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
  Future<void> getDriverLocationFromServer(double latitude, double longitude, int userId) async {
    final url = Uri.parse('http://$ip/drivers/location/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('Location updated successfully');
    } else {
      print('Failed to update location. Status code: ${response.statusCode}');
      // Handle the error as needed
    }
  }

  // Function to start location updates
  void startLocationUpdates() {
    locationUpdateTimer = Timer.periodic(locationUpdateInterval, (timer) {
      updateDriverLocation(); // Call the function to update driver location
    });
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
                  _updateMapPosition(
                      currentTrip!.startLocationLatitude,
                      currentTrip!.startLocationLongitude
                  );
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentTrip!.startLocationLatitude,
                      currentTrip!.startLocationLongitude
                  ),
                  zoom: 12.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("pickup"),
                    position: LatLng(
                        currentTrip!.startLocationLatitude,
                        currentTrip!.startLocationLongitude
                    ),
                    infoWindow: const InfoWindow(title: "Pickup Location"),
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