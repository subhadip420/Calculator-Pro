import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  // Texts
  final String title;
  final String? subtitle;
  final bool isSingleButton;
  final String primaryButtonText;
  final String? secondaryButtonText;

  // Actions
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  // Customization (Colors & Font Sizes)
  final Color backgroundColor;
  final Color titleColor;
  final double titleFontSize;
  final Color subtitleColor;
  final double subtitleFontSize;

  final Color primaryButtonBgColor;
  final Color primaryButtonTextColor;
  final double primaryButtonFontSize;

  final Color secondaryButtonBgColor;
  final Color secondaryButtonTextColor;
  final double secondaryButtonFontSize;

  const CustomDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.isSingleButton = false,
    required this.primaryButtonText,
    this.secondaryButtonText,
    required this.onPrimaryPressed,
    this.onSecondaryPressed,

    // Default theme colors (Aapke app ke colors se matched)
    this.backgroundColor = const Color(0xFF1E2638),
    this.titleColor = Colors.white,
    this.titleFontSize = 22.0,
    this.subtitleColor = const Color(0xFFDBC2AD),
    this.subtitleFontSize = 14.0,

    this.primaryButtonBgColor = const Color(0xFF4CD7F6), // Cyan
    this.primaryButtonTextColor = const Color(0xFF0E131D), // Dark text for contrast
    this.primaryButtonFontSize = 16.0,

    this.secondaryButtonBgColor = Colors.transparent,
    this.secondaryButtonTextColor = Colors.white,
    this.secondaryButtonFontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Background transparent for custom shape
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Jitna content utni height
          children: [
            // --- TITLE ---
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            // --- SUBTITLE ---
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: subtitleFontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 24),

            // --- BUTTONS ---
            Row(
              children: [
                // Secondary Button (Cancel)
                if (!isSingleButton) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: secondaryButtonBgColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: secondaryButtonBgColor == Colors.transparent
                                ? Colors.white.withOpacity(0.1) // Light border if transparent
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Text(
                        secondaryButtonText ?? 'Cancel',
                        style: TextStyle(
                          color: secondaryButtonTextColor,
                          fontSize: secondaryButtonFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Primary Button (OK / Confirm)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimaryPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonBgColor,
                      foregroundColor: primaryButtonTextColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      primaryButtonText,
                      style: TextStyle(
                        fontSize: primaryButtonFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}