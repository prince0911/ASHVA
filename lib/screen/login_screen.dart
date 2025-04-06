import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resq_assist/screen/bottom_screen.dart';
import 'package:resq_assist/screen/home_screen.dart';
import 'package:resq_assist/screen/sign_up.dart';
import 'package:resq_assist/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Define the regular expression for a valid email
    final emailRegExp = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\s?$'
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Welcome header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Welcome Back ",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Icon(
                              Icons.local_shipping,
                              size: 28,
                              color: Colors.deepOrange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 2.0, bottom: 5, top: 15),
                                  child: Text(
                                    'Email',
                                    style: GoogleFonts.getFont(
                                      'Open Sans',
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 75,
                                  child: TextFormField(
                                    controller: _emailController,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                      suffixIcon: Icon(Icons.person),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    validator: emailValidator,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.only(left: 2, bottom: 5),
                                  child: Text(
                                    'Password',
                                    style: GoogleFonts.getFont(
                                      'Open Sans',
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 75,
                                  child: TextFormField(
                                    controller: _passwordController,
                                    cursorColor: Colors.black,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      suffixIcon: Icon(Icons.key),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      } else if (value.length < 8) {
                                        return 'Password must be at least 8 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() => rememberMe = value ?? false);
                              },
                            ),
                            const Text("Remember me"),
                            Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null) ...[
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              'invalid username or password. Please try again',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                              });

                              try {
                                final email = _emailController.text.trim();
                                final password = _passwordController.text;

                                final user = await DatabaseHelper.loginUser(email, password);

                                if (user != null) {
                                  // Save login status to SharedPreferences
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool('isLoggedIn', true);
                                  await prefs.setString('userEmail', email);

                                  // Navigate to Home or BottomNavigation
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BottomNavigationScreen(email: email),
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    _errorMessage = "Invalid username or password";
                                  });
                                }
                              } catch (e) {
                                setState(() {
                                  _errorMessage = "Something went wrong. Try again later.";
                                });
                                print("Login error: $e");
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C2C4F),
                            elevation: 4,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Continue",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                "or login with",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            socialButton(FontAwesomeIcons.google, () {}),
                            socialButton(FontAwesomeIcons.facebookF, () {}),
                            socialButton(FontAwesomeIcons.bolt, () {}),
                          ],
                        ),
                        const SizedBox(height: 40),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don’t have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(color: Colors.lightBlue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget socialButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Center(child: FaIcon(icon, size: 20)),
      ),
    );
  }
}
