import 'package:flutter/material.dart';

class SettingItem extends StatelessWidget {
  final String text;
  const SettingItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
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
                  height: 0.05),
            ),
          ),
          Transform(
            transform: Matrix4.identity()..rotateZ(0),
            child: const Text(
              '>',
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
