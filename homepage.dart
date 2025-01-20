import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freefall/Contacts.dart';
import 'package:freefall/dashboard.dart';
import 'package:freefall/nearbyhospitals.dart';
import 'package:geolocator/geolocator.dart';
import 'package:freefall/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'common.dart';

class HomePage extends StatefulWidget {
  static bool hasFallen = false;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Track the current index
  String classificationResult = "No result yet";  // Variable to store the API response

  // Initialize local notifications plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    initializeNotifications();
    // Set a timer to call the function every minute
    Timer.periodic(Duration(seconds: 10), (timer) {
      sendSensorData('j');  // Pass the sensor data accordingly (replace with real data)
    });
  }

  // Function to initialize local notifications
  Future<void> initializeNotifications() async {
    final androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings = InitializationSettings(android: androidInitialization);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Function to show notifications
  Future<void> showNotification(String message) async {
    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'This channel is used for alarm notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Fall Detection',
      message,
      notificationDetails,
    );
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
      Common.currentPosition = position;
    });
  }

  Future<void> sendSensorData(String username) async {
    const apiUrl = 'http://127.0.0.1:5000/classify'; // Update with your API URL

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          // Check for fall result in response
          if (HomePage.hasFallen) {
            classificationResult = 'fall';
            if (classificationResult == 'fall' && Common.currentPosition != null) {
              // Send the current location with the fall state
              final latitude = Common.currentPosition!.latitude;
              final longitude = Common.currentPosition!.longitude;
              showNotification('Person fell');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NearbyHospitalsWidget(latitude: latitude, longitude: longitude)),
              );
            }
          } else {
            classificationResult = 'Stand';
          }
        });
      } else {
        setState(() {
          classificationResult = "Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        classificationResult = "Error: $e";
      });
    }

    // If fall is not detected, send a notification
    if (classificationResult != 'fall') {
      showNotification('Fall detection has failed, please check the device.');
    }
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Dashboard();
      case 1:
        return ProfilePage(
          userProfile: {
            'name': 'Jithu',
            'email': 'jithu@gmail.com',
            'phone': '9982098298',
          },
        );
      case 2:
        return InactivityTrackerPage();
      case 3:
        if (Common.currentPosition != null) {
          return NearbyHospitalsWidget(
            latitude: Common.currentPosition!.latitude,
            longitude: Common.currentPosition!.longitude,
          );
        }
        return Center(child: Text("Location not available"));
      default:
        return Center(child: Text("Page not found"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FreeFall'),
        backgroundColor: Colors.redAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                setState(() {
                  _currentIndex = 0; // Change the page to Dashboard
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                setState(() {
                  _currentIndex = 1; // Change the page to Profile
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                setState(() {
                  _currentIndex = 2; // Change the page to Notifications
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.track_changes),
              title: Text('Tracker'),
              onTap: () {
                setState(() {
                  _currentIndex = 3; // Change the page to Tracker
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _getPage(_currentIndex), // Display the page based on current index
      ),
    );
  }
}
