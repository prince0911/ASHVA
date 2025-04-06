import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LiveTrackingScreen extends StatefulWidget {
  final String agentId;

  LiveTrackingScreen({required this.agentId});

  @override
  _LiveTrackingScreenState createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  late IO.Socket socket;
  LatLng? agentLocation;
  LatLng? userLocation;
  final MapController _mapController = MapController();
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();
    connectToSocket();
    getUserLocation().then((location) {
      setState(() {
        userLocation = location;
      });

      // ✅ Ensure map fits bounds after user location is set
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fitMapToBounds();
      });
    });
  }

  /// ✅ Fit Map to Show Both User and Agent
  void fitMapToBounds() {
    if (userLocation != null && agentLocation != null && isMapReady) {
      final bounds = LatLngBounds.fromPoints([userLocation!, agentLocation!]);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: EdgeInsets.all(50), // Add padding for better visibility
          ),
        );
      });
    }
  }

  /// ✅ Get User's Current Location
  Future<LatLng> getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  /// ✅ Connect to WebSocket and Receive Agent Location
  void connectToSocket() {
    socket = IO.io("https://39e7-2409-40c1-110d-db-89df-7ec9-c8b7-1872.ngrok-free.app", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });

    socket.onConnect((_) => print("✅ Connected to WebSocket!"));

    socket.on("receive-location", (data) {
      if (data != null && data.containsKey("latitude") && data.containsKey("longitude")) {
        setState(() {
          agentLocation = LatLng(data["latitude"], data["longitude"]);
        });

        // ✅ Adjust map only if it is ready
        if (isMapReady) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(agentLocation!, _mapController.camera.zoom);
            fitMapToBounds(); // Refit map bounds
          });
        }
      } else {
        print("⚠️ Invalid location data received: $data");
      }
    });

    socket.onDisconnect((_) => print("❌ Disconnected from WebSocket! Retrying..."));
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live Tracking")),
      body: agentLocation == null || userLocation == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: userLocation ?? LatLng(0, 0),
          initialZoom: 16,
          onMapReady: () {
            setState(() => isMapReady = true); // ✅ Mark map as ready
          },
        ),
        children: [
          /// ✅ Map Tile
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),

          /// ✅ Polyline (Route Line from User to Agent)
          if (userLocation != null && agentLocation != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [userLocation!, agentLocation!],
                  color: Colors.blue,
                  strokeWidth: 5.0,
                ),
              ],
            ),

          /// ✅ Markers (User & Agent)
          MarkerLayer(
            markers: [
              if (userLocation != null)
                Marker(
                  point: userLocation!,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                ),
              if (agentLocation != null)
                Marker(
                  point: agentLocation!,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.directions_car, color: Colors.red, size: 40),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
