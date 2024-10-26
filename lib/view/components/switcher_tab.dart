import 'package:flutter/material.dart';

class SwitcherTab extends StatelessWidget {
  const SwitcherTab(
      {super.key, required this.leftTabName, required this.rightTabName});
  final String leftTabName;
  final String rightTabName;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(40.0),
      child: Container(
        color: Colors.white,
        child: TabBar(
          indicatorColor: const Color(0xFF0056FF),
          labelColor: const Color(0xFF0056FF),
          unselectedLabelColor: Colors.black,
          labelStyle: const TextStyle(
            fontSize: 20,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: leftTabName),
            Tab(text: rightTabName),
          ],
        ),
      ),
    );
  }
}
