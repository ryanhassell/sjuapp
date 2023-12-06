import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global_vars.dart';


enum ShuttleDirection { east, west }

class ShuttleSchedulePage extends StatefulWidget {
  @override
  _ShuttleSchedulePageState createState() => _ShuttleSchedulePageState();
}

class _ShuttleSchedulePageState extends State<ShuttleSchedulePage> {
  List<Map<String, dynamic>> shuttles = [];

  Future<void> fetchShuttles() async {
    final response = await http.get(Uri.parse('http://'+ip+'/shuttles'));
    if (response.statusCode == 200) {
      setState(() {
        shuttles = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      // Handle error gracefully
      print('Failed to fetch shuttle schedules: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchShuttles();
    return Scaffold(
      appBar: AppBar(
        title: Text('Shuttle Schedules'),
      ),
      body: ListView.builder(
        itemCount: shuttles.length,
        itemBuilder: (context, index) {
          return ShuttleTile(
            shuttleInfo: shuttles[index], // Pass shuttle information to the tile
          );
        },
      ),
    );
  }
}

class ShuttleTile extends StatefulWidget {
  final Map<String, dynamic> shuttleInfo;

  const ShuttleTile({
    Key? key,
    required this.shuttleInfo,
  }) : super(key: key);

  @override
  _ShuttleTileState createState() => _ShuttleTileState();
}

class _ShuttleTileState extends State<ShuttleTile> {
  String shuttleStatus = 'Offline';
  String shuttleDirection = '';
  String shuttleSchedule = '';
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    fetchShuttleStatus(widget.shuttleInfo['id']).then((status) {
      setState(() {
        shuttleStatus = status;
      });
    });
    fetchShuttleDirection(widget.shuttleInfo['id']).then((direction) {
      setState(() {
        shuttleDirection = direction;
      });
    });
    fetchShuttleSchedule(widget.shuttleInfo['id']).then((schedule) {
      setState(() {
        shuttleSchedule = schedule;
      });
    });
    fetchShuttleCoordinates(widget.shuttleInfo['id']).then((coordinates) {
      setState(() {
        latitude = coordinates['latitude'];
        longitude = coordinates['longitude'];
      });
    });
  }

  Future<String> fetchShuttleDirection(int shuttleId) async {
    try {
      final response = await http.get(Uri.parse('http://'+ip+'/shuttles/$shuttleId/direction'));

      if (response.statusCode == 200) {
        return json.decode(response.body)['direction'];
      } else {
        throw Exception('Failed to load direction');
      }
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }


  Future<String> fetchShuttleStatus(int shuttleId) async {
    try {
      final response = await http.get(Uri.parse('http://'+ip+'/shuttles/$shuttleId/status'));

      if (response.statusCode == 200) {
        return json.decode(response.body)['status'];
      } else {
        throw Exception('Failed to load status');
      }
    } catch (e) {
      print('Error: $e');
      return ''; // Return a default value or handle the error case
    }
  }

  Future<String> fetchShuttleSchedule(int shuttleId) async {
    try {
      final response = await http.get(Uri.parse('http://'+ip+'/shuttles/$shuttleId/schedule'));

      if (response.statusCode == 200) {
        return json.decode(response.body)['schedule'];
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }


  Future<Map<String, dynamic>> fetchShuttleCoordinates(int shuttleId) async {
    try {
      final response = await http.get(Uri.parse('http://'+ip+'/shuttles/$shuttleId/coordinates'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load coordinates');
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }


  @override
  Widget build(BuildContext context) {

    String shuttleType = widget.shuttleInfo['shuttle_direction'] == 'east' ? 'East' : 'West';
    String scheduleInfo = widget.shuttleInfo['shuttle_direction'] == 'east'
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
        color: shuttleStatus == 'Online' ? Colors.red.withOpacity(0.7) : Colors.red.withOpacity(0.1),
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
            Expanded(
              child: Padding(
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
                        int shuttleId = widget.shuttleInfo['id']; // Use the actual shuttle ID
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
  Set<Marker> _markers = {}; // Store markers in a Set
  bool _replacedInitialMarker = false;

  Future<void> fetchShuttleLocation() async {
    final response =
    await http.get(Uri.parse('http://'+ip+'/shuttles/${widget.shuttleId}/location'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      double latitude = responseData['latitude'];
      double longitude = responseData['longitude'];
      _updateShuttleMapPosition(latitude, longitude);
    } else {
      // Handle error gracefully
      print('Failed to fetch shuttle location: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchShuttleLocation();
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

    if (_replacedInitialMarker) {
      _markers.removeWhere((marker) => marker.markerId.value == 'shuttle_location');
    } else {
      _replacedInitialMarker = true;
    }

    _markers.add(
      Marker(
        markerId: MarkerId('shuttle_location'),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: 'Shuttle Location', snippet: '($latitude, $longitude)'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Update the markers on the map by combining existing markers and new markers
    setState(() {
      _markers = _markers.toSet();
    });
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
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(39.9951, -75.2399),
              zoom: 15.0,
            ),
            markers: _markers,
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
                fetchShuttleLocation(); // Corrected function call
              },
              child: Text('Refresh Location'),
            ),
          ),
        ],
      ),
    );
  }
}
