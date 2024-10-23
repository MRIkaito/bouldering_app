import 'package:flutter/material.dart';

class SpeedWidget extends StatelessWidget {
  const SpeedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 69,
        height: 24,
        child: Stack(
            children: [
                Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                        width: 65,
                        height: 24,
                        decoration: ShapeDecoration(
                            color: Color(0xFF03B300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                            ),
                        ),
                    ),
                ),
                Positioned(
                    left: 8,
                    top: 0,
                    child: SizedBox(
                        width: 50,
                        height: 24,
                        child: Text(
                            'リード',
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