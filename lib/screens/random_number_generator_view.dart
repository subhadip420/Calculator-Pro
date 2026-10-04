import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';

class RandomNumberGeneratorView extends StatefulWidget {
  final VoidCallback onBack;

  const RandomNumberGeneratorView({super.key, required this.onBack});

  @override
  State<RandomNumberGeneratorView> createState() => _RandomNumberGeneratorViewState();
}

class _RandomNumberGeneratorViewState extends State<RandomNumberGeneratorView> {
  bool _isHapticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // --- 1. TOP BAR ---
          CustomTopBar(
            toolId: 'random_number',
            title: 'Random Number',
            iconPath: 'assets/images/percentage-discount-symbol.png', // Temporary icon
            onBack: widget.onBack,
            isHapticsEnabled: _isHapticsEnabled,
          ),

          // --- 2. DEMO BODY (Aage ka UI yahan aayega) ---
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.casino_rounded, // Random/Dice ke liye mast icon
                    size: 64,
                    color: AppColors.cyanColor(context).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Random Number Generator',
                    style: TextStyle(
                      color: AppColors.textColor(context),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UI Design Coming Soon...',
                    style: TextStyle(
                      color: AppColors.textGrey(context),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}