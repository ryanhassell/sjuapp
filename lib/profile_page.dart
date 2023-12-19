import 'package:flutter/material.dart';
import 'global_vars.dart';
import 'login_page.dart';
import 'user.dart';
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

  void signOut() {
    // Set current_user_id to -1
    current_user_id = -1;

    // Navigate to the login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false, // Remove all routes from the stack
    );
  }

  Future<User> fetchUserData() async {
    final userId = current_user_id;
    final url = Uri.parse('http://$ip/users/$userId');
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
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

  Widget buildSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),

      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                      subtitle: buildSubtitle('${snapshot.data!
                          .firstName} ${snapshot.data!.lastName}'),
                    ),
                    ListTile(
                      title: buildTitle('Date Registered'),
                      subtitle: buildSubtitle('${snapshot.data!.dateRegistered
                          .month}/${snapshot.data!.dateRegistered
                          .day}/${snapshot.data!.dateRegistered.year}'),
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
            return const Center(child: Text("No user data available"));
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: signOut,
          style: ElevatedButton.styleFrom(
            primary: Colors.red[700],
            onPrimary: Colors.white,
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Sign Out',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}