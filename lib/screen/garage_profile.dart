import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq_assist/screen/book_screen.dart';

class GarageProfileScreen extends StatelessWidget {
  final String garageName;
  final LatLng location;

  GarageProfileScreen({required this.garageName, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(garageName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              garageName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Location: ${location.latitude}, ${location.longitude}",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the booking screen (to be created)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(garageName: garageName),
                  ),
                );
              },
              child: Text("Book Service"),
            ),
          ],
        ),
      ),
    );
  }
}
