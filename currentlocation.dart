import 'package:geolocator/geolocator.dart';

class LocationService {
  // Private constructor for singleton pattern
  LocationService._privateConstructor();

  // The instance of the service
  static final LocationService instance = LocationService._privateConstructor();

  // Variable to store current position
  Position? _currentPosition;

  // Getter to access current position
  Position? get currentPosition => _currentPosition;

  // Setter to update current position
  set currentPosition(Position? position) {
    _currentPosition = position;
  }
}
