import 'package:flutter/material.dart';
import 'action_button.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
                  // Back Button
                  ActionButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    contentColor: textGrey,
                    bgColor: surfaceColor.withOpacity(0.5),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(width: 16),

                  // Title
                  const Expanded(
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. POLICY CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last updated: September 12, 2026',
                      style: TextStyle(
                        color: textGrey.withOpacity(0.5),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSection(
                      '1. Introduction',
                      'SP Tech Studios built the Calculator Pro app as a Free/Commercial app. This SERVICE is provided by SP Tech Studios and is intended for use as is.',
                    ),

                    _buildSection(
                      '2. Data Collection and Use',
                      'Calculator Pro is designed with privacy in mind. We do not collect, store, or share any personal information. All your calculations and app settings (like theme and haptic preferences) are saved locally on your device.',
                    ),

                    _buildSection(
                      '3. Permissions',
                      'The app may require certain device permissions (such as Vibration for haptic feedback) solely to enhance your user experience. We do not use these permissions to collect personal data.',
                    ),

                    _buildSection(
                      '4. Third-Party Services',
                      'Currently, Calculator Pro does not use any third-party services that collect information used to identify you.',
                    ),

                    _buildSection(
                      '5. Changes to This Privacy Policy',
                      'We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page.',
                    ),

                    _buildSection(
                      '6. Contact Us',
                      'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at:\n\nsupport.sptechstudios@gmail.com',
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Premium Section Builder
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: cyanColor, // Highlighted Headers
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              height: 1.6, // Better line spacing for readability
            ),
          ),
        ],
      ),
    );
  }
}