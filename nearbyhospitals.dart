import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:freefall/apikey.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart'; // For LatLng

class NearbyHospitalsWidget extends StatefulWidget {
  final double latitude;
  final double longitude;

  const NearbyHospitalsWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _NearbyHospitalsWidgetState createState() => _NearbyHospitalsWidgetState();
}

class _NearbyHospitalsWidgetState extends State<NearbyHospitalsWidget> {
  List<dynamic> hospitals = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchNearbyHospitals();
  }

  Future<void> fetchNearbyHospitals() async {
    final String apiUrl =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/hospital.json?proximity=${widget.longitude},${widget.latitude}&access_token=${ApiKeys.mapboxapi}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          hospitals = data['features'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch data: ${response.reasonPhrase}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Column(
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                final hospital = hospitals[index];
                return ListTile(
                  title: Text(hospital['text']),
                  subtitle: Text(hospital['place_name']),
                  leading: const Icon(Icons.local_hospital),
                );
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(widget.latitude, widget.longitude),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=${ApiKeys.mapboxapi}",
                  additionalOptions: {
                    "access_token":
                    ApiKeys.mapboxapi,
                  },
                ),
                MarkerLayer(
                  markers: [
                    // Current location marker
                    Marker(
                      point: LatLng(widget.latitude, widget.longitude),
                      width: 30.0, // Set the width for the marker
                      height: 30.0, // Set the height for the marker
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 30.0,
                      ),
                    ),
                    // Hospital markers
                    ...hospitals.map((hospital) {
                      final coords = hospital['geometry']['coordinates'];
                      return Marker(
                        point: LatLng(coords[1], coords[0]),
                        width: 30.0, // Set marker width
                        height: 30.0, // Set marker height
                        child: const Icon(
                          Icons.local_hospital,
                          color: Colors.red,
                          size: 25.0,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
