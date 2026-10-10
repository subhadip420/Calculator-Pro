import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_toast.dart';
import '../custom_top_bar.dart';
import '../widgets/custom_ruler_slider_card.dart';
import '../widgets/percentage_slider_card.dart';

class InterestCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const InterestCalculatorView({super.key, required this.onBack});

  @override
  State<InterestCalculatorView> createState() => _InterestCalculatorViewState();
}

class _InterestCalculatorViewState extends State<InterestCalculatorView> {
  final ScrollController _scrollController = ScrollController();
  bool _showStickyResult = true;
  bool _isHapticsEnabled = true;

  // State Variables
  String _interestType = 'simple'; // 'simple' or 'compound'
  double _amountValue = 100000; // Default Deposit Amount
  double _interestRateValue = 12.0; // Default Interest Rate
  String _tenureUnit = 'year'; // Default unit

  final TextEditingController _tenureController = TextEditingController(text: '5');
  double _tenureValue = 5.0;

  // --- REAL-TIME MATH LOGIC ---
  Map<String, double> _getCalculatedValues() {
    double p = _amountValue;
    double r = _interestRateValue;
    double t = _tenureUnit == 'year' ? _tenureValue : _tenureValue / 12.0;

    if (p == 0 || t == 0) return {'invested': p, 'returns': 0, 'total': p};

    double total = 0;
    double returns = 0;

    if (_interestType == 'simple') {
      // Simple Interest Formula: (P * R * T) / 100
      returns = (p * r * t) / 100;
      total = p + returns;
    } else {
      // Compound Interest Formula (Annually Compounded): P * (1 + R/100)^T
      total = p * pow(1 + (r / 100), t);
      returns = total - p;
    }

    if (returns < 0) returns = 0;

    return {'invested': p, 'returns': returns, 'total': total};
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Scroll Listener for Sticky Bar
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent > 0 &&
          _scrollController.offset >= _scrollController.position.maxScrollExtent - 250) {
        if (_showStickyResult) {
          setState(() => _showStickyResult = false);
        }
      } else {
        if (!_showStickyResult) {
          setState(() => _showStickyResult = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _tenureController.dispose();
    _scrollController.dispose();
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

  // --- HELPER TO BUILD RESULT ROWS ---
  Widget _buildResultRow(String label, double value, {bool isHighlighted = false, Color? valueColor}) {
    String formattedValue = value.toStringAsFixed(0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isHighlighted ? AppColors.textColor(context) : AppColors.textGrey(context),
              fontSize: isHighlighted ? 18 : 15,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '₹$formattedValue',
              style: TextStyle(
                color: valueColor ?? (isHighlighted ? AppColors.cyanColor(context) : AppColors.textColor(context)),
                fontSize: isHighlighted ? 22 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _getCalculatedValues();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            CustomTopBar(
              toolId: 'interest',
              title: 'Interest Calculator',
              iconPath: 'assets/images/percentage-discount-symbol.png',
              onBack: widget.onBack,
              isHapticsEnabled: _isHapticsEnabled,
            ),

            // --- MAIN SCROLL VIEW & STICKY BAR ---
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. INTEREST TYPE SELECTOR ---
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor(context).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Interest Type',
                                style: TextStyle(
                                  color: AppColors.textColor(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.bgColor(context).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    // Simple Interest
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                          setState(() => _interestType = 'simple');
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Row(
                                          children: [
                                            Icon(
                                              _interestType == 'simple'
                                                  ? Icons.radio_button_checked_rounded
                                                  : Icons.radio_button_off_rounded,
                                              color: _interestType == 'simple'
                                                  ? AppColors.cyanColor(context)
                                                  : AppColors.textGrey(context),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Simple',
                                                style: TextStyle(
                                                  color: _interestType == 'simple'
                                                      ? AppColors.textColor(context)
                                                      : AppColors.textGrey(context),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Compound Interest
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                          setState(() => _interestType = 'compound');
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Row(
                                          children: [
                                            Icon(
                                              _interestType == 'compound'
                                                  ? Icons.radio_button_checked_rounded
                                                  : Icons.radio_button_off_rounded,
                                              color: _interestType == 'compound'
                                                  ? AppColors.cyanColor(context)
                                                  : AppColors.textGrey(context),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Compound',
                                                style: TextStyle(
                                                  color: _interestType == 'compound'
                                                      ? AppColors.textColor(context)
                                                      : AppColors.textGrey(context),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- 2. DEPOSIT AMOUNT RULER ---
                        CustomRulerSliderCard(
                          title: 'Deposit Amount',
                          subtitle: 'Principal',
                          symbol: '₹',
                          currentValue: _amountValue,
                          min: 0,
                          max: 10000000,
                          // 1 Crore max
                          isHapticsEnabled: _isHapticsEnabled,
                          onChanged: (val) {
                            setState(() {
                              _amountValue = val;
                            });
                          },
                        ),
                        const SizedBox(height: 15),

                        // --- 3. INTEREST RATE SLIDER ---
                        PercentageSliderCard(
                          title: 'Interest Rate',
                          currentValue: _interestRateValue,
                          onChanged: (val) {
                            setState(() {
                              _interestRateValue = val;
                            });
                          },
                        ),
                        const SizedBox(height: 15),

                        // --- 4. TENURE CARD ---
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor(context).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Tenure Type',
                                    style: TextStyle(
                                      color: AppColors.textColor(context),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Year Radio
                                  GestureDetector(
                                    onTap: () {
                                      if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                      setState(() {
                                        _tenureUnit = 'year';
                                        if (_tenureValue > 50) {
                                          _tenureValue = 50;
                                          _tenureController.text = '50';
                                        }
                                      });
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _tenureUnit == 'year'
                                              ? Icons.radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: _tenureUnit == 'year'
                                              ? AppColors.cyanColor(context)
                                              : AppColors.textGrey(context),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Year',
                                          style: TextStyle(
                                            color: _tenureUnit == 'year'
                                                ? AppColors.textColor(context)
                                                : AppColors.textGrey(context),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Month Radio
                                  GestureDetector(
                                    onTap: () {
                                      if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                      setState(() {
                                        _tenureUnit = 'month';
                                      });
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _tenureUnit == 'month'
                                              ? Icons.radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: _tenureUnit == 'month'
                                              ? AppColors.cyanColor(context)
                                              : AppColors.textGrey(context),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Month',
                                          style: TextStyle(
                                            color: _tenureUnit == 'month'
                                                ? AppColors.textColor(context)
                                                : AppColors.textGrey(context),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Divider(
                                  color: AppColors.textGrey(context).withOpacity(0.5),
                                  thickness: 1,
                                  height: 1,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Duration', style: TextStyle(color: AppColors.textGrey(context), fontSize: 15)),
                                  Container(
                                    width: 140,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: AppColors.bgColor(context).withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _tenureController,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.textColor(context),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            cursorColor: AppColors.cyanColor(context),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                            ),
                                            onChanged: (val) {
                                              double? newVal = double.tryParse(val.replaceAll(',', ''));
                                              if (newVal != null && newVal >= 0) {
                                                double maxLimit = _tenureUnit == 'year' ? 50 : 600;
                                                String limitText = maxLimit.toInt().toString();

                                                if (newVal > maxLimit) {
                                                  newVal = maxLimit;
                                                  _tenureController.value = TextEditingValue(
                                                    text: limitText,
                                                    selection: TextSelection.collapsed(offset: limitText.length),
                                                  );
                                                  String timeUnit = _tenureUnit == 'year' ? 'years' : 'months';
                                                  showCustomToast(
                                                    context,
                                                    'Maximum duration can be $limitText $timeUnit',
                                                  );
                                                }
                                                setState(() => _tenureValue = newVal!);
                                              }
                                            },
                                          ),
                                        ),
                                        Container(
                                          width: 55,
                                          decoration: BoxDecoration(
                                            color: AppColors.cyanColor(context).withOpacity(0.1),
                                            borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(11),
                                              bottomRight: Radius.circular(11),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _tenureUnit == 'year' ? 'Year' : 'Month',
                                            style: TextStyle(
                                              color: AppColors.cyanColor(context).withOpacity(0.9),
                                              fontSize: _tenureUnit == 'year' ? 16 : 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- 5. RESULT CARD ---
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.cyanColor(context).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.5), width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'Calculation Result',
                                  style: TextStyle(
                                    color: AppColors.cyanColor(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              _buildResultRow('Principal Amount', results['invested']!),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                              ),

                              _buildResultRow(
                                'Total Interest',
                                results['returns']!,
                                valueColor: AppColors.greenColor(context),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                              ),

                              _buildResultRow('Maturity Amount', results['total']!, isHighlighted: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- 6. COPY & SHARE BUTTONS ---
                        Row(
                          children: [
                            // 1. COPY BUTTON
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (_isHapticsEnabled) HapticFeedback.selectionClick();

                                  String typeLabel = _interestType == 'simple'
                                      ? 'Simple Interest'
                                      : 'Compound Interest';
                                  String tenureText =
                                      "${_tenureValue.toStringAsFixed(0)} ${_tenureUnit == 'year' ? 'Years' : 'Months'}";

                                  String copyText =
                                      "Interest Calculation Result\n\n"
                                      "Interest Type: $typeLabel\n"
                                      "Principal Amount: ₹${_amountValue.toStringAsFixed(0)}\n"
                                      "Interest Rate: ${_interestRateValue.toStringAsFixed(1)}%\n"
                                      "Duration: $tenureText\n\n"
                                      "Total Interest: ₹${results['returns']!.toStringAsFixed(0)}\n"
                                      "Maturity Amount: ₹${results['total']!.toStringAsFixed(0)}";

                                  Clipboard.setData(ClipboardData(text: copyText));
                                  showCustomToast(context, 'Result Copied!');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceColor(context).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.textGrey(context)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.copy_rounded, color: AppColors.textGrey(context), size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Copy",
                                        style: TextStyle(
                                          color: AppColors.textColor(context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),

                            // 2. SHARE BUTTON
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (_isHapticsEnabled) HapticFeedback.selectionClick();

                                  String typeLabel = _interestType == 'simple'
                                      ? 'Simple Interest'
                                      : 'Compound Interest';
                                  String tenureText =
                                      "${_tenureValue.toStringAsFixed(0)} ${_tenureUnit == 'year' ? 'Years' : 'Months'}";

                                  String shareText =
                                      "Hey! Check my Interest Calculation\n\n"
                                      "Interest Type: $typeLabel\n"
                                      "Principal Amount: ₹${_amountValue.toStringAsFixed(0)}\n"
                                      "Interest Rate: ${_interestRateValue.toStringAsFixed(1)}%\n"
                                      "Duration: $tenureText\n\n"
                                      "Total Interest: ₹${results['returns']!.toStringAsFixed(0)}\n"
                                      "Maturity Amount: ₹${results['total']!.toStringAsFixed(0)}\n\n"
                                      "Calculated via Calculator Pro!";

                                  try {
                                    await SharePlus.instance.share(
                                      ShareParams(text: shareText, subject: "Interest Calculation Result"),
                                    );
                                  } catch (e) {
                                    debugPrint("Share error: $e");
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.cyanColor(context).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.share_rounded, color: AppColors.cyanColor(context), size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Share",
                                        style: TextStyle(
                                          color: AppColors.cyanColor(context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor(context).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5, // Line spacing ke liye
                              ),
                              children: [
                                TextSpan(
                                  text: 'Note : ',
                                  style: TextStyle(
                                    color: AppColors.orangeColor(context), // Orange/Yellow color note ke title ke liye
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                  'Based on your input, Interest Calculator will be calculate how much rate of interest will be applicable on loan amount.',
                                  style: TextStyle(
                                    color: AppColors.textColor(context).withOpacity(0.9), // White/Light grey text
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 120), // Bottom padding for sticky bar
                      ],
                    ),
                  ),

                  // --- 7. STICKY BOTTOM BAR ---
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      offset: _showStickyResult ? Offset.zero : const Offset(0, 1.2),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _showStickyResult ? 1.0 : 0.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor(context),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyanColor(context).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                            border: Border(
                              top: BorderSide(color: AppColors.cyanColor(context).withOpacity(0.3), width: 1.5),
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Maturity Amount',
                                  style: TextStyle(
                                    color: AppColors.textColor(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${results['total']!.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppColors.cyanColor(context),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}
