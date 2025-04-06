import 'package:flutter/material.dart';
import 'package:resq_assist/screen/garage_details_screen.dart';

class GarageListScreen extends StatelessWidget {
  final List<String> garages = ["FastFix Garage", "AutoCare Center", "Speedy Repairs"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Garages")),
      body: ListView.builder(
        itemCount: garages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(garages[index]),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GarageDetailScreen(garageName: garages[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}