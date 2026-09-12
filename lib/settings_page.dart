import 'package:calculator_pro/privacy_policy_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NAYA: SharedPreferences import kiya
import 'package:url_launcher/url_launcher.dart';
import 'action_button.dart';
import 'custom_dialog.dart';

// NAYA: StatefulWidget banaya taaki toggle state update ho sake
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Main screen wale same theme colors
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  // Toggle ke liye variable
  bool _isHapticsEnabled = true; // Default ON rahega

  @override
  void initState() {
    super.initState();
    _loadHapticsSetting(); // App khulte hi setting load hogi
  }

  // SharedPreferences se load karne ka function
  Future<void> _loadHapticsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    });
  }

  // SharedPreferences me save karne ka function
  Future<void> _toggleHaptics(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics_enabled', value);
    setState(() {
      _isHapticsEnabled = value;
    });
  }

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
                      if (_isHapticsEnabled) {
                        HapticFeedback.lightImpact(); // Halka sa premium vibration
                      }
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(width: 16), // Button aur title ke beech gap

                  // Title (Ab Left aligned hai)
                  const Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22, // Size thoda bada kiya premium look ke liye
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. SETTINGS OPTIONS ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingsItem(
                      icon: Icons.palette_outlined,
                      title: 'Theme Settings',
                      subtitle: 'Change app colors & look',
                      iconColor: cyanColor,
                      onTap: () {
                        if (_isHapticsEnabled) {
                          HapticFeedback.lightImpact(); // Halka sa premium vibration
                        }
                        // "Coming Soon" Dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              title: 'Coming Soon!',
                              subtitle: 'We are working hard to bring this awesome feature in the next update. Stay tuned!',
                              isSingleButton: true,
                              primaryButtonText: 'Okay',
                              onPrimaryPressed: () {
                                if (_isHapticsEnabled) {
                                  HapticFeedback.selectionClick(); // Halka sa premium vibration
                                }
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                    ),

                    // NAYA: Haptics option with Toggle Button
                    _buildSettingsItem(
                      icon: Icons.vibration_rounded,
                      title: 'Haptic Feedback', // Sound hata diya
                      subtitle: 'Enable vibration on tap',
                      iconColor: const Color(0xFFFF9500),
                      // Custom trailing widget (Switch) bheja
                      trailing: Switch(
                        value: _isHapticsEnabled,
                        activeColor: cyanColor,
                        inactiveTrackColor: surfaceColor.withOpacity(0.8),
                        onChanged: (value) => _toggleHaptics(value),
                      ),
                    ),

                    // Share App
                    _buildSettingsItem(
                      icon: Icons.share_rounded,
                      title: 'Share App',
                      subtitle: 'Share Calculator Pro with friends',
                      iconColor: Colors.blueAccent, // Share ke liye blue color
                      onTap: () {
                        if (_isHapticsEnabled) {
                          HapticFeedback.lightImpact(); // Halka sa premium vibration
                        }
                        // "Coming Soon" Dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              title: 'Coming Soon!',
                              subtitle: 'We are working hard to bring this awesome feature in the next update. Stay tuned!',
                              isSingleButton: true,
                              primaryButtonText: 'Okay',
                              onPrimaryPressed: () {
                                if (_isHapticsEnabled) {
                                  HapticFeedback.selectionClick(); // Halka sa premium vibration
                                }
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                    ),

                    _buildSettingsItem(
                      icon: Icons.star_outline_rounded,
                      title: 'Rate Us',
                      subtitle: 'Love Calculator Pro?',
                      iconColor: Colors.yellow,
                      onTap: () {
                        if (_isHapticsEnabled) {
                          HapticFeedback.lightImpact(); // Halka sa premium vibration
                        }
                        // "Coming Soon" Dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              title: 'Coming Soon!',
                              subtitle: 'We are working hard to bring this awesome feature in the next update. Stay tuned!',
                              isSingleButton: true,
                              primaryButtonText: 'Okay',
                              onPrimaryPressed: () {
                                if (_isHapticsEnabled) {
                                  HapticFeedback.selectionClick(); // Halka sa premium vibration
                                }
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                    ),

                    _buildSettingsItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'Learn how to use features',
                      iconColor: Colors.greenAccent,
                      onTap: () {
                        if (_isHapticsEnabled) {
                          HapticFeedback.lightImpact(); // Halka sa premium vibration
                        }
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              title: 'Support & Feedback',
                              subtitle: 'We would love to hear from you! For any queries, bugs, or feedback, please email us at:',

                              // NAYA: Clickable Blue Email Address
                              customContent: GestureDetector(
                                onTap: () async {
                                  final Uri emailUri = Uri(
                                    scheme: 'mailto',
                                    path: 'support.sptechstudios@gmail.com',
                                    query: 'subject=App Feedback - Calculator Pro',
                                  );

                                  // canLaunchUrl check hata bhi sakte hain ya mode pass kar sakte hain
                                  try {
                                    await launchUrl(
                                      emailUri,
                                      mode: LaunchMode.externalApplication, // NAYA: External app me force kholne ke liye
                                    );
                                  } catch (e) {
                                    debugPrint("Could not launch email app: $e");
                                  }
                                },
                                child: const Text(
                                  'support.sptechstudios@gmail.com',
                                  style: TextStyle(
                                    color: Colors.cyanAccent, // Premium Blue Color
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              isSingleButton: true,
                              primaryButtonText: 'Close',
                              onPrimaryPressed: () {
                                if (_isHapticsEnabled) {
                                  HapticFeedback.selectionClick(); // Halka sa premium vibration
                                }
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                    ),

                    // Privacy Policy
                    _buildSettingsItem(
                      icon: Icons.privacy_tip_outlined, // Privacy ke liye shield/tip icon
                      title: 'Privacy Policy',
                      subtitle: 'Read our terms & policies',
                      iconColor: Colors.tealAccent, // Privacy ke liye teal color
                      onTap: () {
                        if (_isHapticsEnabled) {
                          HapticFeedback.lightImpact(); // Halka sa premium vibration
                        }
                        // NAYA: Click karte hi Privacy Policy page open hoga
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                        );
                      },
                    ),

                    _buildSettingsItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      subtitle: 'Version 1.0.0',
                      iconColor: textGrey,
                      onTap: () {
                        if (_isHapticsEnabled) {
                          HapticFeedback.lightImpact(); // Halka sa premium vibration
                        }
                        // NAYA: About par click karte hi Custom Dialog open hoga
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              title: 'Calculator Pro',
                              subtitle: 'Version 1.0.0\n\nA premium calculator and multi-tool designed for seamless daily use.',
                              isSingleButton: true, // Aapki requirement: Single button
                              primaryButtonText: 'Got it',
                              onPrimaryPressed: () {
                                if (_isHapticsEnabled) {
                                  HapticFeedback.selectionClick(); // Halka sa premium vibration
                                }
                                Navigator.of(context).pop(); // Button click par dialog band ho jayega
                              },
                            );
                          },
                        );
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

  // Settings ke Item ka Design (Ab Card View me hai)
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    VoidCallback? onTap,
    Widget? trailing, // NAYA: Custom right side widget (Arrow ya Switch ke liye)
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: iconColor.withOpacity(0.1),
        highlightColor: iconColor.withOpacity(0.05),
        child: Container(
          // NAYA: Card Design add kiya (MenuOptions jaisa)
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.4), // Premium Card Background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // Icon Box
              Icon(icon, color: iconColor, size: 28),
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
                          fontSize: 16,
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

              // Right Arrow Icon ya Custom Widget (jaise Switch)
              trailing ?? Icon(
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