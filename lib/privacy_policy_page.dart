import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'action_button.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
                  ActionButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    contentColor: textGrey,
                    bgColor: surfaceColor.withOpacity(0.5),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
                    _buildSection(
                      '1. Introduction',
                      'SP Tech Studios built the Calculator Pro app as a Free/Commercial app. This SERVICE is provided by SP Tech Studios and is intended for use as is.',
                    ),

                    _buildSection(
                      '2. Data Collection and Use',
                      'Calculator Pro itself does not collect, store, or share any personal information directly. Your calculations and app settings (like theme and haptics) are saved locally on your device.',
                    ),

                    _buildSection(
                      '3. Third-Party Services (Ads)',
                      'To keep the app free, we use Google AdMob for advertising. AdMob may use device identifiers and cookies to serve personalized or non-personalized ads based on your location and usage.',
                    ),

                    _buildSection(
                      '4. Permissions',
                      'The app requires Internet permission to serve advertisements and Vibration permission to provide haptic feedback during typing.',
                    ),

                    // --- NAYA: Clickable Email ID Section ---
                    _buildContactUsSection(),

                    // --- Clickable Hyperlink Section ---
                    _buildLinkSection(),

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

  // Premium Section Builder (Normal Text ke liye)
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: cyanColor, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          Text(content, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }

  // --- NAYA: Contact Us Section (Clickable Mailto) ---
  Widget _buildContactUsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '5. Contact Us',
            style: TextStyle(color: cyanColor, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at:',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 8),

          // Clickable Email Text
          GestureDetector(
            onTap: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'support.sptechstudios@gmail.com',
                query: 'subject=Privacy Policy Query - Calculator Pro',
              );
              try {
                await launchUrl(emailUri, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint("Could not launch email app: $e");
              }
            },
            child: const Text(
              'support.sptechstudios@gmail.com',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Link Section Builder (Website ke liye)
  Widget _buildLinkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '6. More Information',
          style: TextStyle(color: cyanColor, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 10),
        Text(
          'For complete details, including Terms & Conditions and Third-Party links, please read our full policy online:',
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: 12),
        // Clickable Blue Text
        GestureDetector(
          onTap: () async {
            final Uri policyUrl = Uri.parse('https://subhadip420.github.io/calculator-pro-privacy-policy/');
            try {
              await launchUrl(policyUrl, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint("Could not launch url: $e");
            }
          },
          child: const Text(
            'Read Full Privacy Policy Here',
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: Colors.blueAccent,
            ),
          ),
        ),
      ],
    );
  }
}
