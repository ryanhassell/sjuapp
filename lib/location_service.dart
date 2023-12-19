import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  Future<LocationData?> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData? locationData;

      serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return null;
        }
      }

      locationData = await _location.getLocation();
      return locationData;
    } catch (e) {
      // Handle exceptions or errors that might occur during location fetching
      print('Error fetching location: $e');
      return null;
    }
  }
}
