import 'package:flutter/material.dart';

class SpeedWidget extends StatelessWidget {
  const SpeedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 67,
      height: 24,
      child: Stack(
          children: [
              Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                      width: 67,
                      height: 24,
                      decoration: ShapeDecoration(
                          color: Color(0xFFFFA115),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                          ),
                      ),
                  ),
              ),
              const Positioned(
                  left: 9,
                  top: 4,
                  child: SizedBox(
                      width: 47,
                      height: 16,
                      child: Text(
                          'キッズ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              height: 0.06,
                              letterSpacing: -0.50,
                          ),
                      ),
                  ),
              ),
          ],
      ),
    );
  }
}