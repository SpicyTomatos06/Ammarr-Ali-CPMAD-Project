import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  final double lat;
  final double lng;
  final String title;

  const MapPage({
    super.key,
    required this.lat,
    required this.lng,
    required this.title,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();

  LocationData? _userLocation;
  bool _requesting = false;

  Future<void> _getUserLocation() async {
    if (_requesting) return;
    setState(() => _requesting = true);

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) return;
      }

      final loc = await _location.getLocation();
      setState(() => _userLocation = loc);
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    final target = LatLng(widget.lat, widget.lng);

    final CameraPosition currentPos = CameraPosition(
      bearing: 0.0,
      target: target,
      tilt: 60.0,
      zoom: 17,
    );

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('selected_location'),
        position: target,
        infoWindow: InfoWindow(title: widget.title),
      ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: GoogleMap(
        mapType: MapType.hybrid,
        myLocationEnabled: _userLocation != null, 
        initialCameraPosition: currentPos,
        markers: markers,
        onMapCreated: (GoogleMapController controller) {
          if (!_controller.isCompleted) _controller.complete(controller);
        },
      ),
    );
  }
}
