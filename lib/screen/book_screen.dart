import 'package:flutter/material.dart';
import 'package:resq_assist/screen/live_tracking.dart';

class BookingScreen extends StatefulWidget {
  final String garageName;

  BookingScreen({required this.garageName});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedService;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final List<String> services = [
    "Oil Change",
    "Brake Repair",
    "Car Wash",
    "Battery Replacement",
    "Tire Rotation"
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking Confirmed at ${widget.garageName}")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveTrackingScreen(agentId: "A1"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Service at ${widget.garageName}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Your Name"),
                validator: (value) => value!.trim().isEmpty ? "Enter your name" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.trim().isEmpty) return "Enter phone number";
                  if (value.length < 10) return "Enter a valid phone number";
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedService,
                decoration: InputDecoration(
                  labelText: "Select Service",
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  border: OutlineInputBorder(),
                ),
                items: services.map((service) {
                  return DropdownMenuItem(value: service, child: Text(service));
                }).toList(),
                onChanged: (value) => setState(() => _selectedService = value),
                validator: (value) => value == null ? "Select a service" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitBooking,
                child: Text("Confirm Booking"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
