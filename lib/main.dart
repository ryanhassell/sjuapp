import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sjuapp/ride_request_page.dart';
import 'dart:convert';
import 'package:sjuapp/profile_page.dart';
import 'package:sjuapp/shuttle_schedule.dart';
import 'package:sjuapp/trip_history.dart';
import 'package:sjuapp/user.dart';
import 'global_vars.dart';
import 'current_ride_page.dart';
import 'driver_page.dart';

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
      home: const MyHomePage(title: 'SJU App Home'), // UNCOMMENT TO GO TO HOME PAGE
      //home: LoginPage(), // UNCOMMENT FOR TESTING LOGIN
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
  late final Future<User> _userFuture = fetchUserData();

  void fetchTripsByUser(int userId) async {
    final url = Uri.parse('http://$ip/trips/by-user/$userId');
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
    final url = Uri.parse('http://$ip/trips/current-trips/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // Assuming responseData is a map representing the trip data
      return responseData['id']; // Get the trip ID from the trip data
    }
    return null; // Return null if no current trip ID was found or in case of an error
  }

  Widget _buildMainButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[700], // Button background color
        foregroundColor: Colors.white, // Text and icon color
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
    );
  }

  Future<User> fetchUserData() async {
    // Replace with the actual user ID and endpoint URL
    final userId = current_user_id; // Example user ID
    final url = Uri.parse('http://$ip/users/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> mainButtons = [
      _buildMainButton(
        icon: Icons.history,
        label: 'View Trip History',
        onPressed: () {
          fetchTripsByUser(current_user_id);
        },
      ),
      const SizedBox(height: 16),
      _buildMainButton(
        icon: Icons.directions_car,
        label: 'Request a Ride',
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RideRequestPage()));
        },
      ),
      const SizedBox(height: 16),
      _buildMainButton(
        icon: Icons.directions_bus,
        label: 'View Shuttle Schedules',
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ShuttleSchedulePage()));
          // Handle "View Shuttle Schedules" button press
        },
      ),
    ];

    if (userType == "driver") {
      mainButtons.add(
        const SizedBox(height: 16),
      );
      mainButtons.add(
        _buildMainButton(
          icon: Icons.build,
          label: 'Driver Tools',
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DriverPage()));
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              FutureBuilder<User>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return Row(
                      children: [
                        Text(
                          'Welcome, ${snapshot.data!.firstName}',
                          style: const TextStyle(
                            fontSize: 25, // Increased font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Changed text color to white
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    );
                  } else {
                    return const Text('404: No User Found'); // Handle the case where there's no user data
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 40),
            color: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // The translucent background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/thwnd.jpg'),
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.33), // Adjust the opacity as needed
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Display buttons according to userType
                ...mainButtons,
                const Spacer(), // Push everything to the top
                // Current Ride Button at the bottom
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.car_rental, size: 24),
                    label: const Text('View Active Ride'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[900], // Text and icon color
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: Colors.red[900]!),
                    ),
                    onPressed: () async {
                      int? currentTripId = await fetchCurrentTripId(current_user_id); // Replace with actual user ID
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
                          const SnackBar(content: Text('No active ride found')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
