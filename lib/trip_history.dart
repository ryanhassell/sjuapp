import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sjuapp/user.dart';

import 'api_keys.dart';

class Trip {
  final int id;
  final String tripType;
  final double startLocationLatitude;
  final double startLocationLongitude;
  final double endLocationLatitude;
  final double endLocationLongitude;
  final String driver;
  final List<int> passengers;
  final String dateRequested;

  Trip({
    required this.id,
    required this.tripType,
    required this.startLocationLatitude,
    required this.startLocationLongitude,
    required this.endLocationLatitude,
    required this.endLocationLongitude,
    required this.driver,
    required this.passengers,
    required this.dateRequested,
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
      dateRequested: json['date_requested'],
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
  late Future<void> _loadingFuture;
  bool _isPageContentVisible = true; // This flag will handle the visibility of the whole page content

  @override
  void initState() {
    super.initState();
    _loadingFuture = _loadData();
  }

  Future<void> _loadData() async {
    if (widget.trips.isNotEmpty) {
      await fetchPassengers();
      final trip = widget.trips.first;
      await updateTripDescription(
          trip.startLocationLatitude,
          trip.startLocationLongitude,
          trip.endLocationLatitude,
          trip.endLocationLongitude
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> fetchPassengers() async {
    final List<int> passengerIds = widget.trips.expand((trip) =>
    trip.passengers).toList();
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

    if (mounted) {
      setState(() {
        passengers = fetchedPassengers;
      });
    }
  }

  Future<void> updateTripDescription(double startLat, double startLng,
      double endLat, double endLng) async {
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

  void _onBackPressed() {
    setState(() {
      _isPageContentVisible = false; // Set the entire page content visibility to false
    });

    // Delay the navigation to allow setState to take effect
    Future.delayed(Duration(milliseconds: 100), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }
  Future<String> getLocationDescription(double latitude,
      double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleApiKey');
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
    return WillPopScope(
      onWillPop: () async {
        _onBackPressed();
        return false; // We are handling the back button ourselves
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Trip History'),
        ),
        body: FutureBuilder(
          future: _loadingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While waiting for the futures to complete, show a loading indicator
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // If an error occurs, display an error message
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              // Once the data is fetched, show the page content
              return _isPageContentVisible ? buildPageContent() : SizedBox();
            }
          },
        ),
      ),
    );
  }

  Widget buildPageContent() {
    if (widget.trips.isEmpty) {
      return Center(child: Text('No trips available'));
    }

    final trip = widget.trips[0];
    return ListView.builder(
      itemCount: widget.trips.length,
      itemBuilder: (context, index) {
        return buildTripItem(trip);
      },
    );
  }

  Widget buildTripItem(Trip trip) {
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
            Visibility(
              visible: _isPageContentVisible,
              child: Container(
                height: 200,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
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
            ),
          ],
        ),
      ),
    );
  }
}