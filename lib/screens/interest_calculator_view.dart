import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';

class InterestCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const InterestCalculatorView({super.key, required this.onBack});

  @override
  State<InterestCalculatorView> createState() => _InterestCalculatorViewState();
}

class _InterestCalculatorViewState extends State<InterestCalculatorView> {
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
          CustomTopBar(
            toolId: 'interest',
            title: 'Interest Calculator',
            iconPath: 'assets/images/percentage-discount-symbol.png', // Ise baad mein finance icon se replace kar lena
            onBack: widget.onBack,
            isHapticsEnabled: _isHapticsEnabled,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_rounded, // Piggy bank/Savings icon
                    size: 64,
                    color: AppColors.cyanColor(context).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Interest Calculator',
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