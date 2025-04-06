import 'package:flutter/material.dart';
import 'package:resq_assist/services/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  final String email;
  const ProfileScreen({super.key, required this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool circular = false;

  String? userEmail;
  var id;
  bool isLoading = true;
  bool isDelayed = true;
  String profilePhoto = "";
  String backStreamPhoto = "";
  String fullName = "Loading...";
  String email = "Loading...";
  int travelPoints = 0;
  int tripBooked = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserData(widget.email).then((data) {
      setState(() {
        profilePhoto = data["profilePhoto"] ?? "";
        backStreamPhoto = data["backStreamPhoto"] ?? "";
        fullName = data["fullName"] ?? "Unknown";
        email = data["email"] ?? "No email";
        travelPoints = (data["travelPoints"] ?? 0).toInt();
        tripBooked = (data["tripBooked"] ?? 0).toInt();
        isLoading = false;
      });
    });
  }

  Future<Map<String, dynamic>> fetchUserData(String email) async {
    var data = await DatabaseHelper.getDataOfUserByEmail(email) ?? {};
    return {
      "profilePhoto": data["profilePhoto"] ?? "",
      "backStreamPhoto": data["backStreamPhoto"] ?? "",
      "fullName": data["fullName"] ?? "Unknown",
      "email": data["email"] ?? "No email",
      "travelPoints": (data["travelPoints"] ?? 0).toInt(),
      "tripBooked": (data["tripBooked"] ?? 0).toInt(),
    };
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: 120,
            left: 30,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=3',
              ),
            ),
          ),
          const Positioned(
            top: 170,
            left: 80,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.black,
              child: Icon(
                Icons.edit,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
           Positioned(
            top: 130,
            left: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fullName}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$email',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 240,
            left: 26,
            child: Container(
              height: 120,
              width: 340,
              decoration: BoxDecoration(
                color: Colors.grey[900], // Dark background
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image(image: AssetImage('assets/images/reward_bg.png'), fit: BoxFit.fill),
            ),
          ),
          Positioned(
              top: 260,
              left: 42,
              child: Text('Your Points', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18,color: Colors.white))),
          Positioned(
              top: 290,
              left: 45,
              child: Text('${travelPoints}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25, color: const Color.fromARGB(255, 179, 226, 255)))),
          Positioned(
              top: 270,
              right: 54,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset('assets/images/coin.png', height: 60),
              )),
        ],
      ),
    );
  }
}
