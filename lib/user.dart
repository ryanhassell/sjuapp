import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;

import 'global_vars.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime dateRegistered;
  final String emailAddress;
  final String phoneNumber;
  final String sju_id;
  final String password;
  final Bool authenticated;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateRegistered,
    required this.emailAddress,
    required this.phoneNumber,
    required this.sju_id,
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
      sju_id: json['sju_id'],
      password: json['password'],
      authenticated: json['authenticated'],
    );
  }
  // Replace with the actual endpoint URL
  final userEndpoint = Uri.parse('http://'+ip+'/user/yourUserIdHere');

  Future<User> fetchUserData() async {
    final response = await http.get(userEndpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user data');
    }
  }

}
