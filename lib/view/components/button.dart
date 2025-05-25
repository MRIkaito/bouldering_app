import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.buttonName,
    this.buttonWidth = double.infinity,
    this.buttonHeight = 48,
    this.buttonTextColorCode = 0xFFFFFFFF,
    this.buttonColorCode = 0xFF0056FF,
    this.onPressedFunction,
  });
  final String buttonName;
  final double buttonWidth;
  final double buttonHeight;
  final int buttonTextColorCode;
  final int buttonColorCode;
  final Function? onPressedFunction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed:
            (onPressedFunction == null) ? null : () => onPressedFunction!(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(buttonColorCode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          buttonName,
          style: TextStyle(
            color: Color(buttonTextColorCode),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
