import 'package:flutter/material.dart';
import 'package:resq_assist/screen/bottom_navigation.dart';
import 'package:resq_assist/screen/login_screen.dart';
import 'package:resq_assist/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Connect to MongoDB
  await DatabaseHelper.connect();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? userEmail = prefs.getString('userEmail');

  runApp(MyAppDemo(isLoggedIn: isLoggedIn,userEmail: userEmail!,));
}

class MyAppDemo extends StatefulWidget {
  final bool isLoggedIn;
  final String userEmail;

  const MyAppDemo({super.key, required this.isLoggedIn, required this.userEmail});
  @override
  State<MyAppDemo> createState() => _MyAppDemoState();
}

class _MyAppDemoState extends State<MyAppDemo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashVideoScreen(userEmail: widget.userEmail,isLoggedIn: widget.isLoggedIn,),
    );
  }
}

class SplashVideoScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String userEmail;

  const SplashVideoScreen({super.key, required this.isLoggedIn, required this.userEmail});
  @override
  _SplashVideoScreenState createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      print("Initializing video...");
      _controller = VideoPlayerController.asset('assets/splash_video.mp4')
        ..initialize().then((_) {
          print("Video initialized successfully!");
          if (mounted) {
            setState(() {});
            _controller.play();
            _controller.setLooping(false);
            _controller.addListener(() {
              if (_controller.value.position >= _controller.value.duration) {
                print("Video ended, navigating to HomeScreen");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp(isLoggedIn: widget.isLoggedIn, userEmail: widget.
                  userEmail)),
                );
              }
            });
          }
        }).catchError((e) {
          print("Video initialization error: $e");
          setState(() {
            _hasError = true;
          });
        });
    } catch (e) {
      print("Error in _initializeVideo: $e");
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Error loading video',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}