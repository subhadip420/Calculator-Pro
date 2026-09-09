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

  const CalculatorButton({
    super.key,
    this.text,
    this.icon,
    required this.textColor,
    required this.bgColor,
    required this.onTap,
    this.fontSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            // Thodi side padding taaki text border se na chipke
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
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
    );
  }
}