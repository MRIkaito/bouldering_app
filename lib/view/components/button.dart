import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button(
      {super.key,
      required this.buttonName,
      this.buttonHeight = 48,
      this.onPressedFunction,
      this.colorCode = 0xFF0056FF});
  final String buttonName;
  final double buttonHeight;
  final int colorCode;
  final Function? onPressedFunction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed:
            (onPressedFunction == null) ? null : () => onPressedFunction!(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(colorCode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          buttonName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
