import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:resq_assist/screen/bottom_screen.dart';
import 'package:resq_assist/screen/home_screen.dart';
import 'package:resq_assist/screen/payment_screen.dart';
import 'package:resq_assist/screen/request_status_screen.dart';
import 'dart:developer';
import 'package:intl/intl.dart';

import 'package:resq_assist/services/database_helper.dart';

class RequestDetailsScreen extends StatefulWidget {
  final String email;
  final String providerEmail;
  final String serviceName;
  final int minPrice;
  final int maxPrice;
  const RequestDetailsScreen({Key? key, required this.email, required this.serviceName, required this.minPrice, required this.maxPrice, required this.providerEmail}) : super(key: key);

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _locationController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _issueDescriptionController = TextEditingController();

  var id;
  var userName;
  var email;
  var contactNo;
  var password;
  var fullName;
  var homeAddress;
  var dateOfBirth;
  var vehicleType;
  var vehicleModel;
  var numberPlate;
  int? selectedVehicleIndex;

  String selectedVehicle = 'Default'; // Tracks selected vehicle option
  String selectedVehicleType = "Car";
  String? selectedVehicleNumberPlate = '';

  final TextEditingController modelController = TextEditingController();
  final TextEditingController numberPlateController = TextEditingController();

  final themeColor = const Color(0xFF0F1123);
  String? _selectedVal;
  double? lat;
  double? long;
  var address;
  bool isDataLoaded = false;
  bool isVehicleFetch = false;

  List<String> vehicleTypeList = [
    "Car",
    "Motorcycle",
    "Truck",
    "Bus",
    "Bicycle",
    "Tractor"
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserData(widget.email!);
  }
  List<Map<String, String>> vehicles = [
    // {
    //   'type': 'Motorcycle',
    //   'model': 'Default',
    //   'numberPlate': 'ABC123',
    //   'image': 'assets/images/motorcycle.png' // Placeholder image path
    // }
  ];

  final Map<String, String> vehicleImages = {
    'Car': 'assets/images/car.png', // Replace with actual image paths
    'Motorcycle': 'assets/images/motorcycle.png',
    'Truck': 'assets/images/truck2.png',
    'Bus': 'assets/images/bus.png',
    'Bicycle': 'assets/images/bicycle.png',
    'Tractor': 'assets/images/tractor.png',
  };

  String getCurrentDate() {
    DateTime now = DateTime.now();
    return DateFormat('dd-MM-yyyy').format(now);
  }

  // Method to get current time in hh:mm:ss format
  String getCurrentTime() {
    DateTime now = DateTime.now();
    return DateFormat('HH:mm:ss').format(now); // 24-hour format
  }

  void fetchUserData(String user) async {
    // Fetch the user data based on email
    var userData = await DatabaseHelper.getDataOfUserByEmail(user);

    print(userData);


    // If user data is found, initialize variables
    if (userData != null) {
      setState(() {
        id = userData['_id'];
        userName = userData['username'];
        email = userData['email'];
        contactNo = userData['contactNo'];
        password = userData['password'];
        fullName = userData['fullName'];
        homeAddress = userData['address'];
        dateOfBirth = userData['dateOfBirth'];
        vehicleType = userData['vehicleType'];
        vehicleModel = userData['vehicleModel'];
        numberPlate = userData['numberPlate'];
        selectedVehicle = vehicleModel;
        selectedVehicleType = vehicleType;
        selectedVehicleNumberPlate = numberPlate;
        isDataLoaded = true; // Set flag to true when data is loaded
      });
      if (vehicleType != null && vehicleModel != null && numberPlate != null && vehicleImages.isNotEmpty) {
        initializeVehicles();
      } else {
        // Handle the case when values are not ready
        print('Vehicle details are not fully initialized yet.');
      }
    } else {
      print("User not found");
    }
  }

  void initializeVehicles() {
    setState(() {
      vehicles.add({
        'type': vehicleType!,
        'model': vehicleModel!,
        'numberPlate': numberPlate!,
        'image': vehicleImages[vehicleType]!
      });
      isVehicleFetch = true;
    });

  }

  void selectVehicle(String vehicleModel) {
    setState(() {
      selectedVehicle = vehicleModel;
    });
  }
  Future<void>showAddVehicleDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Vehicle'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: selectedVehicleType,
                  items: vehicleImages.keys.map((String vehicleType) {
                    return DropdownMenuItem<String>(
                      value: vehicleType,
                      child: Text(vehicleType),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedVehicleType = newValue!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Vehicle Type'),
                ),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: 'Vehicle Model'),
                ),
                TextField(
                  controller: numberPlateController,
                  decoration: const InputDecoration(labelText: 'Number Plate'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                if (modelController.text.isNotEmpty && numberPlateController.text.isNotEmpty) {
                  addVehicle(
                    selectedVehicleType,
                    modelController.text,
                    numberPlateController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void addVehicle(String vehicleType, String vehicleModel, String numberPlate) {
    setState(() {
      vehicles.add({
        'type': vehicleType,
        'model': vehicleModel,
        'numberPlate': numberPlate,
        'image': vehicleImages[vehicleType]!,
        // Select image based on vehicle type
      });
    });
  }

  Widget buildAddVehicleOption() {
    return InkWell(
      onTap: () {
        showAddVehicleDialog(context);
      },
      child: Container(
        height: 120,
        width: 120,
        // Fixed width for Add Vehicle container
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFFFFFFF),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Icon(
              Icons.add,
              size: 50,
              color: const Color(0xFF979393),
            ),
            const SizedBox(height: 5),
            Text(
              'Add Vehicle',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF979393),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVehicleOption(
      String type, String model, String numberPlate, String image) {
    final isSelected = selectedVehicle == model;
    return InkWell(
      onTap: () {
        selectVehicle(model);
        selectedVehicleIndex = vehicles.indexWhere((vehicle) => vehicle['model'] == model);
        selectedVehicleType = type;
        selectedVehicle = model;
        selectedVehicleNumberPlate = numberPlate;
      },
      child: Container(
        width: 120,
        height: 120,
        // Fixed width for vehicle containers
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          border: Border.all (
              color: isSelected
                  ? const Color(0xFF000000)
                  : const Color(0xFFE0E0E0)), // Light grey if not selected
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? const Color(0xFFEEEEEE)
              : const Color(0xFFEEEEEE), // Light grey if not selected
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF000000),
              ),
            ),
            Text(
              model,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: const Color(0xFF000000),
              ),
            ),
            Text(
              numberPlate,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: const Color(0xFF000000),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      _locationController.text = address;
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
    if (!isDataLoaded && !isVehicleFetch) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: const Text(
          "ASHVA",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Icon(Icons.notifications_none_outlined),
          SizedBox(width: 16),
          Icon(Icons.person_outline),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              const SizedBox(height: 24),


               Text("Service Details : ${widget.serviceName}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 40),

              // Vehicle Number
              const Text("Enter Location*"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      maxLines: 2,
                      style: TextStyle(fontSize: 13),
                      decoration: InputDecoration(

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

                        _locationController.text = address;

                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 17), // Button padding
                    ),
                    child: Icon(Icons.location_on_rounded,size: 36,),
                  ),
                ],
              ),


              const SizedBox(height: 16),

              const Text("Select Your Vehicle*"),
              const SizedBox(height: 12),
              // Horizontal Scrollable Container for Vehicles
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vehicles.length + 1,
                  // Add 1 for the "Add Vehicle" option
                  itemBuilder: (context, index) {
                    if (index < vehicles.length) {
                      return buildVehicleOption(
                        vehicles[index]['type']!,
                        vehicles[index]['model']!,
                        vehicles[index]['numberPlate']!,
                        vehicles[index]['image']!,
                      );
                    } else {
                      return buildAddVehicleOption();
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Issue Description
              const Text("Issue Description"),
              const SizedBox(height: 12),
              TextFormField(
                controller: _issueDescriptionController,
                maxLines: 4,
                decoration: _inputDecoration("Describe the issue"),
              ),

              const SizedBox(height: 152),
              // Confirm Button
              ElevatedButton(
                onPressed: () async{
                  if (_locationController.text!="") {

                    _showPriceSelectionDialog(context, widget.minPrice.toDouble(), widget.maxPrice.toDouble());



                    // bool success = await DatabaseHelper.bookUser(
                    //     id,
                    //     fullName,
                    //     email,
                    //     contactNo,
                    //     address,
                    //     widget.serviceName,
                    //     selectedVehicleType,
                    //     selectedVehicle,
                    //     selectedVehicleNumberPlate!,
                    //     "550",
                    //     getCurrentDate(),
                    //     getCurrentTime(),
                    // "pending");
                    // // Handle submission logic
                    //
                    // if(success){
                    //   Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(uid: id, email: email, serviceName: widget.serviceName, bookDate: getCurrentDate(), fullName: fullName, address: address, vehicleModel: vehicleModel, numberPlate: numberPlate, vehicleType: vehicleType,  paymentDate: getCurrentDate(), bookTime: getCurrentTime(),contactNo: contactNo,),));
                    // }
                 }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please Set Location '),backgroundColor: Colors.red,));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Confirm Service",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPriceSelectionDialog(BuildContext context, double minPrice, double maxPrice) {
    double selectedPrice = minPrice;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Your Price'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select a price between ₹${minPrice.toInt()} and ₹${maxPrice.toInt()}'),
              SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Slider(
                        value: selectedPrice,
                        min: minPrice,
                        max: maxPrice,
                        divisions: (maxPrice - minPrice).toInt(),
                        label: '₹${selectedPrice.toInt()}',
                        onChanged: (value) {
                          setState(() {
                            selectedPrice = value;
                          });
                        },
                      ),
                      Text('Selected: ₹${selectedPrice.toInt()}'),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                bool success = await DatabaseHelper.bookUser(
                    id,
                    fullName,
                    email,
                    widget.providerEmail,
                    contactNo,
                    address,
                    widget.serviceName,
                    selectedVehicleType,
                    selectedVehicle,
                    selectedVehicleNumberPlate!,
                    selectedPrice.toString(),
                    getCurrentDate(),
                    getCurrentTime(),
                "pending");
                // Handle submission logic

                if(success){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigationScreen(email: email,indexRequest: 1,)));// Close the dialog

                }
                // Use the selectedPrice value as needed
                print('User selected price: ₹${selectedPrice.toInt()}');
                // You can call your API here or pass selectedPrice to another function
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }


  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
