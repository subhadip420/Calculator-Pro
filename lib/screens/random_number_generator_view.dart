import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math; // Random logic ke liye

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

  // Controllers
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // State Variables
  bool _isUnique = true; // Default: Unique numbers (no repeat)
  bool _showGenerateBtn = false;
  List<int> _generatedNumbers = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // NAYA: Real-time calculation ke liye listeners
    _countController.addListener(_generateNumbers);
    _fromController.addListener(_generateNumbers);
    _toController.addListener(_generateNumbers);
  }

  @override
  void dispose() {
    _countController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
      });
    }
  }

  // --- MATH HELPER: Real-time Number Generation ---
  void _generateNumbers() {
    int? count = int.tryParse(_countController.text.trim());
    int? min = int.tryParse(_fromController.text.trim());
    int? max = int.tryParse(_toController.text.trim());

    // Agar koi bhi field khali hai ya count 0 hai, toh result hide kar do
    if (count == null || min == null || max == null || count <= 0) {
      setState(() {
        _generatedNumbers = [];
        _showGenerateBtn = false;
      });
      return;
    }

    // Min aur Max ko properly handle karna (agar user galti se From > To daal de)
    int actualMin = math.min(min, max);
    int actualMax = math.max(min, max);
    int range = actualMax - actualMin + 1;

    List<int> results = [];
    math.Random random = math.Random();

    if (_isUnique) {
      // UNIQUE Logic (No repeats)
      // Safety: Agar range kam hai aur count zyada, toh count ko range tak limit kar do
      int safeCount = math.min(count, range);
      Set<int> uniqueSet = {};
      while (uniqueSet.length < safeCount) {
        uniqueSet.add(actualMin + random.nextInt(range));
      }
      results = uniqueSet.toList();
    } else {
      // ALLOW REPEATS Logic
      for (int i = 0; i < count; i++) {
        results.add(actualMin + random.nextInt(range));
      }
    }

    setState(() {
      _generatedNumbers = results;
      _showGenerateBtn = true; // Sab input valid hain toh button dikhao
    });
  }

  // --- WIDGET HELPER: Custom Input Box ---
  Widget _buildInputBox(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.textColor(context), fontSize: 20, fontWeight: FontWeight.bold),
      cursorColor: AppColors.cyanColor(context),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.4), fontSize: 20),
        filled: true,
        fillColor: AppColors.surfaceColor(context).withOpacity(0.7),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.textGrey(context).withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.cyanColor(context), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // NAYA: Screen ke bahar click karne par keyboard hide hoga
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            // --- 1. TOP BAR ---
            CustomTopBar(
              toolId: 'random_number',
              title: 'Random Number',
              iconPath: 'assets/images/random_number.png',
              // Temporary
              onBack: widget.onBack,
              isHapticsEnabled: _isHapticsEnabled,
            ),

            // --- 2. MAIN SCROLL VIEW ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- COUNT SECTION ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Count',
                                style: TextStyle(
                                  color: AppColors.textColor(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'How many numbers to generate?',
                                style: TextStyle(color: AppColors.textGrey(context), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 120, // Count box ki fixed width
                          child: _buildInputBox('--', _countController),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- RANGE SECTION (From / To) ---
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From (Minimum)',
                                style: TextStyle(
                                  color: AppColors.textColor(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInputBox('Min', _fromController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To (Maximum)',
                                style: TextStyle(
                                  color: AppColors.textColor(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInputBox('Max', _toController),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- REPEAT TOGGLE SECTION ---
                    // --- REPEAT TOGGLE SECTION (Card View) ---
                    GestureDetector(
                      onTap: () {
                        if (_isHapticsEnabled) HapticFeedback.lightImpact();
                        setState(() {
                          _isUnique =
                              !_isUnique; // Variable name wahi hai, bas iska matlab ab 'Allow Repeat' ho gaya hai
                        });
                        _generateNumbers(); // Toggle hote hi naya result aaye
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Card ke andar padding
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor(context).withOpacity(0.3), // Card background color
                          borderRadius: BorderRadius.circular(16), // Rounded corners
                          border: Border.all(color: Colors.white.withOpacity(0.05)), // Subtle border
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title update kar diya taaki checked hone par sense bane
                                  Text(
                                    'Allow Repeats',
                                    style: TextStyle(
                                      color: AppColors.textColor(context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Subtitle dynamically updates (Condition ulta kar diya)
                                  Text(
                                    _isUnique ? 'Generated numbers can repeat' : 'All generated numbers will be unique',
                                    style: TextStyle(color: AppColors.textGrey(context), fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            // Custom Premium Checkbox/Switch Style
                            Icon(
                              _isUnique ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              color: _isUnique ? AppColors.cyanColor(context) : AppColors.textGrey(context),
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- GENERATE ACTION ROW ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Generate one or more numbers',
                                  style: TextStyle(color: AppColors.textColor(context), fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Generate Button - Sirf tab dikhega jab inputs valid honge
                        AnimatedOpacity(
                          opacity: _showGenerateBtn ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: IgnorePointer(
                            ignoring: !_showGenerateBtn, // Hide hone pe click disable ho jaye
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_isHapticsEnabled) HapticFeedback.selectionClick();
                                _generateNumbers(); // Same input pe fresh random numbers dega
                                FocusScope.of(context).unfocus(); // Click pe keyboard hide
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                              label: const Text('Generate', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cyanColor(context).withOpacity(0.15),
                                foregroundColor: AppColors.cyanColor(context),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: AppColors.cyanColor(context).withOpacity(0.5)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- RESULT SECTION ---
                    Text(
                      'Result',
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.textGrey(context).withOpacity(0.5)),
                      ),
                      child: _generatedNumbers.isEmpty
                          ? Center(
                              child: Text(
                                'Awaiting valid inputs...',
                                style: TextStyle(color: AppColors.textGrey(context).withOpacity(0.6), fontSize: 16),
                              ),
                            )
                          : Wrap(
                              spacing: 12, // Horizontal gap between numbers
                              runSpacing: 12, // Vertical gap between lines
                              children: _generatedNumbers.map((num) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceColor(context),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    num.toString(),
                                    style: TextStyle(
                                      color: AppColors.cyanColor(context),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),

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
}
