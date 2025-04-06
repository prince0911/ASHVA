import 'package:flutter/material.dart';
import 'package:resq_assist/screen/explore_screen.dart';
import 'package:resq_assist/screen/home_screen.dart';
import 'package:resq_assist/screen/profile_screen.dart';


class BottomNavigationScreen extends StatefulWidget {
  final String email;
  final int indexRequest;
  // Accept initial index

  const BottomNavigationScreen({super.key, required this.email, this.indexRequest = 0});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigationScreen> {
  late int currentindex; // Use `late` to initialize in `initState`
  late int indexR; // Use `late` to initialize in `initState`
  late List<Widget> screen;

  void onTap(int index) {
    setState(() {
      currentindex = index;

    });
  }

  @override
  void initState() {
    super.initState();
    currentindex = 0;
    indexR=widget.indexRequest;// Set initial tab index
    screen = [
      HomeScreen(userEmail: widget.email,selectedIndex: indexR,),
      ExploreScreen(email: widget.email,),
      ProfileScreen(email: widget.email,),
    ];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    indexR=0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen[currentindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        onTap: onTap,
        currentIndex: currentindex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.travel_explore_rounded), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
