import 'package:flutter/material.dart';
import 'package:resq_assist/model/user_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resq_assist/model/user_model.dart';
import 'package:resq_assist/screen/bottom_screen.dart';
import 'package:resq_assist/screen/home_screen.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:resq_assist/screen/vehicle_setup_screen.dart';
import 'package:resq_assist/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final String username;
  final String email;
  final String contactNo;
  final String password;
  final String fullName;
  final String homeAddress;
  final String emergencyContact;
  final String gender;

  const VehicleDetailsScreen({
    super.key,
    required this.username,
    required this.email,
    required this.contactNo,
    required this.password,
    required this.fullName,
    required this.homeAddress,
    required this.emergencyContact,
    required this.gender,
  });

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final TextEditingController typeController = TextEditingController();

  final TextEditingController modelController = TextEditingController();

  final TextEditingController plateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    typeController.dispose();
    modelController.dispose();
    plateController.dispose();
    super.dispose();
  }


  List<String> vehicleTypeList = [
    "Car",
    "Motorcycle",
    "Truck",
    "Bus",
    "Bicycle",
    "Tractor",
  ];
  String? _selectedVal;

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> saveLoginState(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email); // store unique user info
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("< Back", style: TextStyle(color: Colors.blue)),
                    Row(
                      children: List.generate(4, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 30,
                          height: 6,
                          decoration: BoxDecoration(
                            color:
                                index == 3 ? Colors.blue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    Text("Next >", style: TextStyle(color: Colors.blue)),
                  ],
                ),
                SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F1123),
                        ),
                      ),
                      SizedBox(height: 52),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, bottom: 3),
                        child: Text(
                          'Vehicle Type',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            // fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        child: DropdownButtonFormField<String>(
                          value: _selectedVal,
                          items: vehicleTypeList.map((String e) {
                            return DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedVal = value;
                              typeController.text = value ?? ''; // Set the controller text when user selects
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 2.0,
                          bottom: 3,
                          top: 15,
                        ),
                        child: Text(
                          'Vehicle Model',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            // fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        child: TextFormField(
                          controller: modelController,
                          keyboardType: TextInputType.text,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorStyle: TextStyle(
                              fontSize:
                                  12, // Adjust font size for the error text
                              height:
                                  0.5, // Reduce the line height to minimize padding
                            ),
                            errorMaxLines: 1,
                            // Limit error message to a single line
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter your Vehicle Model";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, bottom: 3),
                        child: Text(
                          'Number Plate',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            // fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        child: TextFormField(
                          controller: plateController,
                          keyboardType: TextInputType.text,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorStyle: TextStyle(
                              fontSize:
                                  11, // Adjust font size for the error text
                              height:
                                  0.5, // Reduce the line height to minimize padding
                            ),
                            errorMaxLines: 1,
                            // Limit error message to a single line
                            isDense: true,
                          ),
                          validator: (value) {
                            String pattern =
                                r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$';
                            RegExp regExp = RegExp(pattern);

                            if (value == null || value.isEmpty) {
                              return 'Please enter the number plate';
                            } else if (!regExp.hasMatch(value)) {
                              return 'Please enter a valid Indian number plate (e.g., MH12AB1234)';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 260),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final encryptedPassword = hashPassword(widget.password);

                        UserModel newUser = UserModel(
                          username: widget.username,
                          fullName: widget.fullName,
                          email: widget.email,
                          contactNo: widget.contactNo,
                          emergencyContact: widget.emergencyContact,
                          homeAddress: widget.homeAddress,
                          gender: widget.gender,
                          password: encryptedPassword,
                          vehicleType: typeController.text,
                          vehicleModel: modelController.text,
                          numberPlate: plateController.text,
                          travelPoints: 1000
                        );

                        try {
                          bool success = await DatabaseHelper.addUser(newUser);

                          if (success) {
                            print("🎉 User added to MongoDB successfully!");
                            await saveLoginState(widget.email);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                    BottomNavigationScreen(email: widget.email),
                              ),
                            );
                          } else {
                            print("❌ Failed to add user.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to save user ❌')),
                            );
                          }
                        } catch (e) {
                          print("❌ Exception during user registration: $e");
                        }}
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0F1123),
                      padding: EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                      shadowColor: Colors.black26,
                    ),
                    child: Text(
                      'continue',
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        fillColor: Color(0xFFF1F6FB),
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: Colors.black87),
    );
  }
}
