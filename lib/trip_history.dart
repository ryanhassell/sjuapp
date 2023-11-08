import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sjuapp/user.dart';

class Trip {
  final int id;
  final String tripType;
  final double startLocationLatitude;
  final double startLocationLongitude;
  final double endLocationLatitude;
  final double endLocationLongitude;
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
      startLocationLatitude: json['start_location_latitude'],
      startLocationLongitude: json['start_location_longitude'],
      endLocationLatitude: json['end_location_latitude'],
      endLocationLongitude: json['end_location_longitude'],
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
  List<User> passengers = [];
  String tripDescription = '';

  @override
  void initState() {
    super.initState();
    fetchPassengers();
  }

  void fetchPassengers() async {
    final List<int> passengerIds = widget.trips.expand((trip) => trip.passengers).toList();
    final List<User> fetchedPassengers = [];

    for (final passengerId in passengerIds) {
      final url = Uri.parse('http://10.0.0.21:8000/users/$passengerId');
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

  Future<void> updateTripDescription(double startLat, double startLng, double endLat, double endLng) async {
    final startLocation = await getLocationDescription(startLat, startLng);
    final endLocation = await getLocationDescription(endLat, endLng);

    final tripType = widget.trips[0].tripType;
    final description = tripType == 'group'
        ? 'Group Trip from $startLocation to $endLocation'
        : 'Trip from $startLocation to $endLocation';

    setState(() {
      tripDescription = description;
    });
  }

  Future<String> getLocationDescription(double latitude, double longitude) async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=api_key_here');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['results'] is List && decoded['results'].isNotEmpty) {
        return decoded['results'][0]['formatted_address'];
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trips.isNotEmpty) {
      final trip = widget.trips[0];

      if (tripDescription.isEmpty) {
        updateTripDescription(trip.startLocationLatitude, trip.startLocationLongitude, trip.endLocationLatitude, trip.endLocationLongitude);
      }

      return Scaffold(
        appBar: AppBar(
          title: Text('Trip History'),
        ),
        body: ListView.builder(
          itemCount: widget.trips.length,
          itemBuilder: (context, index) {
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
                    Text('$tripDescription', style: TextStyle(fontSize: 20)),
                    Text('Start Location: ${trip.startLocationLatitude}, ${trip.startLocationLongitude}', style: TextStyle(fontSize: 16)),
                    Text('End Location: ${trip.endLocationLatitude}, ${trip.endLocationLongitude}', style: TextStyle(fontSize: 16)),
                    Text('Driver: ${trip.driver}', style: TextStyle(fontSize: 16)),
                    Text('Passengers: ${passengers.map((user) => '${user.firstName} ${user.lastName}').join(', ')}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Container(
                      height: 200,
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
    } else {
      // Handle the case where there are no trips to display
      return Center(child: Text('No trips available'));
    }
  }
}
