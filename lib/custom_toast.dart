import 'package:flutter/material.dart';

void showCustomToast(BuildContext context, String message) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  // Background color dynamic set kiya
  final Color bgColor = isDark
      ? const Color(0xFF29292C).withOpacity(0.8)
      : Colors.white.withOpacity(0.95); // Light mode me solid white

  final Color cyanColor = isDark ? Colors.cyanAccent : Colors.cyan;

  final snackBar = SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        //color: Color(0xFF4CD7F6), // Dark background color for text
        color: isDark ? cyanColor : Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
    //backgroundColor: const Color(0xFF29292C).withOpacity(0.6), // Cyan theme color
    backgroundColor: bgColor,
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            //color: Color(0xFF4CD7F6).withOpacity(0.5),
            color: isDark ? cyanColor.withOpacity(0.5) : cyanColor,
            width: 1
        ),
  ),
    margin: const EdgeInsets.only(bottom: 100, left: 50, right: 50),
    duration: const Duration(seconds: 2),
  );

  // Pehle wale toast ko hide karke naya dikhayega (agar jaldi jaldi tap kiya)
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}