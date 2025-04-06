import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:resq_assist/screen/request_details_screen.dart';
import 'package:resq_assist/services/database_helper.dart';

class RequestHelpScreen extends StatefulWidget {
  final String email;

  const RequestHelpScreen({super.key, required this.email});

  @override
  State<RequestHelpScreen> createState() => _RequestHelpScreenState();
}

class _RequestHelpScreenState extends State<RequestHelpScreen> {
  double? lat;
  double? long;
  var address;
  String? selectedService;
  List<Map<String, dynamic>> providers = [];
  bool isLoading = false;


  final locationController = TextEditingController();


  getLatLong() {
    Future<Position> data = getCurrentLocation();
    data.then((value) {
      print("$value");
      setState(() {
        lat = value.latitude;
        long = value.longitude;
      });
      getAddress(lat, long);
    }).catchError((onError) {
      print("Error $onError");
    });
  }
  getAddress(lat, long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    setState(() {
      address = placemarks[0].street! + " , " + placemarks[4]. name! + " , " + placemarks[0].subLocality! + " , " + placemarks[0].locality! + " , " + placemarks[0].administrativeArea! + " - " + placemarks[0].postalCode!;
      locationController.text = address;
    });
    for (int i = 0; i < placemarks.length; i++) {
      print("INDEX $i ${placemarks[i]}");
    }
  }
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showLocationServicesDisabledDialog(context);
      // Location services are not enabled, show a message to the user
      return Future.error('Location services are disabled. Please enable them in your device settings.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are denied. Please allow location access in your app settings.');
      }
    }

    // If permissions are granted, get the current position
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      log("latitude = ${currentPosition.latitude}");
      log("longitude = ${currentPosition.longitude}");
      return currentPosition;
    } catch (e) {
      return Future.error('Error getting current location: $e');
    }
  }
  void showLocationServicesDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Please enable location services in your device settings.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                      hintText: "Enter Your Location",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    getLatLong();
                    setState(() {
        
                        locationController.text = address;
        
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16), // Button padding
                  ),
                  child: Icon(Icons.explore_outlined,size: 20,),
                ),
                SizedBox(width: 12),// Space between text field & button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Button padding
                  ),
                  child: Text("Set", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
        
            SizedBox(height: 20),
            Text("What Assistance Do You Need ?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  serviceCard(Icons.build, "Mechanic", "On-The-Spot Repairs"),
                  serviceCard(Icons.local_shipping, "Tow-Truck", "Vehicle Transportation"),
                  serviceCard(Icons.local_gas_station, "Fuel Transportation", "On-The-Spot Repairs"),
                  serviceCard(Icons.people, "Nearby Users", "Ask For Help"),
                ],
              ),
            ),

            SizedBox(height: 20),
            if (selectedService != null) ...[
              SizedBox(height: 16),
              Text("Available $selectedService Providers",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : providers.isEmpty
                  ? Text("No providers found.")
                  : ListView.builder(
                itemCount: providers.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return providerCard(providers[index]);
                },
              ),
            ],
        
          ],
          
        ),
      ),
    );
  }

  Widget serviceCard(IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedService = title;
          isLoading = true;
          providers = [];
        });

        final result = await DatabaseHelper.getProvidersByCategory(title); // Replace with your backend function
        setState(() {
          providers = result;
          print(providers);
          isLoading = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 32),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget providerCard(Map<String, dynamic> provider) {
    // Get first service (we assume one service per provider for now)
    final service = (provider['services'] as List).isNotEmpty
        ? provider['services'][0]
        : {};
    String pEmail = provider["email"];
    String name = provider["provider_name"] ?? "No Name";
    String distance = service["distance"] ?? "Unknown";
    String eta = service["eta"] ?? "--";
    int minPrice = service["minprice"] ?? "₹0";
    int maxPrice = service["maxprice"] ?? "₹0";
    double rating = (service["rating"] ?? 0).toDouble();
    List categories = service["category"] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundColor: Colors.grey[300]),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text("$rating", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text("Available", style: TextStyle(color: Colors.green)),
                      ),
                      SizedBox(width: 50,),
                      Text('₹ ${minPrice} - $maxPrice',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16),
              SizedBox(width: 4),
              Text(distance),
              SizedBox(width: 12),
              Icon(Icons.access_time, size: 16),
              SizedBox(width: 4),
              Text("ETA: $eta"),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: categories
                .map<Widget>((s) => Chip(
              label: Text(s),
              backgroundColor: Colors.grey[200],
              shape: StadiumBorder(),
            ))
                .toList(),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.phone, color: Colors.black),
                label: Text("Contact", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RequestDetailsScreen(email: widget.email,serviceName: selectedService!,minPrice: minPrice,maxPrice: maxPrice,providerEmail: pEmail,),));
                },
                child: Text("Request"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



}