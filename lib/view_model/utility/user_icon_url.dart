import 'package:flutter/material.dart';

bool isValidUrl(String? url) {
  return url != null &&
      (url.startsWith('http://') || url.startsWith('https://'));
}

Widget buildPlaceholderIcon({double size = 72}) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Color(0xFFEEEEEE),
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.person,
      color: Colors.grey,
      size: 40,
    ),
  );
}
