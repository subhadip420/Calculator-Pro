import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_action_button.dart';
import '../custom_top_bar.dart'; // Apna correct path check kar lena

class ShoeSizeConverterView extends StatefulWidget {
  final VoidCallback onBack;
  const ShoeSizeConverterView({super.key, required this.onBack});

  @override
  State<ShoeSizeConverterView> createState() => _ShoeSizeConverterViewState();
}

class _ShoeSizeConverterViewState extends State<ShoeSizeConverterView> {
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
        CustomTopBar(
          toolId: 'shoe_size',
          title: 'Shoe Size',
          iconPath: 'assets/images/shoe_size.png',
          onBack: widget.onBack,
          isHapticsEnabled: _isHapticsEnabled,
        ),


        // --- SAMPLE TEXT (COMING SOON) ---
        const Expanded(
          child: Center(
            child: Text(
              'Shoe Size UI Coming Soon...',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}