import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sjuapp/user.dart';

class Trip {
  final int id;
  final String tripType;
  final double startLocationLatitude; // Updated
  final double startLocationLongitude; // Updated
  final double endLocationLatitude; // Updated
  final double endLocationLongitude; // Updated
  final String driver;
  final List<int> passengers;

  Trip({
    required this.id,
    required this.tripType,
    required this.startLocationLatitude,
    required this.startLocationLongitude,
    required this.endLocationLatitude,
    required this.endLocationLongitude,
    required this.driver,
    required this.passengers,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      tripType: json['trip_type'],
      startLocationLatitude: json['start_location_latitude'], // Updated
      startLocationLongitude: json['start_location_longitude'], // Updated
      endLocationLatitude: json['end_location_latitude'], // Updated
      endLocationLongitude: json['end_location_longitude'], // Updated
      driver: json['driver'],
      passengers: List<int>.from(json['passengers']),
    );
  }
}

class TripHistoryPage extends StatefulWidget {
  final List<Trip> trips;

  TripHistoryPage({required this.trips});

  @override
  _TripHistoryPageState createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  GoogleMapController? _mapController;
  List<User> passengers = []; // List to store user objects

  @override
  void initState() {
    super.initState();
    // Fetch user objects for passengers
    fetchPassengers();
  }
  void fetchPassengers() async {
    final List<int> passengerIds = widget.trips.expand((trip) => trip.passengers).toList();
    final List<User> fetchedPassengers = [];

    for (final passengerId in passengerIds) {
      final url = Uri.parse('http://127.0.0.1:8000/users/$passengerId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final User user = User.fromJson(data);
        fetchedPassengers.add(user);
      }
    }

    setState(() {
      passengers = fetchedPassengers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip History'),
      ),
      body: ListView.builder(
        itemCount: widget.trips.length,
        itemBuilder: (context, index) {
          final trip = widget.trips[index];
          return GestureDetector(
            onTap: () {
              // Handle trip bubble click here
            },
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip Type: ${trip.tripType}', style: TextStyle(fontSize: 20)),
                  Text('Start Location: ${trip.startLocationLatitude}, ${trip.startLocationLongitude}', style: TextStyle(fontSize: 16)),
                  Text('End Location: ${trip.endLocationLatitude}, ${trip.endLocationLongitude}', style: TextStyle(fontSize: 16)),
                  Text('Driver: ${trip.driver}', style: TextStyle(fontSize: 16)),
                  Text('Passengers: ${passengers.map((user) => '${user.firstName} ${user.lastName}').join(', ')}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  Container(
                    height: 200, // Adjust the height as needed
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        setState(() {
                          _mapController = controller;
                        });
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(trip.startLocationLatitude, trip.startLocationLongitude),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('startLocation'),
                          position: LatLng(trip.startLocationLatitude, trip.startLocationLongitude),
                          infoWindow: InfoWindow(title: 'Start Location'),
                        ),
                        Marker(
                          markerId: MarkerId('endLocation'),
                          position: LatLng(trip.endLocationLatitude, trip.endLocationLongitude),
                          infoWindow: InfoWindow(title: 'End Location'),
                        ),
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
