import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global_vars.dart';

class Trip {
  final int id;
  final String origin;
  final String destination;

  Trip({required this.id, required this.origin, required this.destination});

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      origin: json['origin'],
      destination: json['destination'],
    );
  }
}

class PickupRidePage extends StatefulWidget {
  @override
  _PickupRidePageState createState() => _PickupRidePageState();
}

class _PickupRidePageState extends State<PickupRidePage> {
  late Future<List<Trip>> _availableTripsFuture;

  @override
  void initState() {
    super.initState();
    _availableTripsFuture = fetchAvailableTrips();
  }

  Future<List<Trip>> fetchAvailableTrips() async {
    final url = Uri.parse('http://$ip/trips/available');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Trip.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load available trips');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Trips'),
      ),
      body: FutureBuilder<List<Trip>>(
        future: _availableTripsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No available trips'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final trip = snapshot.data![index];
                return ListTile(
                  title: Text('Trip ${trip.id}'),
                  subtitle: Text('${trip.origin} to ${trip.destination}'),
                  onTap: () {
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('404: No Data Found'));
          }
        },
      ),
    );
  }
}
