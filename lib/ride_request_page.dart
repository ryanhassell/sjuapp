import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

import 'global_vars.dart';
import 'current_ride_page.dart';

class RideRequestPage extends StatefulWidget {
  @override
  _RideRequestPageState createState() => _RideRequestPageState();
}

class _RideRequestPageState extends State<RideRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final places = GoogleMapsPlaces(apiKey: googleApiKey); // Replace with your API key
  late double _pickupLocationLatitude;
  late double _pickupLocationLongitude;
  late double _dropoffLocationLatitude;
  late double _dropoffLocationLongitude;
  late final tripId;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handlePressButton(BuildContext context, TextEditingController controller,
      {required bool isPickup}) async {
    // Show the autocomplete places search dialog
    Prediction? p = await PlacesAutocomplete.show(offset: 0, radius:1000, types:[], strictbounds: false, region: "us",
      context: context,
      apiKey: googleApiKey, // Replace with your API key
      mode: Mode.overlay,
      language: "en",components: [Component(Component.country, "us")]
    );

    if (p != null) {
      // Get detail (lat/lng) for the selected place
      PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      // Set the controller text to the selected location description
      controller.text = p.description!;

      // Update the latitude and longitude state
      setState(() {
        if (isPickup) {
          _pickupLocationLatitude = lat;
          _pickupLocationLongitude = lng;
        } else {
          _dropoffLocationLatitude = lat;
          _dropoffLocationLongitude = lng;
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Format the date and time to ISO 8601 format without the timezone, because Dart doesn't support 'Z' directly in the DateFormat pattern.
      final String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()) + 'Z';

      final Map<String, dynamic> rideRequest = {
        'start_location_latitude': _pickupLocationLatitude,
        'start_location_longitude': _pickupLocationLongitude,
        'end_location_latitude': _dropoffLocationLatitude,
        'end_location_longitude': _dropoffLocationLongitude,
        'driver': "5", // Replace with actual driver's name or ID
        'passengers': [1], // Replace with actual passenger IDs
        'trip_type': "group",
        'trip_status': "current",
        'date_requested': formattedDate, // Use the formattedDate with 'Z' appended
      };

      final url = Uri.parse('http://'+ip+'/trips');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(rideRequest),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride requested successfully!')),
        );

        // Assuming responseData contains the trip id of the new ride
        tripId = responseData['id'];
        _navigateToCurrentRidePage(tripId); // Pass the trip ID to the new function
      } else {
        print('Failed to request ride with status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to request ride.')),
        );
      }
    }
  }

  void _navigateToCurrentRidePage(int tripId) {
    // Navigate to the CurrentRidePage with the tripId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrentRidePage(tripId: tripId),
      ),
    );
  }




  Widget _buildLocationInputField(TextEditingController controller, String labelText, bool isPickup) {
    return InkWell(
      onTap: () async {
        await _handlePressButton(context, controller, isPickup: isPickup);
      },
      borderRadius: BorderRadius.circular(30), // Rounded corners for the InkWell effect
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // Circular border radius for the bubble effect
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: IgnorePointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              border: InputBorder.none, // Remove the underline border
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a $labelText';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector(Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white, //background color
        borderRadius: BorderRadius.circular(30), // Rounded corners
        border: Border.all(color: Colors.grey.shade300), // Border color
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: Offset(0, 2), // Shadow position
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request a Ride'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            _buildLocationInputField(_pickupController, 'Pickup Location', true),
            SizedBox(height: 16.0),
            _buildLocationInputField(_dropoffController, 'Drop-off Location', false),
            _buildDateTimeSelector(
              ListTile(
                title: Text('Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ),
            _buildDateTimeSelector(
              ListTile(
                title: Text('Select Time: ${_selectedTime.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitRequest,
                child: Text('Submit Ride Request'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[700],
                onPrimary: Colors.white,
              )
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }
}

