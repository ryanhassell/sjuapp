import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global_vars.dart';


enum ShuttleDirection { east, west }

class ShuttleSchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shuttle Schedules'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ShuttleTile(shuttleDirection: ShuttleDirection.east, shuttleStatus: 'Online'), // Replace with actual status
          SizedBox(height: 16),
          ShuttleTile(shuttleDirection: ShuttleDirection.west, shuttleStatus: 'Offline'), // Replace with actual status
        ],
      ),
    );
  }
}

class ShuttleTile extends StatelessWidget {
  final ShuttleDirection shuttleDirection;
  final String shuttleStatus;

  const ShuttleTile({
    Key? key,
    required this.shuttleDirection,
    required this.shuttleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String shuttleType = shuttleDirection == ShuttleDirection.east ? 'East' : 'West';
    String scheduleInfo = shuttleDirection == ShuttleDirection.east
        ? 'The East Shuttle runs continuous loops between Main Campus and the Presidential City Apartments (3900 City Avenue) during the following hours: '
        '\n\nMonday-Friday –  7:20 a.m.-10:50 p.m.\nSaturday and Sunday – 10:20 a.m.-10:50 p.m.\n\nStops:\nMandeville Hall\n50th and City Avenue'
        '\n47th & City Avenue (City Ave North of 47th Street)\nTarget Shopping Center (City Ave North of Monument)\nPresidential/Lincoln Green (Stop is at Lincoln Green)'
        '\nBala Shopping Center (City Ave South of 47th Street)\nBala Ave & City Avenue'
        '\n\n*Please note that there is a stoppage in service from 10:20 a.m.-1:20 p.m., Monday-Friday and from 1:20 p.m.-3:20 p.m. on Saturday and Sunday.'
        : 'The West Shuttle runs continuous loops between Main Campus and Merion Gardens during the following hours: '
        '\n\nMonday-Friday: \nShuttle 1: 8:00 a.m.-3:15 p.m.\nShuttle 2: 7:15 a.m.-10:50 p.m.\n\nSaturday-Sunday:\n10:20 a.m.-10:50 p.m.'
        '\n\nStops:\nMandeville Hall\nCardinal Avenue Entrance Gate\nMerion Gardens\nOverbrook and City (Septa Stop)\nCardinal Avenue (Septa Stop)';


    return Card(
      elevation: 4,
      child: Container(
        color: shuttleDirection == ShuttleDirection.east
            ? shuttleStatus == 'Online' ? Colors.red.withOpacity(0.7) : Colors.red.withOpacity(0.1)
            : shuttleStatus == 'Online' ? Colors.red.withOpacity(0.7) : Colors.red.withOpacity(0.1),
        child: ExpansionTile(
          leading: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: shuttleStatus == 'Online' ? Colors.green : Colors.grey,
            ),
          ),
          title: Text(
            '$shuttleType Shuttle',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Status: $shuttleStatus'),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'General Schedule:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    scheduleInfo,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      int shuttleId = shuttleDirection == ShuttleDirection.east ? 1 : 2; // Adjust shuttle IDs
                      // Navigate to a page to track this shuttle
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShuttleTrackingPage(shuttleId: shuttleId)),
                      );
                    },
                    child: Center(
                      child: Text(
                        'Track this shuttle',
                        style: TextStyle(
                          color: shuttleStatus == 'Online' ? Colors.black : Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: shuttleStatus == 'Online' ? Colors.white.withOpacity(0.9) : Colors.grey.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ShuttleTrackingPage extends StatefulWidget {
  final int shuttleId; // Assuming you have the shuttle ID

  const ShuttleTrackingPage({Key? key, required this.shuttleId})
      : super(key: key);

  @override
  _ShuttleTrackingPageState createState() => _ShuttleTrackingPageState();
}

class _ShuttleTrackingPageState extends State<ShuttleTrackingPage> {
  GoogleMapController? _mapController;
  bool isLoading = false;

  Future<void> _fetchShuttleLocation(int shuttleId) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://'+ip+'/shuttles/$shuttleId/location');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final double latitude = responseData['latitude'];
      final double longitude = responseData['longitude'];
      _updateShuttleMapPosition(latitude, longitude);
    } else {
      // Handle error or no shuttle location available
      print('Failed to fetch shuttle location: ${response.statusCode}');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _updateShuttleMapPosition(double latitude, double longitude) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15.0, // Adjust the zoom level as needed
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Shuttle'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
              _fetchShuttleLocation(widget.shuttleId);
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(0.0, 0.0), // Initial position, will be updated
              zoom: 15.0,
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: ElevatedButton(
              onPressed: () {
                _fetchShuttleLocation(widget.shuttleId);
              },
              child: Text('Refresh Location'),
            ),
          ),
        ],
      ),
    );
  }
}