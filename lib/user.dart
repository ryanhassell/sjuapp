import 'dart:convert';
import 'package:http/http.dart' as http;
import 'global_vars.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime dateRegistered;
  final String emailAddress;
  final String phoneNumber;
  final String userType;
  final String sjuId;
  final String password;
  final bool authenticated;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateRegistered,
    required this.emailAddress,
    required this.phoneNumber,
    required this.userType,
    required this.sjuId,
    required this.password,
    required this.authenticated,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateRegistered: DateTime.parse(json['date_registered']),
      emailAddress: json['email_address'],
      phoneNumber: json['phone_number'],
      userType: json['user_type'],
      sjuId: json['sju_id'],
      password: json['password'],
      authenticated: json['authenticated'],
    );
  }

  static Future<User> fetchUserData(int userId) async {
    final response = await http.get(Uri.parse('http://$ip/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // Updated toJson method to match the required structure
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'date_registered': dateRegistered.toIso8601String(),
      'email_address': emailAddress,
      'phone_number': phoneNumber,
      'user_type': userType,
      'sju_id': sjuId,
      'password': password,
      'authenticated': authenticated,
    };
  }

  static Future<void> registerUser(User newUser) async {
    final url = Uri.parse('http://$ip/users'); // Update with your registration endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(newUser.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register user');
    }
  }
}

