import 'package:flutter/material.dart';
import 'package:freefall/Contacts.dart';
import 'package:freefall/nearbyhospitals.dart';
import 'package:geolocator/geolocator.dart';
import 'package:freefall/profile.dart';

import 'common.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key});
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
        if (classificationResult == 'fall' && Common.currentPosition != null) {
          // Send the current location with the fall state
          final latitude = Common.currentPosition!.latitude;
          final longitude = Common.currentPosition!.longitude;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
