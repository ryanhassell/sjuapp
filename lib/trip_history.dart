import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sjuapp/user.dart';
import 'global_vars.dart';

class Trip {
  final int id;
  final String tripType;
  final double startLocationLatitude;
  final double startLocationLongitude;
  final double endLocationLatitude;
  final double endLocationLongitude;
  final int driver;
  final List<int> passengers;
  final DateTime dateRequested;
  final String tripStatus;
  GoogleMapController? mapController;
  String tripDescription = '';
  String tripDate = '';


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
    required this.tripStatus,
    this.mapController,
    required String tripDescription,
    required String tripDate,
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
      dateRequested: DateTime.parse(json['date_requested']),
      tripStatus: json['trip_status'],
      mapController: null, // Initialize with null
      tripDescription: '',
      tripDate: '',
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
  String tripDate = '';
  late Future<void> _loadingFuture;
  bool _isPageContentVisible = true;

  @override
  void initState() {
    super.initState();
    _loadingFuture = _loadData();
  }

  Future<void> _loadData() async {
    for (final trip in widget.trips) {
      await fetchPassengers(trip);
      await updateTripDescription(trip);
      await updateTripDate(trip);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> fetchPassengers(Trip trip) async {
    final List<int> passengerIds = trip.passengers;
    final List<User> fetchedPassengers = [];

    for (final passengerId in passengerIds) {
      final url = Uri.parse('http://' + ip + '/users/$passengerId');
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


  Future<void> updateTripDescription(Trip trip) async {
    final startLocation = await getLocationDescription(
      trip.startLocationLatitude,
      trip.startLocationLongitude,
    );
    final endLocation = await getLocationDescription(
      trip.endLocationLatitude,
      trip.endLocationLongitude,
    );

    final description = 'Trip from $startLocation to $endLocation';

    // Update the tripDescription field for the specific trip
    setState(() {
      trip.tripDescription = description;
    });
  }

  Future<void> updateTripDate(Trip trip) async {
    var month = '';
    if(trip.dateRequested.month == 1){
      month = "January";
    }
    if(trip.dateRequested.month == 2){
      month = "February";
    }
    if(trip.dateRequested.month == 3){
      month = "March";
    }
    if(trip.dateRequested.month == 4){
      month = "April";
    }
    if(trip.dateRequested.month == 5){
      month = "May";
    }
    if(trip.dateRequested.month == 6){
      month = "June";
    }
    if(trip.dateRequested.month == 7){
      month = "July";
    }
    if(trip.dateRequested.month == 8){
      month = "August";
    }
    if(trip.dateRequested.month == 9){
      month = "September";
    }
    if(trip.dateRequested.month == 10){
      month = "October";
    }
    if(trip.dateRequested.month == 11){
      month = "November";
    }
    if(trip.dateRequested.month == 12){
      month = "December";
    }
    var weekday = '';
    //weekday
    if(trip.dateRequested.weekday == 1){
      weekday = "Monday";
    }
    if(trip.dateRequested.weekday == 2){
      weekday = "Tuesday";
    }
    if(trip.dateRequested.weekday == 3){
      weekday = "Wednesday";
    }
    if(trip.dateRequested.weekday == 4){
      weekday = "Thursday";
    }
    if(trip.dateRequested.weekday == 5){
      weekday = "Friday";
    }
    if(trip.dateRequested.weekday == 6){
      weekday = "Saturday";
    }
    if(trip.dateRequested.weekday == 7){
      weekday = "Sunday";
    }
    final dateString = '$weekday $month ${trip.dateRequested.day}, ${trip.dateRequested.year}';
    // Update the tripDate field for the specific trip
    setState(() {
      trip.tripDate = dateString;
    });
  }

  Future<String> getLocationDescription(double latitude, double longitude) async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleApiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['results'] is List && decoded['results'].isNotEmpty) {
        final results = decoded['results'] as List<dynamic>;

        // Iterate through results to find the nearest address
        for (final result in results) {
          final components = result['address_components'] as List<dynamic>;
          final streetNumber = _getLongName(components, 'street_number');
          final streetName = _getLongName(components, 'route');

          if (streetNumber.isNotEmpty && streetName.isNotEmpty) {
            return '$streetNumber $streetName';
          }
        }

        // If no valid address found, use a more general description
        final formattedAddress = results[0]['formatted_address'];
        return 'an address close to $formattedAddress';
      }
    }

    return 'Location not found';
  }

  String _getLongName(List<dynamic> components, String type) {
    for (final component in components) {
      if (component['types'].contains(type)) {
        return component['long_name'].toString();
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onBackPressed();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Trip History'),
        ),
        body: FutureBuilder(
          future: _loadingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
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

    return ListView.builder(
      itemCount: widget.trips.length,
      itemBuilder: (context, index) {
        final trip = widget.trips[index];
        return buildTripItem(trip);
      },
    );
  }

  Widget buildTripItem(Trip trip) {
    final double midLat =
        (trip.startLocationLatitude + trip.endLocationLatitude) / 2;
    final double midLng =
        (trip.startLocationLongitude + trip.endLocationLongitude) / 2;
    final LatLngBounds bounds = getBounds(trip);

    return GestureDetector(
      onTap: () {
        // Handle trip bubble click here
      },
      child: Card(
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Container(
                height: 150,
                width: double.infinity,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;

                    // Adjust the camera position to fit the bounds of the trip
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngBounds(bounds, 50.0),
                    );
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(midLat, midLng),
                    zoom: 8,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('startLocation'),
                      position: LatLng(
                          trip.startLocationLatitude, trip.startLocationLongitude),
                      infoWindow: InfoWindow(title: 'Start Location'),
                    ),
                    Marker(
                      markerId: MarkerId('endLocation'),
                      position: LatLng(
                          trip.endLocationLatitude, trip.endLocationLongitude),
                      infoWindow: InfoWindow(title: 'End Location'),
                    ),
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trip.tripDate}', // Use tripDescription for the specific trip
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SquareFont'),
                  ),
                  Text(
                    '${trip.tripDescription}', // Use tripDescription for the specific trip
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SquareFont'),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder(
                    future: fetchDriverInfo(trip.driver),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error fetching driver info: ${snapshot.error}');
                      } else {
                        final driverInfo = snapshot.data as User;
                        return Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.car_rental, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Driver: ${driverInfo.firstName} ${driverInfo.lastName}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Passengers:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: trip.passengers.map((passengerId) {
                      return FutureBuilder(
                        future: fetchPassengerInfo(passengerId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text(
                                'Error fetching passenger info: ${snapshot.error}');
                          } else {
                            final passengerInfo = snapshot.data as User;
                            return GestureDetector(
                              onTap: () {
                                // Handle passenger bubble click here
                              },
                              child: Chip(
                                label: Text(
                                    '${passengerInfo.firstName} ${passengerInfo.lastName}'),
                                avatar: Icon(Icons.person),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<User> fetchPassengerInfo(int passengerId) async {
    final url = Uri.parse('http://' + ip + '/users/$passengerId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load passenger information');
    }
  }



  Future<User> fetchDriverInfo(int driverId) async {
    final url = Uri.parse('http://' + ip + '/users/$driverId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load driver information');
    }
  }

  void _onBackPressed() {
    setState(() {
      _isPageContentVisible = false;
    });

    Future.delayed(Duration(milliseconds: 100), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }
  LatLngBounds getBounds(Trip trip) {
    final LatLng startLocation = LatLng(trip.startLocationLatitude, trip.startLocationLongitude);
    final LatLng endLocation = LatLng(trip.endLocationLatitude, trip.endLocationLongitude);

    final double minLat = min(startLocation.latitude, endLocation.latitude);
    final double maxLat = max(startLocation.latitude, endLocation.latitude);
    final double minLng = min(startLocation.longitude, endLocation.longitude);
    final double maxLng = max(startLocation.longitude, endLocation.longitude);

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

