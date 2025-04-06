import 'package:flutter/material.dart';
import 'package:resq_assist/screen/history_screen.dart';
import 'package:resq_assist/screen/login_screen.dart';
import 'package:resq_assist/screen/request_help_screen.dart';
import 'package:resq_assist/screen/request_status_screen.dart';
import 'package:resq_assist/screen/segmented_tabbar_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final int selectedIndex;

  const HomeScreen({super.key, required this.userEmail, this.selectedIndex = 0});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentTabIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentTabIndex = widget.selectedIndex;

  }

  final themeColor = const Color(0xFF0F1123);
  @override
  Widget build(BuildContext context) {
    final tabs = [
      RequestHelpScreen(email: widget.userEmail,),
      RequestStatusScreen(email: widget.userEmail,),
      HistoryScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: const Text(
          "ASHVA",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
       actions: [
         Icon(Icons.notifications_none, color: Colors.white), SizedBox(width: 16),
          InkWell(
              onTap: (){
                  logout(context);
              },
              child: Icon(Icons.logout, color: Colors.white)),SizedBox(width: 16)],
      ),
      body: Column(
        children: [
          SegmentedTabBar(
            selectedIndex: currentTabIndex,
            onTabChange: (index) => setState(() => currentTabIndex = index),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: IndexedStack(
                key: ValueKey<int>(currentTabIndex), // ensures switch detection
                index: currentTabIndex,
                children: [
                  RequestHelpScreen(email: widget.userEmail,),
                  RequestStatusScreen(email: widget.userEmail,),
                  HistoryScreen(),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}

