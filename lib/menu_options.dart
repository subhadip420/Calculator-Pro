import 'package:calculator_pro/settings_page.dart';
import 'package:flutter/material.dart';
import 'action_button.dart'; // NAYA: Aapke custom ActionButton ko import kiya

class MenuOptions extends StatelessWidget {
  final VoidCallback onClose;

  const MenuOptions({super.key, required this.onClose});

  // Main screen wale same theme colors yahan define kiye
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: bgColor, // Main screen ka exact background color
      child: SafeArea(
        child: Column(
          children: [
            // --- 1. TOP BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Settings Button (Ab ActionButton use ho raha hai)
                  ActionButton(
                    icon: Icons.settings_outlined,
                    contentColor: textGrey,
                    bgColor: surfaceColor.withOpacity(0.5),
                    onTap: () {
                      // NAYA: Settings Page open karega
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),

                  // Center: Title
                  const Text(
                    'More Options', // NAYA TITLE
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  // Right: Back Button (Ab ActionButton use ho raha hai)
                  ActionButton(
                    icon: Icons.arrow_forward_ios_rounded,
                    contentColor: textGrey,
                    bgColor: surfaceColor.withOpacity(0.5),
                    onTap: onClose, // Back dabaate hi menu slide wapas ho jayega
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Card View
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(0.4), // Card background
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        cursorColor: cyanColor,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: textGrey.withOpacity(0.5), fontSize: 15),
                          prefixIcon: Icon(Icons.search_rounded, color: textGrey.withOpacity(0.7)),
                          border: InputBorder.none, // Default line hide karne ke liye
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stylish Menu Item Design
  Widget _buildMenuItem(IconData icon, String title, String subtitle, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceColor.withOpacity(0.5), // Surface color for icon background
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: textGrey.withOpacity(0.6), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}