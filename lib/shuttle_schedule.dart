import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
          ShuttleTile(shuttleType: 'East', shuttleStatus: 'Online'), // Replace with actual status
          SizedBox(height: 16),
          ShuttleTile(shuttleType: 'West', shuttleStatus: 'Offline'), // Replace with actual status
        ],
      ),
    );
  }
}

class ShuttleTile extends StatelessWidget {
  final String shuttleType;
  final String shuttleStatus;

  const ShuttleTile({
    Key? key,
    required this.shuttleType,
    required this.shuttleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String scheduleInfo = shuttleType == 'East'
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
        color: shuttleType == 'East'
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
                      // Navigate to a page to track this shuttle
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShuttleTrackingPage(shuttleType: shuttleType)),
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
  final String shuttleType;

  const ShuttleTrackingPage({Key? key, required this.shuttleType}) : super(key: key);

  @override
  _ShuttleTrackingPageState createState() => _ShuttleTrackingPageState();
}

class _ShuttleTrackingPageState extends State<ShuttleTrackingPage> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track ${widget.shuttleType} Shuttle'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(39.9951, -75.2399), // Replace with your campus coordinates
          zoom: 15,
        ),
         onMapCreated: (controller) {
           setState(() {
             _mapController = controller;
             // Perform any actions when the map is ready
           });
         },
         markers: _buildMarkers(), // Create shuttle markers here
      ),
    );
  }

   Set<Marker> _buildMarkers() {
     // Logic to create shuttle markers based on the shuttle's location
     // You'll need to determine the shuttle's coordinates and update the markers accordingly
     // For example:
     return <Marker>[
       Marker(
         markerId: MarkerId('shuttleMarker'),
         position: LatLng(39.9951, -75.2399), // Replace with actual coordinates
         infoWindow: InfoWindow(title: 'Shuttle Location'),
         // Add more properties if needed
       ),
       // Add more markers for stops, etc., if required
     ].toSet();
   }
}
