import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSelector extends StatefulWidget {
  @override
  _MapSelectorState createState() => _MapSelectorState();
}

class _MapSelectorState extends State<MapSelector> {
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(37.7749, -122.4194); // Default to San Francisco

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _selectLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _confirmLocation() {
    Navigator.pop(context, '${_selectedLocation.latitude}, ${_selectedLocation.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmLocation,
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 10,
        ),
        markers: {
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: _selectedLocation,
          ),
        },
        onTap: _selectLocation,
      ),
    );
  }
}
