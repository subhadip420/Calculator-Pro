import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_action_button.dart';

class PressureConverterView extends StatefulWidget {
  final VoidCallback onBack;
  const PressureConverterView({super.key, required this.onBack});

  @override
  State<PressureConverterView> createState() => _PressureConverterViewState();
}

class _PressureConverterViewState extends State<PressureConverterView> {
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
        // --- 1. TOP BAR ---
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
                    'Pressure Conversion',
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

        // --- 2. TEMPORARY PLACEHOLDER ---
        const Expanded(
          child: Center(
            child: Text(
              'Pressure UI Coming Soon...',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}