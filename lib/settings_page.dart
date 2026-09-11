import 'package:flutter/material.dart';
import 'action_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Main screen wale same theme colors
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. TOP BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Back Button (Action Button)
                  ActionButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    contentColor: textGrey,
                    bgColor: surfaceColor.withOpacity(0.5),
                    onTap: () {
                      Navigator.pop(context); // Settings se wapas aane ke liye
                    },
                  ),

                  // Title (Center aligned)
                  const Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),

                  // Dummy spacing taaki title center mein rahe
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // --- 2. SETTINGS OPTIONS ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingsItem(
                      icon: Icons.palette_outlined,
                      title: 'Theme Settings',
                      subtitle: 'Change app colors & look',
                      iconColor: cyanColor,
                      onTap: () {
                        // Action here
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.vibration_rounded,
                      title: 'Haptics & Sound',
                      subtitle: 'Manage vibration feedback',
                      iconColor: const Color(0xFFFF9500),
                      onTap: () {
                        // Action here
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'Learn how to use features',
                      iconColor: Colors.greenAccent,
                      onTap: () {
                        // Action here
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.star_outline_rounded,
                      title: 'Rate Us',
                      subtitle: 'Love Calculator Pro?',
                      iconColor: Colors.yellow,
                      onTap: () {
                        // Action here
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      subtitle: 'Version 1.0.0',
                      iconColor: textGrey,
                      onTap: () {
                        // Action here
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Settings ke Item ka Design
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // Cards ke beech thoda gap
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: iconColor.withOpacity(0.1),
        highlightColor: iconColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            children: [
              // Icon Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                          color: textGrey.withOpacity(0.6),
                          fontSize: 13
                      ),
                    ),
                  ],
                ),
              ),

              // Right Arrow Icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: textGrey.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}