import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color textColor;
  final Color bgColor;
  final VoidCallback onTap;

  // Naye parameters size ko dynamic banane ke liye
  final double? fontSize;
  final double? iconSize;
  final String buttonShape;

  const CalculatorButton({
    super.key,
    this.text,
    this.icon,
    required this.textColor,
    required this.bgColor,
    required this.onTap,
    this.fontSize,
    this.iconSize,
    this.buttonShape = 'rounded',
  });

  BorderRadius _getShapeRadius() {
    return buttonShape == 'circle'
        ? BorderRadius.circular(100) // Circle ke liye full round
        : BorderRadius.circular(16); // Rounded ke liye normal curve
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          // 1. Shadow aur Border ko bahar wale Container me rakha hai
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(16),
            borderRadius: _getShapeRadius(),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          // 2. Material widget use kiya background color aur ripple ke liye
          child: Material(
            color: bgColor, // FIX: Background color yahan shift kiya
            //borderRadius: BorderRadius.circular(16),
            borderRadius: _getShapeRadius(),
            clipBehavior: Clip.antiAlias, // Taaki ripple gol corners ke bahar na nikle
            child: InkWell(
              onTap: onTap,
              // NAYA: Premium splash aur highlight animation colors
              splashColor: textColor.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),

              child: Container(
                alignment: Alignment.center,
                // Thodi side padding taaki text border se na chipke
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                // Yahan se color hata diya taaki ripple dikhe
                child: icon != null
                    ? Icon(
                  icon,
                  color: textColor,
                  size: iconSize ?? 22, // Agar iconSize diya hai to wo use hoga, warna 22
                )
                    : FittedBox( // FittedBox ensure karega ki text kabhi 2nd line pe na jaye
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text ?? '',
                    style: TextStyle(
                      color: textColor,
                      // Agar fontSize diya hai to wo, warna default logic
                      fontSize: fontSize ?? ((text == 'AC' || text == '=') ? 22 : 18),
                      fontWeight: (text == 'AC' || text == '=' || text == '÷' || text == '×' || text == '−' || text == '+')
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}