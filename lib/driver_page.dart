import 'package:flutter/material.dart';
import 'current_ride_page.dart';

class DriverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            //
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => CurrentRidePage()),
            // );
          },
          child: Text('Current Ride Requests'),
        ),
      ),
    );
  }
}
