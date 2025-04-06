import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:resq_assist/screen/profile_setup_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phnoOrEmail;  // Explicitly define the type
  final bool isEmail;
  final String sentOtp;
  final String username;
  final String email;
  final String contactNo;
  final String password;


  const VerifyOtpScreen({super.key, required this.phnoOrEmail, required this.isEmail, required this.sentOtp, required this.username, required this.email, required this.contactNo, required this.password});
  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  var otp;
  bool _isResendAvailable = false; // Controls the resend button
  int _countdown = 30; // Set the initial countdown to 30 seconds
  Timer? _timer;
  var sentOtp,newOTP;
  var email;


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

  Future<void> _resendOTP() async {
    String newOtp = generateOTP(6); // Generate a new OTP
    bool isSent = await sendEmail(email, newOtp); // Resend the OTP

    if (isSent) {
      print('New OTP sent to ${email}');
      setState(() {
        sentOtp = newOtp;
        newOTP = newOtp;
        print(sentOtp);// Update the OTP in the state
        // _isResendAvailable = false; // Disable the resend button
        // _countdown = 30; // Reset the countdown
        // startTimer(); // Restart the timer
      });
    } else {
      print('Failed to resend OTP');
    }
  }

  // Function to start the countdown timer
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _isResendAvailable = true; // Enable the resend button when countdown finishes
        });
        timer.cancel();
      }
    });
  }

  void _verifyOTP() {
    print(sentOtp);
    print(otp);

    if (newOTP == otp || sentOtp == otp) {
      print('OTP Verified');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PersonalDetailsScreen(username: widget.username,email: widget.email,contactNo: widget.contactNo,password: widget.password,),));
    } else {
      Get.snackbar("Invalid OTP", "check your OTP on your mail.Please Try Again");
      print('Invalid OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    sentOtp = widget.sentOtp;
    email = widget.phnoOrEmail;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                        color: index == 1 ? Colors.blue : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                Text("Next >", style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 50),
            Text(
              'Verify OTP',
              style: GoogleFonts.getFont(
                'Open Sans',
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the OTP which you have received',
              style: GoogleFonts.getFont(
                'Open Sans',
                fontSize: 14.5,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            OtpTextField(
              numberOfFields: 6,
              fillColor: Colors.black.withOpacity(0.1),
              filled: true,
              keyboardType: TextInputType.number,
              margin: const EdgeInsets.all(8),
              cursorColor: Colors.black,
              focusedBorderColor: Colors.black,
              onSubmit: (code) {
                otp = code;
                if (widget.isEmail) {
                  _verifyOTP();
                  // OTPController.instance.verifyEmailOtp(otp, widget.phnoOrEmail);
                }
                else{
                  // verifyOtp(otp);
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code?",
                  style: GoogleFonts.getFont(
                    'Open Sans',
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: () {
                    if(widget.isEmail) {
                      // if (_isResendAvailable)
                      //   TextButton(
                      //     onPressed: _resendOTP,
                      //     child: Text('Resend OTP'),
                      //   );
                      // else
                      //   Text('Resend OTP in $_countdown seconds');
                      _resendOTP();
                    }else{
                      // resendOtp(widget.phnoOrEmail);
                    }
                  },
                  child: Text(
                    "Resend",
                    style: GoogleFonts.getFont(
                      'Open Sans',
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if(widget.isEmail) {
                    _verifyOTP();
                  }else{
                    // verifyOtp(otp);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Verify',
                  style: GoogleFonts.getFont(
                    'Open Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
