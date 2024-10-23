import 'package:flutter/material.dart';

class SpeedWidget extends StatelessWidget {
  const SpeedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 96,
        height: 24,
        child: Stack(
            children: [
                Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                        width: 110,
                        height: 24,
                        decoration: ShapeDecoration(
                            color: Color(0xFFFF0F00),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                            ),
                        ),
                    ),
                ),
                const Positioned(
                    left: 7,
                    top: 3,
                    child: SizedBox(
                        width: 95,
                        height: 18,
                        child: Text(
                            'ボルダリング',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                height: 0.05,
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