import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController; // Make nullable to handle uninitialized state
  Location _locationService = Location();
  LatLng? _currentLocation;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMarkers();
  }

  // Fetch and display current location
  void _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if location services are enabled
    _serviceEnabled = await _locationService.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationService.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Request location permission if not granted
    _permissionGranted = await _locationService.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationService.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get and update current location
    _locationService.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          _currentLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          if (_mapController != null) {
            _updateMapPosition(_currentLocation!);
          }
        });
      }
    });
  }

  // Update camera position when the location changes
  void _updateMapPosition(LatLng location) {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(location));
    }
  }

  // Load markers from SharedPreferences
  Future<void> _loadMarkers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? itemsData = prefs.getString('items');

    if (itemsData != null) {
      List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(json.decode(itemsData));
      setState(() {
        _markers = items.map((item) {
          List<String> location = item['location'].split(',');
          return Marker(
            markerId: MarkerId(item['name']),
            position: LatLng(double.parse(location[0]), double.parse(location[1])),
            infoWindow: InfoWindow(title: item['name'], snippet: item['category']),
          );
        }).toSet();
      });
    }
  }

  // Map controller initialization
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller; // Assign the controller
    if (_currentLocation != null) {
      _updateMapPosition(_currentLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator()) // Show loading until location is fetched
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentLocation ?? LatLng(37.7749, -122.4194), // Default to San Francisco
          zoom: 12,
        ),
        markers: _markers, // Display markers
        myLocationEnabled: true, // Show device's current location
      ),
    );
  }
}
