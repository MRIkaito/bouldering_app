import 'package:flutter/material.dart';

class SettingItem extends StatelessWidget{
  final String text;
  const SettingItem({Key? key, required this.text}): super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 352,
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                height: 0.05
              ),
            ),
          ),
          Transform(
            transform: Matrix4.identity()..rotateZ(3.14),
            child: const Text(
              '<',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.w600,
                height: 0.07,
                letterSpacing: -0.50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}