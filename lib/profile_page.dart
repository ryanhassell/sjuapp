import 'package:flutter/material.dart';
import 'user.dart'; // Your user model
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = fetchUserData();
  }

  Future<User> fetchUserData() async {
    // Replace with the actual user ID and endpoint URL
    final userId = 1; // Example user ID
    final url = Uri.parse('http://10.0.0.21:8000/users/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

  Widget buildSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      title: buildTitle('Name'),
                      subtitle: buildSubtitle('${snapshot.data!.firstName} ${snapshot.data!.lastName}'),
                    ),
                    ListTile(
                      title: buildTitle('Date Registered'),
                      subtitle: buildSubtitle('${snapshot.data!.dateRegistered.day}/${snapshot.data!.dateRegistered.month}/${snapshot.data!.dateRegistered.year}'),
                    ),
                    ListTile(
                      title: buildTitle('Email Address'),
                      subtitle: buildSubtitle(snapshot.data!.emailAddress),
                    ),
                    ListTile(
                      title: buildTitle('Phone Number'),
                      subtitle: buildSubtitle(snapshot.data!.phoneNumber),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text("No user data available"));
          }
        },
      ),
    );
  }
}