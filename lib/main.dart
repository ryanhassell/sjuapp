import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sjuapp/ride_request_page.dart';
import 'dart:convert';
import 'package:sjuapp/profile_page.dart';
import 'package:sjuapp/trip_history.dart';

import 'current_ride_page.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sjuapp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          backgroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void fetchTripsByUser(int userId) async {
    final url = Uri.parse('http://10.0.0.21:8000/trips/by-user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Trip> trips = data.map((item) => Trip.fromJson(item)).toList();

      // Navigate to the Trip History page and pass the list of trips
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripHistoryPage(trips: trips),
        ),
      );
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  Future<int?> fetchCurrentTripId(int userId) async {
    final url = Uri.parse('http://10.0.0.21:8000/trips/current-trips/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // Assuming responseData is a map representing the trip data
      return responseData['id']; // Get the trip ID from the trip data
    }
    return null; // Return null if no current trip ID was found or in case of an error
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.directions_car),
            onPressed: () async {
              int? currentTripId = await fetchCurrentTripId(1); // Replace with actual user ID
              if (currentTripId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CurrentRidePage(tripId: currentTripId),
                  ),
                );
              } else {
                // Handle the case where there is no current trip ID
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No current ride found')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
      ),
      body: ListView(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              onPressed: () {
                fetchTripsByUser(1); // Pass the user ID
              },
              child: Text(
                'View Trip History',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ),


              Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RideRequestPage()),
                );              },
              child: Text(
                'Request a Ride',
                style: TextStyle(
                  color: Colors.white, // main page button color
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // button color
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle "View Shuttle Schedules" button press
              },
              child: Text(
                'View Shuttle Schedules',
                style: TextStyle(
                  color: Colors.white, // main page button color
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // button color
              ),
            ),
          ),
          Divider(height: 20, color: Colors.black),
        ],
      ),
    );
  }
}