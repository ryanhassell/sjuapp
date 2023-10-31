import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class Rider {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime dateRegistered;
  final String emailAddress;
  final int phoneNumber;

  Rider({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateRegistered,
    required this.emailAddress,
    required this.phoneNumber,
  });

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateRegistered: DateTime.parse(json['date_registered']),
      emailAddress: json['email_address'],
      phoneNumber: json['phone_number'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sjuapp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          backgroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'sjuapp Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Rider> riderDataList = [];

  Future<void> fetchDataFromApi() async {
    final url = Uri.parse('http://127.0.0.1:8000/riders'); // Replace with your API URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        riderDataList = data.map((item) => Rider.fromJson(item)).toList();
      });
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: riderDataList.length,
        itemBuilder: (context, index) {
          final rider = riderDataList[index];

          return GestureDetector(
            onTap: () {
              print("Tapped Rider ID: ${rider.id}");
              print("First Name: ${rider.firstName}");
              print("Last Name: ${rider.lastName}");
              print("Phone Number: ${rider.phoneNumber}");
              // Add more handling as needed
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ID: ${rider.id}", style: TextStyle(fontSize: 16)),
                  Text("First Name: ${rider.firstName}", style: TextStyle(fontSize: 16)),
                  Text("Last Name: ${rider.lastName}", style: TextStyle(fontSize: 16)),
                  Text("Date Registered: ${rider.dateRegistered}", style: TextStyle(fontSize: 16)),
                  Text("Email Address: ${rider.emailAddress}", style: TextStyle(fontSize: 16)),
                  Text("Phone Number: ${rider.phoneNumber}", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchDataFromApi,
        tooltip: 'Fetch Data',
        child: const Icon(Icons.download),
      ),
    );
  }
}
