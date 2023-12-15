import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sjuapp/trip_history.dart';
import 'dart:convert';
import 'driver_page.dart';
import 'global_vars.dart';
import 'dart:math';
import 'location_service.dart';
import 'package:location/location.dart';
import 'dart:async';

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
  Marker? driverMarker;

  late LocationService _locationService = LocationService(); // Instantiate LocationService


  @override
  void initState() {
    super.initState();
    _fetchCurrentTrip();
    _updateDriverMarker();

    // Update driver's location periodically, say every 30 seconds

    Timer.periodic(Duration(seconds: 30), (timer) {
      _updateDriverLocation();
    });
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

  // Function to update driver's marker on the map
  void _updateDriverMarker() {
    if (LocationManager.driverLatitude != null &&
        LocationManager.driverLongitude != null) {
      driverMarker = Marker(
        markerId: MarkerId("driver"),
        position: LatLng(
          LocationManager.driverLatitude!,
          LocationManager.driverLongitude!,
        ),
        infoWindow: InfoWindow(title: "Driver Location"),
      );
    }
  }

  Future<void> _updateDriverLocation() async {
    LocationData? locationData = await _locationService.getCurrentLocation();
    if (locationData != null) {
      // Update LocationManager with the new location data
      LocationManager.updateDriverLocation(
        locationData.latitude,
        locationData.longitude,
      );

      if (currentTrip != null) {
        double distance = calculateDistance(
          LocationManager.driverLatitude!,
          LocationManager.driverLongitude!,
          currentTrip!.startLocationLatitude,
          currentTrip!.startLocationLongitude,
        );

        double averageSpeed = 60.0; // in km/h
        int estimatedETA = estimateETA(distance, averageSpeed);

      }

      setState(() {
        // Update map and ETA based on the new location data
        _updateDriverMarker();
        _updateMapPosition(
          LocationManager.driverLatitude!,
          LocationManager.driverLongitude!,
        );
      });
    } else {
      // Handle case where location data is not available
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

  // Function to refresh the map and update driver's marker
  void _refreshMap() {
    setState(() {
      _updateDriverMarker();
      _updateMapPosition(
        currentTrip!.startLocationLatitude,
        currentTrip!.startLocationLongitude,
      );
    });
  }

  Future<void> cancelTrip() async {
    if (currentTrip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No current trip to cancel.')),
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
        SnackBar(content: Text('Trip cancelled successfully!')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel the trip.')),
      );
    }

    setState(() {
      isCancelling = false;
    });
  }

  String _calculateETA() {
    if (LocationManager.driverLatitude != null &&
        LocationManager.driverLongitude != null &&
        currentTrip != null &&
        currentTrip!.startLocationLatitude != null &&
        currentTrip!.startLocationLongitude != null) {
      double distance = calculateDistance(
        LocationManager.driverLatitude!,
        LocationManager.driverLongitude!,
        currentTrip!.startLocationLatitude!,
        currentTrip!.startLocationLongitude!,
      );

      double averageSpeed = 60.0; // in km/h

      int estimatedETA = estimateETA(distance, averageSpeed);

      return '$estimatedETA minutes';
    } else {
      // Handle the case when data is not available
      return 'N/A';
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int radiusOfEarth = 6371; // Earth's radius in km

    // Convert degrees to radians
    double lat1Radians = degreesToRadians(lat1);
    double lon1Radians = degreesToRadians(lon1);
    double lat2Radians = degreesToRadians(lat2);
    double lon2Radians = degreesToRadians(lon2);

    // Calculate differences in latitude and longitude
    double dLat = lat2Radians - lat1Radians;
    double dLon = lon2Radians - lon1Radians;

    // Haversine formula for distance calculation
    double a = pow(sin(dLat / 2), 2) +
        cos(lat1Radians) * cos(lat2Radians) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radiusOfEarth * c;

    return distance;
  }

  int estimateETA(double distance, double averageSpeed) {
    // Calculate time in hours
    double timeInHours = distance / averageSpeed;

    // Convert time to minutes
    int estimatedETA = (timeInHours * 60).round();
    return estimatedETA;
  }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    if (currentTrip == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Current Ride')),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('Current Ride')),
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
                    markerId: MarkerId("pickup"),
                    position: LatLng(
                        currentTrip!.startLocationLatitude,
                        currentTrip!.startLocationLongitude
                    ),
                    infoWindow: InfoWindow(title: "Pickup Location"),
                  ),
                  Marker(
                    markerId: MarkerId("dropoff"),
                    position: LatLng(
                        currentTrip!.endLocationLatitude,
                        currentTrip!.endLocationLongitude
                    ),
                    infoWindow: InfoWindow(title: "Dropoff Location"),
                  ),
                  if (driverMarker != null) driverMarker!,
                },
              ),
            ),
            ListTile(
              title: Text('ETA for Driver'),
              subtitle: Text(_calculateETA()), // Use actual data
            ),
            ListTile(
              title: Text('Estimated Trip Time'),
              subtitle: FutureBuilder<String>(
                future: Future.delayed(Duration(seconds: 1), () => _calculateETA()), // Replace with your actual async call
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                   } else if (snapshot.hasData) {
                      return Text(snapshot.data!);
                  } else {
                      return Text('N/A');
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: isCancelling ? null : () async { await cancelTrip();},
                child: isCancelling
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text('Cancel Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _refreshMap, // Refresh the map
              child: Text('Refresh Map'),
            ),
          ],
        ),
      );
    }
  }
}