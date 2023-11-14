import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'global_vars.dart';

class DriverLoginPage extends StatelessWidget {
  final TextEditingController sjuidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("I'm a Driver"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Driver Login',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(),
              ),
              child: TextField(
                controller: sjuidController,
                decoration: InputDecoration(
                  labelText: 'SJU ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(),
              ),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final sjuid = sjuidController.text;
                final password = passwordController.text;
                final url = 'DUMMY_URL/driver/login?sjuid=$sjuid&password=$password';

                final response = await http.post(Uri.parse(url));
                if (response.statusCode == 200) {
                  final jsonResponse = json.decode(response.body);
                  final userId = jsonResponse['id'] as int;

                  // Set current_user directly to the user ID
                  current_user_id = userId;

                  // Navigate to the main page
                  Navigator.pushReplacementNamed(context, '/main_page');
                } else {
                  // Handle unsuccessful login
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red[700],
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
