import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resq_assist/model/user_model.dart';
import 'package:resq_assist/screen/home_screen.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:resq_assist/screen/vehicle_setup_screen.dart';
import 'package:resq_assist/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PersonalDetailsScreen extends StatefulWidget {
  final String username;
  final String email;
  final String contactNo;
  final String password;

  const PersonalDetailsScreen({super.key, required this.username, required this.email, required this.contactNo, required this.password});
  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String gender = 'Male';


  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final contactController = TextEditingController();

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }


  void _onContinue() async {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => VehicleDetailsScreen(username: widget.username,email: widget.email,contactNo: widget.contactNo,password: widget.password,fullName: nameController.text,homeAddress: addressController.text,emergencyContact: contactController.text,gender: gender,)));
      // final encryptedPassword = hashPassword(widget.password);
      //
      // UserModel newUser = UserModel(
      //   username: widget.username,
      //   fullName: nameController.text,
      //   email: widget.email,
      //   contactNo: widget.contactNo,
      //   emergencyContact: contactController.text,
      //   homeAddress: addressController.text,
      //   gender: gender,
      //   password: encryptedPassword,
      // );
      //
      // try {
      //   bool success = await DatabaseHelper.addUser(newUser);
      //
      //   if (success) {
      //     print("🎉 User added to MongoDB successfully!");
      //     await saveLoginState(widget.email);
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => HomeScreen(userEmail: widget.email)),
      //     );
      //   } else {
      //     print("❌ Failed to add user.");
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Failed to save user ❌')),
      //     );
      //   }
      // } catch (e) {
      //   print("❌ Exception during user registration: $e");
      // }
    } else {
      print("⚠️ Form validation failed");
    }
  }


  Future<void> saveLoginState(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email); // store unique user info
  }



  @override
  Widget build(BuildContext context) {
    const Color buttonColor = Color(0xFF1E1E3F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
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
                            color: index == 2 ? Colors.blue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    Text("Next >", style: TextStyle(color: Colors.blue)),
                  ],
                ),

                const SizedBox(height: 32),

                Text("Personal Details", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),

                const SizedBox(height: 24),

                // Profile photo (optional)
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        // backgroundImage: AssetImage('assets/profile_placeholder.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit, size: 18, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: Text("Profile Photo", style: TextStyle(color: Colors.black87))),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 15),
                        child: Text(
                          'Full Name',
                          style: GoogleFonts.getFont(
                            'Open Sans',
                            color: Colors.black,
                            fontSize: 16,
                            // fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        height: 75,
                        child: TextFormField(
                          controller: nameController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),
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
                              fontSize: 12,  // Adjust font size for the error text
                              height: 0.5,   // Reduce the line height to minimize padding
                            ),
                            errorMaxLines: 1,  // Limit error message to a single line
                            isDense: true,
                          ),

                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter your Full Name";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, bottom: 2,),
                        child: Text(
                          'Home Address',
                          style: GoogleFonts.getFont(
                            'Open Sans',
                            color: Colors.black,
                            fontSize: 16,
                            // fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        height: 75,
                        child: TextFormField(
                          controller: addressController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),
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
                              fontSize: 12,  // Adjust font size for the error text
                              height: 0.5,   // Reduce the line height to minimize padding
                            ),
                            errorMaxLines: 1,  // Limit error message to a single line
                            isDense: true,
                          ),

                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter your Home Address";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, bottom: 3, top: 0),
                        child: Text(
                          'Emergency Contact',
                          style: GoogleFonts.getFont(
                            'Open Sans',
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
                          controller: contactController,
                          keyboardType: TextInputType.phone,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 10),
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
                              fontSize: 12, // Adjust font size for the error text
                              height: 0.5, // Reduce the line height to minimize padding
                            ),
                            errorMaxLines: 1,
                            // Limit error message to a single line
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter your phone number";
                            }

                            String pattern = r'^(?:[+0]9)?[0-9]{10}$';
                            RegExp regExp = RegExp(pattern);

                            if (!regExp.hasMatch(value)) {
                              return "Please enter a valid phone number";
                            }

                            return null;
                          },
                        ),
                      ),

                    ],
                                  ),
                ),
                const SizedBox(height: 20),
                buildLabel("Gender"),

                const SizedBox(height: 10),
                Wrap(
                  spacing: 20,
                  children: [
                    buildGenderRadio("Male"),
                    buildGenderRadio("Female"),
                    buildGenderRadio("Other"),
                  ],
                ),

                const SizedBox(height: 40),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      "continue",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget buildValidatedField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF3F6FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildGenderRadio(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: gender,
          onChanged: (val) => setState(() => gender = val!),
        ),
        Text(label),
      ],
    );
  }
}

