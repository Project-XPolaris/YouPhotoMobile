
import 'package:flutter/material.dart';

Color getTextColor(String hexColor) {
  Color color = Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000);
  double luminance = color.computeLuminance();

  if (luminance > 0.5) {
    return Colors.black;
  } else {
    return Colors.white;
  }
}