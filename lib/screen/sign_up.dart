import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resq_assist/screen/login_screen.dart';
import 'package:resq_assist/screen/otp_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math';


class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();



  final Color fieldFill = const Color(0xFFF3F6FB);

  final Color buttonColor = const Color(0xFF1E1E3F);

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Define the regular expression for a valid email
    final emailRegExp = RegExp( r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }
  String? otp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Top bar (Back, Progress, Next)
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
                          color: index == 0 ? Colors.blue : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  Text("Next >", style: TextStyle(color: Colors.blue)),
                ],
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                "Create Account",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.black87),
              ),

              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 15),
                      child: Text(
                        'Username',
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
                        controller: _usernameController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),
                          suffixIcon: Icon(Icons.person,size: 25,),
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
                            return "Please enter your username";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 5, top: 0),
                      child: Text(
                        'Email',
                        style: GoogleFonts.getFont(
                          'Open Sans',
                          color: Colors.black,
                          fontSize: 16,
                          // fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Email field
                    Container(
                      height: 75,
                      child: TextFormField(
                        controller: _emailController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),
                          suffixIcon: Icon(Icons.email,size: 25,),
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
                        validator: emailValidator,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 3, top: 0),
                      child: Text(
                        'Contact Number',
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
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 10),
                          suffixIcon: Icon(Icons.phone, size: 25,),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 5, top: 0),
                      child: Text(
                        'Password',
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
                        controller: _passwordController,
                        obscureText: true,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),
                          suffixIcon: Icon(Icons.key,size: 25,),
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
                          if (value!.length < 8) {
                            return "Please enter a password with at least 8 characters";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 5, top: 0),
                      child: Text(
                        'Confirm Password',
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
                        controller: _confirmPasswordController,
                        obscureText: true,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),
                          suffixIcon: Icon(Icons.key,size: 25,),
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
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 40),

              // Continue button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: buttonColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 6),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      sendEmailOTP(context);
                    }
                  },

                  child: Text(
                    "continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("have an account?", style: TextStyle(color: Colors.black54)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                    },
                    child: Text("Login", style: TextStyle(color: Colors.lightBlue)),
                  )
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendEmailOTP(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
       otp = generateOTP(6);
      bool result = await sendEmail(email,otp!);

      if (result) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(
              sentOtp: otp!,
              phnoOrEmail: _emailController.text,
              isEmail: true,
              username: _usernameController.text,
              email: _emailController.text,
              contactNo: _phoneController.text,
              password: _passwordController.text,
            ),
          ),
        );
      } else {
        Get.snackbar("Error", "Failed to send OTP. Please try again.");
      }
    }
  }

  String generateOTP(int length) {
    const chars = '1234567890';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<bool> sendEmail(String email, String otp) async{
    var url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    const serviceId = "service_h7gsh5q";
    const templateId = "template_4k7026c";
    const userId = "cZ-Kw9dJB-Pc41K83";
    const subject = "Your OTP";
    var message = "Your OTP is $otp";
    try {
      var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          "service_id": serviceId,
          "template_id": templateId,
          "user_id": userId,
          "template_params": {
            "subject": subject,
            "message": message,
            "user_email": email,
          }
        }),
      );
      print('email sent successfully');
      return true;
    }catch(e){
      print('ERROR FOUND :- ${e.toString()}');
      return false;
    }

  }

}

