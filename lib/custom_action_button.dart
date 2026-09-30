// import 'package:flutter/material.dart';
//
// class ActionButton extends StatelessWidget {
//   final IconData? icon;
//   final String? text; // 'Σ' jaise text ke liye
//   final Color contentColor;
//   final Color bgColor;
//   final List<BoxShadow>? boxShadow;
//   final VoidCallback onTap;
//
//   const ActionButton({
//     super.key,
//     this.icon,
//     this.text,
//     required this.contentColor,
//     required this.bgColor,
//     this.boxShadow,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 44,
//       height: 44,
//       decoration: BoxDecoration(
//         color: bgColor,
//         shape: BoxShape.circle,
//         boxShadow: boxShadow,
//       ),
//       child: IconButton(
//         icon: icon != null
//             ? Icon(icon, color: contentColor, size: 20)
//             : Text(
//           text ?? '',
//           style: TextStyle(
//             color: contentColor,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         onPressed: onTap,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData? icon;
  final String? text; // 'Σ' jaise text ke liye
  final Color contentColor;
  final Color bgColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    this.icon,
    this.text,
    required this.contentColor,
    required this.bgColor,
    this.boxShadow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- NAYA FIX: Theme check kar rahe hain taaki animation color perfect rahe ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: boxShadow,
      ),
      child: Material(
        color: bgColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),

          // --- THEME AWARE ANIMATION COLORS ---
          splashColor: contentColor.withOpacity(isDark ? 0.2 : 0.15),

          // Dark mode me white highlight, aur Light mode me faint black highlight
          highlightColor: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),

          child: Center(
            child: icon != null
                ? Icon(icon, color: contentColor, size: 20)
                : Text(
              text ?? '',
              style: TextStyle(
                color: contentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}