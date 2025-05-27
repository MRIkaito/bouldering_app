import 'package:flutter/material.dart';

class SubmitFormWidget extends StatelessWidget {
  final Function(String) onSubmitTextChanged; // コールバック関数
  final bool isObscure;
  final String hintText;
  final List<String>? autofillHints; // ← 追加

  const SubmitFormWidget({
    super.key,
    required this.isObscure,
    required this.hintText,
    required this.onSubmitTextChanged,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isObscure,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        hintText: hintText,
      ),
      onChanged: onSubmitTextChanged, // 入力が変更されるたびコールバック関数を呼び出す．
      autofillHints: autofillHints,
    );
  }
}
