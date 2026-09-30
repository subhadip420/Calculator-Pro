// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'main.dart';
//
// class ConverterKeyboard extends StatelessWidget {
//   final Function(String) onKeyPress;
//   final VoidCallback onBackspace;
//   final VoidCallback onClear;
//   final bool isHapticsEnabled;
//   final String buttonShape;
//
//   const ConverterKeyboard({
//     super.key,
//     required this.onKeyPress,
//     required this.onBackspace,
//     required this.onClear,
//     this.isHapticsEnabled = true,
//     this.buttonShape = 'rounded',
//   });
//
//   // final Color surfaceColor = const Color(0xFF1E2638);
//   // final Color cyanColor = const Color(0xFF4CD7F6);
//   bool get isDark => appThemeNotifier.value == 'dark';
//   Color get surfaceColor => isDark ? const Color(0xFF1E2638) : const Color(0xFFFFFFFF);
//   Color get cyanColor => isDark ? Colors.cyanAccent : Colors.cyan;
//   Color get white => isDark ? Colors.white : Colors.black87;
//
//   void _triggerHaptic() {
//     if (isHapticsEnabled) HapticFeedback.selectionClick();
//   }
//
//   BorderRadius _getShapeRadius() {
//     return buttonShape == 'circle'
//         ? BorderRadius.circular(100) // Circle ke liye full round
//         : BorderRadius.circular(16); // Rounded ke liye normal curve
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Column(
//         children: [
//           // Row 1: 7, 8, 9, C
//           Row(
//             children: [
//               _buildKey('7', onTap: () => onKeyPress('7')),
//               const SizedBox(width: 10),
//               _buildKey('8', onTap: () => onKeyPress('8')),
//               const SizedBox(width: 10),
//               _buildKey('9', onTap: () => onKeyPress('9')),
//               const SizedBox(width: 10),
//               _buildKey('AC', textColor: Colors.orangeAccent, onTap: onClear),
//             ],
//           ),
//           const SizedBox(height: 10),
//
//           // Row 2: 4, 5, 6, Backspace
//           Row(
//             children: [
//               _buildKey('4', onTap: () => onKeyPress('4')),
//               const SizedBox(width: 10),
//               _buildKey('5', onTap: () => onKeyPress('5')),
//               const SizedBox(width: 10),
//               _buildKey('6', onTap: () => onKeyPress('6')),
//               const SizedBox(width: 10),
//               _buildIconKey(Icons.backspace_outlined, onTap: onBackspace),
//             ],
//           ),
//           const SizedBox(height: 10),
//
//           // Row 3: 1, 2, 3, Empty Space
//           Row(
//             children: [
//               _buildKey('1', onTap: () => onKeyPress('1')),
//               const SizedBox(width: 10),
//               _buildKey('2', onTap: () => onKeyPress('2')),
//               const SizedBox(width: 10),
//               _buildKey('3', onTap: () => onKeyPress('3')),
//               const SizedBox(width: 10),
//               const Expanded(child: SizedBox()),
//             ],
//           ),
//           const SizedBox(height: 10),
//
//           // Row 4: 00, 0, ., Empty Space
//           Row(
//             children: [
//               _buildKey('00', onTap: () => onKeyPress('00')),
//               const SizedBox(width: 10),
//               _buildKey('0', onTap: () => onKeyPress('0')),
//               const SizedBox(width: 10),
//               _buildKey('.', onTap: () => onKeyPress('.')),
//               const SizedBox(width: 10),
//               const Expanded(child: SizedBox()),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildKey(String text, {required VoidCallback onTap, Color? textColor}) {
//     return Expanded(
//       child: Material(
//         color: surfaceColor.withOpacity(0.5),
//         //borderRadius: BorderRadius.circular(16),
//         borderRadius: _getShapeRadius(),
//         clipBehavior: Clip.antiAlias, // Ripple border ke bahar na nikle
//         child: InkWell(
//           onTap: () {
//             _triggerHaptic();
//             onTap();
//           },
//           //borderRadius: BorderRadius.circular(16),
//           borderRadius: _getShapeRadius(),
//           // NAYA: Ripple aur highlight animation colors
//           splashColor: (textColor ?? cyanColor).withOpacity(0.2),
//           highlightColor: Colors.white.withOpacity(0.1),
//           child: Container(
//             height: 65,
//             alignment: Alignment.center, // Center mein laane ke liye
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: textColor ?? white,
//                 fontSize: 26,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildIconKey(IconData icon, {required VoidCallback onTap}) {
//     return Expanded(
//       child: Material(
//         color: surfaceColor.withOpacity(0.5),
//         //borderRadius: BorderRadius.circular(16),
//         borderRadius: _getShapeRadius(),
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: () {
//             _triggerHaptic();
//             onTap();
//           },
//           // Optional: Long press to clear
//           onLongPress: () {
//             _triggerHaptic();
//             onClear();
//           },
//           //borderRadius: BorderRadius.circular(16),
//           borderRadius: _getShapeRadius(),
//           // NAYA: Icon key ke liye splash animation
//           splashColor: cyanColor.withOpacity(0.2),
//           highlightColor: Colors.white.withOpacity(0.1),
//           child: Container(
//             height: 65,
//             alignment: Alignment.center, // Center mein laane ke liye
//             child: Icon(icon, color: cyanColor, size: 28),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart'; // NAYA: AppColors file import karni hai

class ConverterKeyboard extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool isHapticsEnabled;
  final String buttonShape;

  const ConverterKeyboard({
    super.key,
    required this.onKeyPress,
    required this.onBackspace,
    required this.onClear,
    this.isHapticsEnabled = true,
    this.buttonShape = 'rounded',
  });

  // Purane local color variables hata diye hain kyunki ab hum AppColors use karenge.

  void _triggerHaptic() {
    if (isHapticsEnabled) HapticFeedback.selectionClick();
  }

  BorderRadius _getShapeRadius() {
    return buttonShape == 'circle'
        ? BorderRadius.circular(100)
        : BorderRadius.circular(16);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Row 1: 7, 8, 9, C
          Row(
            children: [
              // NAYA: Sab jagah context pass kiya hai
              _buildKey(context, '7', onTap: () => onKeyPress('7')),
              const SizedBox(width: 10),
              _buildKey(context, '8', onTap: () => onKeyPress('8')),
              const SizedBox(width: 10),
              _buildKey(context, '9', onTap: () => onKeyPress('9')),
              const SizedBox(width: 10),
              _buildKey(context, 'AC', textColor: AppColors.orangeColor(context), onTap: onClear),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: 4, 5, 6, Backspace
          Row(
            children: [
              _buildKey(context, '4', onTap: () => onKeyPress('4')),
              const SizedBox(width: 10),
              _buildKey(context, '5', onTap: () => onKeyPress('5')),
              const SizedBox(width: 10),
              _buildKey(context, '6', onTap: () => onKeyPress('6')),
              const SizedBox(width: 10),
              _buildIconKey(context, Icons.backspace_outlined, onTap: onBackspace),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: 1, 2, 3, Empty Space
          Row(
            children: [
              _buildKey(context, '1', onTap: () => onKeyPress('1')),
              const SizedBox(width: 10),
              _buildKey(context, '2', onTap: () => onKeyPress('2')),
              const SizedBox(width: 10),
              _buildKey(context, '3', onTap: () => onKeyPress('3')),
              const SizedBox(width: 10),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 10),

          // Row 4: 00, 0, ., Empty Space
          Row(
            children: [
              _buildKey(context, '00', onTap: () => onKeyPress('00')),
              const SizedBox(width: 10),
              _buildKey(context, '0', onTap: () => onKeyPress('0')),
              const SizedBox(width: 10),
              _buildKey(context, '.', onTap: () => onKeyPress('.')),
              const SizedBox(width: 10),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

// 1. NUMBER KEYS WALA FUNCTION
  Widget _buildKey(BuildContext context, String text, {required VoidCallback onTap, Color? textColor}) {
    final isDark = AppColors.isDark(context);

    return Expanded(
      child: Material(
        color: AppColors.surfaceColor(context).withOpacity(isDark ? 0.5 : 1.0),
        borderRadius: _getShapeRadius(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _triggerHaptic();
            onTap();
          },
          borderRadius: _getShapeRadius(),

          // NAYA FIX 1: textColor check aur opacity ekdum theek syntax me
          splashColor: textColor != null ? textColor.withOpacity(0.2) : AppColors.cyanColor(context).withOpacity(0.2),
          highlightColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),

          child: Container(
            height: 65,
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                // NAYA FIX 2: AppColors.textColor ke baad (context) lagana zaroori hai
                color: textColor ?? AppColors.textColor(context),
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 2. ICON KEYS (BACKSPACE) WALA FUNCTION
  Widget _buildIconKey(BuildContext context, IconData icon, {required VoidCallback onTap}) {
    final isDark = AppColors.isDark(context);

    return Expanded(
      child: Material(
        color: AppColors.surfaceColor(context).withOpacity(isDark ? 0.5 : 1.0),
        borderRadius: _getShapeRadius(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _triggerHaptic();
            onTap();
          },
          onLongPress: () {
            _triggerHaptic();
            onClear();
          },
          borderRadius: _getShapeRadius(),

          // NAYA FIX 3: Yahan textColor nahi hai, direct Cyan color use karna hai
          splashColor: AppColors.cyanColor(context).withOpacity(0.2),
          highlightColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),

          child: Container(
            height: 65,
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.cyanColor(context), size: 28),
          ),
        ),
      ),
    );
  }
}