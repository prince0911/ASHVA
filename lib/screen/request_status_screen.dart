import 'dart:async';
import 'package:flutter/material.dart';
import 'package:resq_assist/services/database_helper.dart';

class RequestStatusScreen extends StatefulWidget {
  final String email;
  RequestStatusScreen({required this.email});

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
  String? status;
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchBookingStatus();
    // Start auto-refresh every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchBookingStatus();
    });
  }

  Future<void> fetchBookingStatus() async {
    final bookings = await DatabaseHelper.getBookingsByUserId(widget.email);
    if (bookings.isNotEmpty) {
      setState(() {
        status = bookings.last['status']; // assuming latest booking
        isLoading = false;
      });
    } else {
      setState(() {
        status = null;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when screen is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchBookingStatus,
      child: isLoading
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        ],
      )
          : ListView(
        padding: EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 16),
          CircleAvatar(
            radius: 30,
            backgroundColor: status == 'accepted'
                ? Colors.green.shade100
                : Colors.red.shade100,
            child: Icon(
              status == 'accepted' ? Icons.check : Icons.error,
              color: status == 'accepted' ? Colors.green : Colors.red,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            status == 'accepted'
                ? "Help Is On The Way !"
                : "Waiting For Request Acceptance !",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          if (status != 'accepted')
            Text(
              "Your request has been sent to Service Provider. Waiting for response",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
