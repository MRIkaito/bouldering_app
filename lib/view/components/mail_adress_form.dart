import 'package:flutter/material.dart';

class MailAdressFormWidget extends StatelessWidget {
  const MailAdressFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        hintText: 'mri.benkyochannel@gmail.com',
      ),
    );
  }
}
