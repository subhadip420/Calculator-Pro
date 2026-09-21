import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'action_button.dart'; // Apna custom ActionButton import kiya

class LengthConverterView extends StatefulWidget {
  final VoidCallback onBack; // Wapas main menu jane ke liye callback

  const LengthConverterView({super.key, required this.onBack});

  @override
  State<LengthConverterView> createState() => _LengthConverterViewState();
}

class _LengthConverterViewState extends State<LengthConverterView> {
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
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
        // --- 1. TOP BAR ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // Back Button (Wapas Main Menu jane ke liye)
              ActionButton(
                icon: Icons.arrow_back_ios_new_rounded,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {
                  if (_isHapticsEnabled) HapticFeedback.lightImpact();
                  widget.onBack(); // Callback call kiya
                },
              ),
              const SizedBox(width: 16),

              // Title
              const Expanded(
                child: Text(
                  'Length Converter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- 2. MAIN BODY (Baad mein design karenge) ---
        Expanded(
          child: Center(
            child: Text(
              'Length Layout\n(Baki UI baad mein aayega)',
              textAlign: TextAlign.center,
              style: TextStyle(color: textGrey.withOpacity(0.5), fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}