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
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: boxShadow,
      ),
      child: IconButton(
        icon: icon != null
            ? Icon(icon, color: contentColor, size: 20)
            : Text(
          text ?? '',
          style: TextStyle(
            color: contentColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}