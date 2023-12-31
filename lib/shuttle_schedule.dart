import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShuttleSchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shuttle Schedules'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ShuttleTile(shuttleType: 'East', shuttleStatus: 'Online'),
          SizedBox(height: 16),
          ShuttleTile(shuttleType: 'West', shuttleStatus: 'Offline'),
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Status: $shuttleStatus'),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'General Schedule:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scheduleInfo,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to a page to track this shuttle
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShuttleTrackingPage(shuttleType: shuttleType)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: shuttleStatus == 'Online' ? Colors.white.withOpacity(0.9) : Colors.grey.withOpacity(0.8),
                    ),
                    child: Center(
                      child: Text(
                        'Track this shuttle',
                        style: TextStyle(
                          color: shuttleStatus == 'Online' ? Colors.black : Colors.white.withOpacity(0.6),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track ${widget.shuttleType} Shuttle'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(39.9951, -75.2399),
          zoom: 15,
        ),
         onMapCreated: (controller) {
           setState(() {
           });
         },
         markers: _buildMarkers(),
      ),
    );
  }

   Set<Marker> _buildMarkers() {
     return <Marker>{
       const Marker(
         markerId: MarkerId('shuttleMarker'),
         position: LatLng(39.9951, -75.2399),
         infoWindow: InfoWindow(title: 'Shuttle Location'),
       ),
     };
   }
}
