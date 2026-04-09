import 'package:flutter/material.dart';

const List<Color> kDisplayBoardPalette = [
  Color(0xFFE8B04A),
  Color(0xFFF5F7FA),
  Color(0xFFD6E4FF),
  Color(0xFFC8F1E7),
  Color(0xFFFFE2A8),
  Color(0xFFEBC7FF),
  Color(0xFFF7C9C9),
  Color(0xFFC8D0D6),
  Color(0xFFFFC857),
  Color(0xFFFFF4D6),
  Color(0xFFB8E3FF),
  Color(0xFFBFF3D8),
  Color(0xFFFFD5C2),
  Color(0xFFFFC7E2),
  Color(0xFFD7CCFF),
  Color(0xFFA7F0F9),
  Color(0xFFE6FFB3),
  Color(0xFFFFE5A3),
  Color(0xFFFFD1B8),
  Color(0xFFE4E7EC),
];

Color displayBoardPaletteColor(int index) {
  if (index < 0 || index >= kDisplayBoardPalette.length) {
    return kDisplayBoardPalette.first;
  }
  return kDisplayBoardPalette[index];
}
