import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';

class BodiesView extends StatefulWidget {
  final VoidCallback onBack;

  const BodiesView({super.key, required this.onBack});

  @override
  State<BodiesView> createState() => _BodiesViewState();
}

class _BodiesViewState extends State<BodiesView> {
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
            toolId: 'bodies',
            title: 'Bodies',
            iconPath: 'assets/images/percentage-discount-symbol.png', // Ise baad mein 3D shape icon se replace kar lena
            onBack: widget.onBack,
            isHapticsEnabled: _isHapticsEnabled,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.view_in_ar_rounded, // 3D box icon
                    size: 64,
                    color: AppColors.cyanColor(context).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bodies Calculator',
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