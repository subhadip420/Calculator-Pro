import 'package:flutter/material.dart';

class AppColors {
  // Theme check karne ka helper method
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // --- DYNAMIC COLORS (Dono themes ke hisaab se badlenge) ---

  static Color bgColor(BuildContext context) {
    return isDark(context) ? const Color(0xFF0E131D) : const Color(0xFFE0E6FC);
  }

  static Color surfaceColor(BuildContext context) {
    return isDark(context) ? const Color(0xFF1E2638) : const Color(0xFFFFFFFF);
  }

  static Color textGrey(BuildContext context) {
    return isDark(context) ? const Color(0xFFE1CDBB) : const Color(0xFF464545);
  }

  static Color textColor(BuildContext context) {
    return isDark(context) ? Colors.white : Colors.black87;
  }

  static Color operatorBgColor(BuildContext context) {
    return isDark(context) ? Colors.orange.withOpacity(0.15) : Colors.orange.withOpacity(0.20);
  }

  static Color cyanColor(BuildContext context) {
    return isDark(context) ? Colors.cyanAccent : Colors.cyan;
  }

  static Color orangeColor(BuildContext context) {
    return isDark(context) ? Colors.orangeAccent : Colors.orange;
  }

  static Color redColor(BuildContext context) {
    return isDark(context) ? Colors.redAccent : Colors.red;
  }

  static Color tealColor(BuildContext context) {
    return isDark(context) ? Colors.tealAccent : Colors.teal;
  }

  static Color greenColor(BuildContext context) {
    return isDark(context) ? Colors.greenAccent : Colors.green;
  }

  static Color blueColor(BuildContext context) {
    return isDark(context) ? Colors.blueAccent : Colors.blue;
  }
  // --- CONSTANT COLORS (Jo har theme mein same rahenge) ---

  //static const Color cyanColor = Color(0xFF4CD7F6);
  //static const Color orangeColor = Color(0xFFFF9500);
  //tatic const Color redColor = Color(0xFFFFB4AB);
}