import 'package:flutter/material.dart';
import 'package:freefall/nearbyhospitals.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:freefall/profile.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Function to get the current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request user to enable it
      return;
    }

    // Check if location permissions are granted
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions denied, show an error
        return;
      }
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });
  }

  // Variable to store the API response
  String classificationResult = "No result yet";

  Future<void> sendSensorData(double x, double y, double z) async {
    const apiUrl = 'http://127.0.0.1:5000/classify'; // Update with your API URL

    try {
      /*final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'x': x, 'y': y, 'z': z}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);*/
        setState(() {
          //classificationResult = responseData['status'];
          classificationResult = 'fall';
          if (classificationResult == 'fall' && _currentPosition != null) {
            // Send the current location with the fall state
            final latitude = _currentPosition!.latitude;
            final longitude = _currentPosition!.longitude;
            Navigator.push(context, MaterialPageRoute(builder: (context)=>NearbyHospitalsWidget(latitude: latitude, longitude: longitude)));
          }
          });
      /*} else {
        setState(() {
          classificationResult = "Error: ${response.body}";
        });
      }*/
    } catch (e) {
      setState(() {
        classificationResult = "Error: $e";
      });
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FreeFall'),
        backgroundColor: Colors.redAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "Welcome to FreeFall",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Example sensor data
                      sendSensorData(3.0, 1.0, 0.5); // Update with actual values
                    },
                    child: Text("Send Data"),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Classification Result: $classificationResult",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            _navigateToPage(ProfilePage(
              userProfile: {
                'name': 'Jithu',
                'email': 'jithu@gmail.com',
                'phone': '9982098298',
              },
            ));
          } else if (index == 1) {
            _navigateToPage(NotificationsPage());
          } else if (index == 2) {
            if (_currentPosition != null) {
              _navigateToPage(NearbyHospitalsWidget(
                latitude: _currentPosition!.latitude,
                longitude: _currentPosition!.longitude,
              ));
            }
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Tracker',
          ),
        ],
      ),
    );
  }
}
