import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import for JSON handling

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
          ShuttleTile(shuttleType: 'East', shuttleId: 1), // Replace with actual shuttle ID
          SizedBox(height: 16),
          ShuttleTile(shuttleType: 'West', shuttleId: 2), // Replace with actual shuttle ID
        ],
      ),
    );
  }
}

class ShuttleTile extends StatefulWidget {
  final String shuttleType;
  final int shuttleId;

  const ShuttleTile({
    Key? key,
    required this.shuttleType,
    required this.shuttleId,
  }) : super(key: key);

  @override
  _ShuttleTileState createState() => _ShuttleTileState();
}

class _ShuttleTileState extends State<ShuttleTile> {
  late Future<String> _shuttleStatus; // Future for fetching shuttle status

  @override
  void initState() {
    super.initState();
    _shuttleStatus = fetchShuttleStatus(widget.shuttleId);
  }

  Future<String> fetchShuttleStatus(int shuttleId) async {
    final response = await http.get(Uri.parse('YOUR_BACKEND_URL/$shuttleId/status'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['status'] as String;
    } else {
      throw Exception('Failed to load shuttle status');
    }
  }
  @override
  Widget build(BuildContext context) {
    final scheduleInfo = widget.shuttleType == 'East'
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
        color: Colors.red.withOpacity(0.1), // Default color, change based on status
        child: FutureBuilder<String>(
          future: _shuttleStatus,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Loading indicator while fetching status
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final shuttleStatus = snapshot.data ?? 'Unknown';
              return ExpansionTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: shuttleStatus == 'Online' ? Colors.green : Colors.grey,
                  ),
                ),
                title: Text(
                  '${widget.shuttleType} Shuttle',
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ShuttleTrackingPage(shuttleType: widget.shuttleType)),
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
              );
            }
          },
        ),
      ),
    );
  }
}


class ShuttleTrackingPage extends StatelessWidget {
  final String shuttleType;

  const ShuttleTrackingPage({Key? key, required this.shuttleType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track $shuttleType Shuttle'),
      ),
      body: Center(
        child: Text(
          'Tracking information for $shuttleType Shuttle will be implemented here.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


