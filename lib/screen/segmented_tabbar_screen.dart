import 'package:flutter/material.dart';

class SegmentedTabBar extends StatefulWidget {
  final Function(int) onTabChange;
  final int selectedIndex;

  const SegmentedTabBar({super.key, required this.onTabChange, required this.selectedIndex});

  @override
  State<SegmentedTabBar> createState() => _SegmentedTabBarState();
}

class _SegmentedTabBarState extends State<SegmentedTabBar> {
  final List<String> tabs = ["Request Help", "Request Status", "History"];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFF1F6FB), // light blue background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          final isSelected = widget.selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onTabChange(index),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
