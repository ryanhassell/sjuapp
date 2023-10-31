import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sjuapp/user.dart';
import 'dart:convert';
import 'trip_history.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class Rider {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime dateRegistered;
  final String emailAddress;
  final int phoneNumber;

  Rider({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateRegistered,
    required this.emailAddress,
    required this.phoneNumber,
  });

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateRegistered: DateTime.parse(json['date_registered']),
      emailAddress: json['email_address'],
      phoneNumber: json['phone_number'],
    );
  }
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
      home: const MyHomePage(title: 'sjuapp Home Page'),
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
  List<Rider> riderDataList = [];

  Future<void> fetchDataFromApi() async {
    final url = Uri.parse('http://127.0.0.1:8000/riders'); // Replace with your API URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        riderDataList = data.map((item) => Rider.fromJson(item)).toList();
      });
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }
  void fetchTripsByUser(int userId) async {
    final url = Uri.parse('http://127.0.0.1:8000/trips/by-user/$userId');
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Handle user icon button press
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
                fetchTripsByUser(3); // Pass the user ID
              },
              child: Text(
                'View Trip History',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
            ),
          ),


              Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle "Request a Ride" button press
              },
              child: Text(
                'Request a Ride',
                style: TextStyle(
                  color: Colors.white, // main page button color
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // button color
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
                primary: Colors.red, // button color
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle "Campus Map" button press
              },
              child: Text(
                'Campus Map',
                style: TextStyle(
                  color: Colors.white, // main page button color
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // button color
              ),
            ),
          ),
          Divider(height: 20, color: Colors.black),
          for (final rider in riderDataList)
            GestureDetector(
              onTap: () {
                print("Tapped Rider ID: ${rider.id}");
                print("First Name: ${rider.firstName}");
                print("Last Name: ${rider.lastName}");
                print("Phone Number: ${rider.phoneNumber}");
                // Add more handling as needed
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ID: ${rider.id}", style: TextStyle(fontSize: 16)),
                    Text("First Name: ${rider.firstName}", style: TextStyle(fontSize: 16)),
                    Text("Last Name: ${rider.lastName}", style: TextStyle(fontSize: 16)),
                    Text("Date Registered: ${rider.dateRegistered}", style: TextStyle(fontSize: 16)),
                    Text("Email Address: ${rider.emailAddress}", style: TextStyle(fontSize: 16)),
                    Text("Phone Number: ${rider.phoneNumber}", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchDataFromApi,
        tooltip: 'Fetch Data',
        child: const Icon(Icons.download),
      ),
    );
  }
}