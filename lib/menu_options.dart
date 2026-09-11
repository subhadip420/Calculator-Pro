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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
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

            // --- 2. SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(), // Premium smooth scroll
                padding: const EdgeInsets.fromLTRB(18, 5, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Widget Call kiya
                    _buildSearchBar(),

                    const SizedBox(height: 14), // Dono ke beech ka gap
                    // Favourite Card Widget Call kiya
                    _buildFavouriteCard(),

                    const SizedBox(height: 14), // Naya gap Favourite aur next items ke beech
                    // --- CATEGORY TEXT ---
                    // --- CARD VIEW WALA SECTION ---
                    Container(
                      padding: const EdgeInsets.only(top: 12.0, left: 10.0, right: 10.0, bottom: 0),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(0.2), // Outer Card Background
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- CATEGORY TEXT ---
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0, bottom: 10.0),
                            child: Text(
                              'Unit Converters', // Category Title
                              style: TextStyle(
                                color: textGrey.withOpacity(0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),

                          // Naya Menu Item
                          _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Length', 'Convert length'),

                          _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Length', 'Convert length'),

                          // Agar aur unit converters add karne ho toh unhe yahan niche add kar sakte hain
                        ],
                      ),
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

  // --- WIDGET 1: Search Bar ---
  Widget _buildSearchBar() {
    return Container(
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
          border: InputBorder.none,
          // Default line hide karne ke liye
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  // --- WIDGET 2: Favourite Card ---
  Widget _buildFavouriteCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 24),
          // Star Icon
          const SizedBox(width: 16),
          const Text(
            'Favourite',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          // Isse baaki space khali rahegi
          Icon(Icons.arrow_forward_ios_rounded, color: textGrey.withOpacity(0.3), size: 16),
          // Right Arrow (Optional premium look)
        ],
      ),
    );
  }

  // Stylish Menu Item Design (Image + Card View)
  Widget _buildMenuItem(String imagePath, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0), // Cards ke beech ka gap
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: surfaceColor.withOpacity(0.4), // Main Card Background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)), // Premium border
        ),
        child: Row(
          children: [
            // Image Box
            Image.asset(
              imagePath, // Yahan aapki asset image aayegi
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon in case image is missing
                return const Icon(Icons.image_not_supported, color: Colors.white54, size: 30);
              },
            ),

            const SizedBox(width: 16),

            // Text Content
            Expanded(
              // Expanded zaroori hai taaki lamba text screen se bahar na jaye
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: textGrey.withOpacity(0.6), fontSize: 13)),
                ],
              ),
            ),

            // Right Arrow (Premium Card Look ke liye)
            Icon(Icons.arrow_forward_ios_rounded, color: textGrey.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }
}
