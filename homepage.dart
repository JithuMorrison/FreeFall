import 'package:flutter/material.dart';
import 'package:freefall/Contacts.dart';
import 'package:freefall/dashboard.dart';
import 'package:freefall/nearbyhospitals.dart';
import 'package:geolocator/geolocator.dart';
import 'package:freefall/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _currentPosition;
  int _currentIndex = 0;  // Track the current index

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

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Dashboard(currpos: _currentPosition);
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
        if (_currentPosition != null) {
          return NearbyHospitalsWidget(
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
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
                  _currentIndex = 0;  // Change the page to Profile
                });
                Navigator.pop(context);  // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                setState(() {
                  _currentIndex = 1;  // Change the page to Profile
                });
                Navigator.pop(context);  // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                setState(() {
                  _currentIndex = 2;  // Change the page to Notifications
                });
                Navigator.pop(context);  // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.track_changes),
              title: Text('Tracker'),
              onTap: () {
                setState(() {
                  _currentIndex = 3;  // Change the page to Tracker
                });
                Navigator.pop(context);  // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _getPage(_currentIndex),  // Display the page based on current index
      ),
    );
  }
}
