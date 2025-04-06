import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resq_assist/screen/bottom_screen.dart';
import 'package:resq_assist/screen/garage_list.dart';
import 'package:resq_assist/screen/home_screen.dart';
import 'package:resq_assist/screen/login_screen.dart';
import 'package:resq_assist/screen/map_screen.dart';

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userEmail;

  const MyApp({super.key, required this.isLoggedIn, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQ Assist',
      debugShowCheckedModeBanner: false,
      home: isLoggedIn && userEmail != null
          ? BottomNavigationScreen(email: userEmail!)
          : LoginScreen(),
    );
  }
}

// MainScreen with Bottom Navigation
// class MainScreen extends StatefulWidget {
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;
//
//   final List<Widget> _pages = [
//     HomeScreen(),
//     GarageListScreen(),
//     MapScreen(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.car_repair), label: "Garages"),
//           BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
//         ],
//       ),
//     );
//   }
// }