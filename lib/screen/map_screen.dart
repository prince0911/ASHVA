import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resq_assist/screen/garage_profile.dart';
import 'dart:math';
// Import the garage profile screen

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng _currentPosition = LatLng(21.1702, 72.8311); // Surat default location
  List<Map<String, dynamic>> _nearestGarages = [];

  // List of garages with names and locations
  final List<Map<String, dynamic>> _suratGarages = [
    {"name": "FastFix Garage", "location": LatLng(21.1885, 72.8293)},
    {"name": "AutoCare Center", "location": LatLng(21.1625, 72.8369)},
    {"name": "Speedy Repairs", "location": LatLng(21.1750, 72.8315)},
    {"name": "Elite Auto Works", "location": LatLng(21.1670, 72.8390)},
    {"name": "Surat Auto Hub", "location": LatLng(21.1800, 72.8400)},
    {"name": "City Car Clinic", "location": LatLng(21.1900, 72.8410)},
    {"name": "Express AutoFix", "location": LatLng(21.1550, 72.8250)},
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _findNearestGarages();
      _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission denied")),
      );
    }
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double R = 6371;
    double lat1 = point1.latitude * pi / 180;
    double lon1 = point1.longitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;
    double lon2 = point2.longitude * pi / 180;
    double dlat = lat2 - lat1;
    double dlon = lon2 - lon1;

    double a = pow(sin(dlat / 2), 2) +
        cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  void _findNearestGarages() {
    List<Map<String, dynamic>> distances = _suratGarages.map((garage) {
      return {
        "name": garage["name"],
        "location": garage["location"],
        "distance": _calculateDistance(_currentPosition, garage["location"]),
      };
    }).toList();

    distances.sort((a, b) => a["distance"].compareTo(b["distance"]));

    setState(() {
      _nearestGarages = distances.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Garages in Surat")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 14),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        markers: {
          ..._nearestGarages.map((garage) => Marker(
            markerId: MarkerId(garage["name"]),
            position: garage["location"],
            infoWindow: InfoWindow(
              title: garage["name"],
              snippet: "Tap to view details",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GarageProfileScreen(
                      garageName: garage["name"],
                      location: garage["location"],
                    ),
                  ),
                );
              },
            ),
          )),
        },
        myLocationEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: _getUserLocation,
      ),
    );
  }
}
