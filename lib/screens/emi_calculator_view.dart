import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';
import '../custom_top_bar.dart';

class EmiCalculatorView extends StatefulWidget {
  final VoidCallback onBack;
  const EmiCalculatorView({super.key, required this.onBack});
  @override
  State<EmiCalculatorView> createState() => _EmiCalculatorViewState();
}
class _EmiCalculatorViewState extends State<EmiCalculatorView> {
  bool _isHapticsEnabled = true;
  @override
  void initState() { super.initState(); _loadSettings(); }
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          CustomTopBar(toolId: 'emi', title: 'EMI Calculator', iconPath: 'assets/images/percentage-discount-symbol.png', onBack: widget.onBack, isHapticsEnabled: _isHapticsEnabled),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.real_estate_agent_rounded, size: 64, color: AppColors.cyanColor(context).withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('EMI Calculator', style: TextStyle(color: AppColors.textColor(context), fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('UI Design Coming Soon...', style: TextStyle(color: AppColors.textGrey(context), fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}