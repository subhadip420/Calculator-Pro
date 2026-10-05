import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';

class PercentageCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const PercentageCalculatorView({super.key, required this.onBack});

  @override
  State<PercentageCalculatorView> createState() => _PercentageCalculatorViewState();
}

class _PercentageCalculatorViewState extends State<PercentageCalculatorView> {
  bool _isHapticsEnabled = true;

  // Default selection set to 'percent_from_a_to_b'
  String selectedCalcType = 'percent_from_a_to_b';
  bool _showExample = false;

  String _resultVal1 = '--';
  String _resultVal2 = '--';

  // Input Controllers for A and B values
  final TextEditingController _input1Controller = TextEditingController();
  final TextEditingController _input2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _input1Controller.addListener(_performCalculation);
    _input2Controller.addListener(_performCalculation);
  }

  @override
  void dispose() {
    _input1Controller.dispose();
    _input2Controller.dispose();
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

  void _onTypeSelect(String typeId) {
    if (_isHapticsEnabled) HapticFeedback.selectionClick();

    _input1Controller.clear();
    _input2Controller.clear();

    setState(() {
      selectedCalcType = typeId;
      _showExample = false; // NAYA: Type badalte hi example reset ho jayega
      _resultVal1 = '--';
      _resultVal2 = '--';
    });
  }

  // --- NAYA FUNCTION: Real Calculations ---
  void _performCalculation() {
    String text1 = _input1Controller.text.trim();
    String text2 = _input2Controller.text.trim();

    double? valA = double.tryParse(text1);
    double? valB = double.tryParse(text2);

    setState(() {
      if (valA == null || valB == null) {
        _resultVal1 = '--';
        _resultVal2 = '--';
        return;
      }

      if (selectedCalcType == 'discount') {
        // Formula: A - (A * B / 100) = Final Value
        double discountAmount = valA * (valB / 100);
        double finalValue = valA - discountAmount;
        _resultVal1 = _formatResult(finalValue);
        _resultVal2 = _formatResult(discountAmount);
      } else if (selectedCalcType == 'increase') {
        // Formula: A + (A * B / 100) = Final Value
        double increaseAmount = valA * (valB / 100);
        double finalValue = valA + increaseAmount;
        _resultVal1 = _formatResult(finalValue);
        _resultVal2 = _formatResult(increaseAmount);
      } else if (selectedCalcType == 'percent_from_a_to_b') {
        // Formula: ((B - A) / A) * 100 = Percentage change
        if (valA == 0) {
          _resultVal1 = 'N/A'; // Cannot divide by zero
        } else {
          double change = ((valB - valA) / valA) * 100;
          // Format with sign for clarity (e.g. +20% or -10%)
          _resultVal1 = (change >= 0 ? '+' : '') + _formatResult(change) + '%';
        }
      } else if (selectedCalcType == 'percent_of_a_from_b') {
        // Formula: (A / B) * 100 = Percentage
        if (valB == 0) {
          _resultVal1 = 'N/A';
        } else {
          double percent = (valA / valB) * 100;
          _resultVal1 = _formatResult(percent) + '%';
        }
      }
    });
  }

  // Helper method: Numbers ko properly format karne ke liye (e.g. 10.0 -> 10, 10.1234 -> 10.12)
  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString(); // Agar whole number hai, toh decimal hata do
    }
    return value.toStringAsFixed(2); // Varna 2 decimal places tak dikhao
  }

  // --- HELPER: 2x2 Grid Option Card ---
  Widget _buildOptionCard({
    required String id,
    required String title,
    required String formula,
    required IconData icon,
  }) {
    bool isSelected = selectedCalcType == id;

    return GestureDetector(
      onTap: () => _onTypeSelect(id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cyanColor(context).withOpacity(0.1)
              : AppColors.surfaceColor(context).withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.cyanColor(context) : Colors.white.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? AppColors.cyanColor(context) : AppColors.textGrey(context), size: 22),
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

  // --- HELPER: Dynamic Input Column ---
  Widget _buildInputCol(String label, TextEditingController controller, {String hint = '--', bool isPercent = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textColor(context), fontSize: 22, fontWeight: FontWeight.bold),
                    cursorColor: AppColors.cyanColor(context),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.4), fontSize: 22),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                if (isPercent)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text('%', style: TextStyle(color: AppColors.textGrey(context), fontSize: 20)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: Result Row ---
  Widget _buildResultRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- MAIN DYNAMIC UI BUILDER ---
  Widget _buildDynamicUI() {
    String label1 = '';
    String label2 = '';
    String hint1 = '';
    String hint2 = '';
    bool isPercent2 = false;
    Widget middleSymbol = const SizedBox();

    String description = '';
    String example = ''; // NAYA: Example text store karne ke liye
    List<Widget> resultRows = [];
    if (selectedCalcType == 'discount') {
      label1 = 'Value';
      label2 = 'Discount';
      hint1 = '--';
      hint2 = '--';
      isPercent2 = true;
      middleSymbol = Text(
        '-',
        style: TextStyle(color: AppColors.textColor(context), fontSize: 28, fontWeight: FontWeight.w400),
      );
      description = 'A reduction of a value by a given percent';
      example = 'Example: A 25% discount on 100 is equal to 75';
      resultRows = [
        _buildResultRow('Final value', _resultVal1), // NAYA
        _buildResultRow('Discount', _resultVal2, isLast: true), // NAYA
      ];
    } else if (selectedCalcType == 'increase') {
      label1 = 'Value';
      label2 = 'Increase';
      hint1 = '--';
      hint2 = '--';
      isPercent2 = true;
      middleSymbol = Text(
        '+',
        style: TextStyle(color: AppColors.textColor(context), fontSize: 28, fontWeight: FontWeight.w400),
      );
      description = 'An increase of a value by a given percent';
      example = 'Example: A 25% increase on 100 is equal to 125';
      resultRows = [
        _buildResultRow('Final value', _resultVal1), // NAYA
        _buildResultRow('Increase', _resultVal2, isLast: true), // NAYA
      ];
    } else if (selectedCalcType == 'percent_from_a_to_b') {
      label1 = 'From';
      label2 = 'To';
      hint1 = 'A';
      hint2 = 'B';
      middleSymbol = Icon(Icons.arrow_forward_rounded, color: AppColors.textColor(context), size: 28);
      description = 'The percentual change when going from value A to value B';
      example = 'Example: From 25 to 100 there is a 300% increase';
      resultRows = [_buildResultRow('Percent', _resultVal1, isLast: true)]; // NAYA
    } else if (selectedCalcType == 'percent_of_a_from_b') {
      label1 = 'Value';
      label2 = 'From';
      hint1 = 'A';
      hint2 = 'B';
      middleSymbol = Icon(Icons.arrow_back_rounded, color: AppColors.textColor(context), size: 28);
      description = 'The percent of value A from value B';
      example = 'Example: 25 is 25% of 100';
      resultRows = [_buildResultRow('Percent', _resultVal1, isLast: true)]; // NAYA
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Inputs Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildInputCol(label1, _input1Controller, hint: hint1),
            Padding(padding: const EdgeInsets.only(bottom: 16.0, left: 16, right: 16), child: middleSymbol),
            _buildInputCol(label2, _input2Controller, hint: hint2, isPercent: isPercent2),
          ],
        ),
        const SizedBox(height: 24),

        // 2. Description & Example Section (Yahan changes kiye gaye hain)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _showExample ? example : description, // Toggle ke hisaab se text dikhega
                style: TextStyle(
                  color: _showExample ? AppColors.cyanColor(context) : AppColors.textColor(context),
                  fontSize: 14,
                  fontStyle: _showExample
                      ? FontStyle.italic
                      : FontStyle.normal, // Example ko italic bhi kar diya taaki alag lage
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
                padding: const EdgeInsets.only(left: 10, bottom: 10), // Click area badhane ke liye thodi padding
                child: Icon(
                  _showExample ? Icons.help_rounded : Icons.help_outline_rounded, // Icon fill/unfill hoga
                  color: _showExample
                      ? AppColors.cyanColor(context)
                      : AppColors.textGrey(context), // Color bhi change hoga
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 3. Result Section
        Text(
          'Result',
          style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context).withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(children: resultRows),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          CustomTopBar(
            toolId: 'percentage',
            title: 'Percentage',
            iconPath: 'assets/images/percentage.png',
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
                  Text(
                    'Calculation Type',
                    style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // 2x2 GRID
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionCard(
                          id: 'discount',
                          title: 'Discount',
                          formula: 'a - x% = b',
                          icon: Icons.local_offer_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionCard(
                          id: 'increase',
                          title: 'Increase',
                          formula: 'a + x% = b',
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionCard(
                          id: 'percent_from_a_to_b',
                          title: 'Percent from\nA to B',
                          formula: 'a → b = x%',
                          icon: Icons.arrow_forward_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionCard(
                          id: 'percent_of_a_from_b',
                          title: 'Percent of A\nfrom B',
                          formula: 'a ← b = x%',
                          icon: Icons.arrow_back_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // DYNAMIC UI CALL
                  _buildDynamicUI(),

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
