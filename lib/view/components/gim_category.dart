import 'package:flutter/material.dart';

class GimCategory extends StatelessWidget {
  const GimCategory({
    super.key,
    required this.gimCategory,
    required this.colorCode,
  });
  final String gimCategory;
  final int colorCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 24,
      decoration: ShapeDecoration(
        color: Color(colorCode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Center(
        child: Text(
          gimCategory,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            height: 1.0, // Updated to properly center vertically
            letterSpacing: -0.50,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
