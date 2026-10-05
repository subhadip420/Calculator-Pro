import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';

class RatioCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const RatioCalculatorView({super.key, required this.onBack});

  @override
  State<RatioCalculatorView> createState() => _RatioCalculatorViewState();
}

class _RatioCalculatorViewState extends State<RatioCalculatorView> {
  bool _isHapticsEnabled = true;

  // Default method selection
  String selectedMethod = 'reduction';
  bool _showExample = false;
  bool _isCalculating = false;

  // --- NAYA: Input Controllers (A, B, X, Y) ---
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();

  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
  int _gcd(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a.abs();
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _aController.addListener(() => _performCalculation('A'));
    _bController.addListener(() => _performCalculation('B'));
    _xController.addListener(() => _performCalculation('X'));
    _yController.addListener(() => _performCalculation('Y'));
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _xController.dispose();
    _yController.dispose();
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



  // --- LOGIC: Option Select ---
  void _onMethodSelect(String method) {
    if (_isHapticsEnabled) HapticFeedback.selectionClick();

    // Method change hone par inputs clear karein
    _aController.clear();
    _bController.clear();
    _xController.clear();
    _yController.clear();

    _isCalculating = true;
    _aController.clear();
    _bController.clear();
    _xController.clear();
    _yController.clear();
    _isCalculating = false;

    setState(() {
      selectedMethod = method;
      _showExample = false;
    });
  }

  // --- LOGIC: Real-time Ratio Calculation ---
  void _performCalculation(String source) {
    if (_isCalculating) return; // Agar program khud text change kar raha hai, toh loop break karo

    setState(() {
      _isCalculating = true;

      if (selectedMethod == 'reduction') {
        // --- REDUCTION LOGIC (A/B ko simplify karke X/Y banana) ---
        if (source == 'A' || source == 'B') {
          int? a = int.tryParse(_aController.text.trim());
          int? b = int.tryParse(_bController.text.trim());

          if (a != null && b != null && a > 0 && b > 0) {
            int gcd = _gcd(a, b);
            _xController.text = (a ~/ gcd).toString();
            _yController.text = (b ~/ gcd).toString();
          } else {
            // Agar numbers proper nahi hain, toh X Y khali rakhein
            _xController.clear();
            _yController.clear();
          }
        }
      } else {
        // --- DEDUCTION LOGIC (Cross Multiplication) ---
        double? x = double.tryParse(_xController.text.trim());
        double? y = double.tryParse(_yController.text.trim());

        if (x != null && y != null && x != 0) {
          if (source == 'A') {
            // Agar user ne A dala hai, toh B nikalenge: B = (Y * A) / X
            double? a = double.tryParse(_aController.text.trim());
            if (a != null) {
              double b = (y * a) / x;
              _bController.text = _formatResult(b);
            } else {
              _bController.clear();
            }
          } else if (source == 'B') {
            // Agar user ne B dala hai, toh A nikalenge: A = (X * B) / Y
            double? b = double.tryParse(_bController.text.trim());
            if (b != null && y != 0) {
              double a = (x * b) / y;
              _aController.text = _formatResult(a);
            } else {
              _aController.clear();
            }
          } else if (source == 'X' || source == 'Y') {
            // Agar base ratio (X ya Y) change kiya, toh existing A ke hisaab se B update karo
            double? a = double.tryParse(_aController.text.trim());
            if (a != null) {
              double b = (y * a) / x;
              _bController.text = _formatResult(b);
            }
          }
        }
      }

      _isCalculating = false;
    });
  }

  // --- HELPER: Option Card ---
  Widget _buildOptionCard({
    required String id,
    required String title,
    required String formula,
    required IconData icon,
  }) {
    bool isSelected = selectedMethod == id;

    return GestureDetector(
      onTap: () => _onMethodSelect(id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cyanColor(context).withOpacity(0.1)
              : AppColors.surfaceColor(context).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.cyanColor(context)
                : AppColors.textGrey(context).withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.cyanColor(context) : AppColors.textGrey(context),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppColors.cyanColor(context) : AppColors.textColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formula,
                    style: TextStyle(
                      color: isSelected ? AppColors.textGrey(context) : AppColors.textGrey(context).withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: Naya Widget 2 Input Boxes ke liye beech mein colon (:) ke sath ---
  Widget _buildRatioRow(String label, String hint1, String hint2, TextEditingController c1, TextEditingController c2, {bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: c1,
                readOnly: isReadOnly, // --- NAYA FIX ---
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textColor(context), fontSize: 24, fontWeight: FontWeight.bold),
                cursorColor: AppColors.cyanColor(context),
                decoration: InputDecoration(
                  hintText: hint1,
                  hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.4), fontSize: 24),
                  filled: true,
                  fillColor: AppColors.surfaceColor(context).withOpacity(0.7),
                  contentPadding: const EdgeInsets.symmetric(vertical: 24),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.textGrey(context).withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.cyanColor(context), width: 1.5),
                  ),
                ),
              ),
            ),

            // Beech ka Colon (:)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                  ':',
                  style: TextStyle(color: AppColors.textGrey(context), fontSize: 28, fontWeight: FontWeight.bold)
              ),
            ),

            // Dusra Input Box (B ya Y)
            Expanded(
              child: TextField(
                controller: c2,
                readOnly: isReadOnly,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textColor(context), fontSize: 24, fontWeight: FontWeight.bold),
                cursorColor: AppColors.cyanColor(context),
                decoration: InputDecoration(
                  hintText: hint2,
                  hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.4), fontSize: 24),
                  filled: true,
                  fillColor: AppColors.surfaceColor(context).withOpacity(0.7),
                  contentPadding: const EdgeInsets.symmetric(vertical: 24),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.textGrey(context).withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.cyanColor(context), width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String description = '';
    String example = '';

    if (selectedMethod == 'reduction') {
      description = 'Find the ratio of two values';
      example = 'Example: For a 1920 by 1080 resolution, the ratio is equal to 16:9';
    } else {
      description = 'Find the missing value based on a ratio';
      example = 'Example: For a 4:3 ratio if one value is 800 the other will be 600';
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          CustomTopBar(
            toolId: 'ratio',
            title: 'Ratio Calculator',
            iconPath: 'assets/images/percentage-discount-symbol.png',
            onBack: widget.onBack,
            isHapticsEnabled: _isHapticsEnabled,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Method', style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _buildOptionCard(id: 'reduction', title: 'Reduction', formula: 'a/b → x/y', icon: Icons.compress_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildOptionCard(id: 'deduction', title: 'Deduction', formula: 'x/y → a/b', icon: Icons.expand_rounded)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _showExample ? example : description,
                          style: TextStyle(
                            color: _showExample ? AppColors.cyanColor(context) : AppColors.textColor(context),
                            fontSize: 14,
                            fontStyle: _showExample ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_isHapticsEnabled) HapticFeedback.lightImpact();
                          setState(() {
                            _showExample = !_showExample;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(left: 10, bottom: 10),
                          child: Icon(
                            _showExample ? Icons.help_rounded : Icons.help_outline_rounded,
                            color: _showExample ? AppColors.cyanColor(context) : AppColors.textGrey(context),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- NAYA UI: DYNAMIC RATIO BOXES ---
                  if (selectedMethod == 'reduction') ...[
                    // Reduction View: Values Upar, Ratio Neeche
                    _buildRatioRow('Values', 'A', 'B', _aController, _bController),
                    const SizedBox(height: 24),
                    // NAYA FIX: Reduction mein X aur Y sirf Output hain, isliye keyboard open nahi hoga
                    _buildRatioRow('Ratio', 'X', 'Y', _xController, _yController, isReadOnly: true),
                  ] else ...[
                    // Deduction View: Ratio Upar, Values Neeche
                    _buildRatioRow('Ratio', 'X', 'Y', _xController, _yController),
                    const SizedBox(height: 24),
                    _buildRatioRow('Values', 'A', 'B', _aController, _bController),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}