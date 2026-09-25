import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_action_button.dart'; // Apna correct path check kar lena

class RomanNumeralsConverterView extends StatefulWidget {
  final VoidCallback onBack;
  const RomanNumeralsConverterView({super.key, required this.onBack});

  @override
  State<RomanNumeralsConverterView> createState() => _RomanNumeralsConverterViewState();
}

class _RomanNumeralsConverterViewState extends State<RomanNumeralsConverterView> {
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color textGrey = const Color(0xFFDBC2AD);

  bool _isHapticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadHaptics();
  }

  Future<void> _loadHaptics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- APP BAR ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionButton(
                icon: Icons.arrow_back_ios_new_rounded,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {
                  if (_isHapticsEnabled) HapticFeedback.lightImpact();
                  widget.onBack();
                },
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Roman Numerals',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ActionButton(
                icon: Icons.star_border_rounded,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {
                  if (_isHapticsEnabled) HapticFeedback.selectionClick();
                },
              ),
            ],
          ),
        ),

        // --- SAMPLE TEXT (COMING SOON) ---
        const Expanded(
          child: Center(
            child: Text(
              'Roman Numerals UI Coming Soon...',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}