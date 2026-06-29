import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Named colors
  static const Color navy = Color(0xFF1B2A41);
  static const Color red = Color(0xFFC5283D);
  static const Color ochre = Color(0xFFC99B5A);
  static const Color cream = Color(0xFFF8F4ED);
  static const Color paper = Color(0xFFFFFDF9);
  static const Color sand = Color(0xFFE7DFD2);
  static const Color taupe = Color(0xFF6B6256);
  static const Color stone = Color(0xFFA89F90);
  static const Color brick = Color(0xFFB03A2E);

  // Semantic roles 
  static const Color primary = navy;        // main actions: Apply, Submit
  static const Color onPrimary = cream;     // text and icons on primary
  static const Color danger = red;          // destructive actions only
  static const Color error = brick;         // validation and error states
  static const Color highlight = ochre;     // verified badge, strong match

  static const Color background = cream;     // app canvas
  static const Color surface = paper;        // cards
  static const Color border = sand;          // hairlines, dividers

  static const Color textPrimary = navy;     // headings, body
  static const Color textSecondary = taupe;  // supporting text
  static const Color textFaint = stone;      // hints, placeholders
}