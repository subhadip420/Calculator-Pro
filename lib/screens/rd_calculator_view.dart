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

class RdCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const RdCalculatorView({super.key, required this.onBack});

  @override
  State<RdCalculatorView> createState() => _RdCalculatorViewState();
}

class _RdCalculatorViewState extends State<RdCalculatorView> {
  final ScrollController _scrollController = ScrollController();
  bool _showStickyResult = true;
  bool _isHapticsEnabled = true;

  // State Variables
  double _amountValue = 5000; // Default Monthly Deposit
  double _interestRateValue = 7.0; // Default Interest Rate
  String _tenureUnit = 'year'; // Default unit

  final TextEditingController _tenureController = TextEditingController(text: '5');
  double _tenureValue = 5.0;

  // --- REAL-TIME MATH LOGIC FOR RD ---
  Map<String, double> _getCalculatedValues() {
    double p = _amountValue;
    double r = _interestRateValue;
    int totalMonths = _tenureUnit == 'year' ? (_tenureValue * 12).round() : _tenureValue.round();

    if (p == 0 || totalMonths == 0) return {'invested': 0, 'returns': 0, 'total': 0};

    double totalInvested = p * totalMonths;
    double maturityAmount = 0.0;

    // RD Calculation: Har mahine ke deposit par bache hue time ke hisaab se Quarterly Compounding
    for (int i = 1; i <= totalMonths; i++) {
      double timeInYears = (totalMonths - i + 1) / 12.0;
      maturityAmount += p * pow(1 + (r / 100) / 4, 4 * timeInYears);
    }

    double returns = maturityAmount - totalInvested;
    if (returns < 0) returns = 0;

    return {
      'invested': totalInvested,
      'returns': returns,
      'total': maturityAmount,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Scroll Listener for Sticky Bar
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent > 0 &&
          _scrollController.offset >= _scrollController.position.maxScrollExtent - 50) {
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
              toolId: 'rd',
              title: 'RD Calculator',
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

                        // --- RULER SCALE: Monthly Investment ---
                        CustomRulerSliderCard(
                          title: 'Monthly Deposit',
                          subtitle: 'Amount you invest every month',
                          symbol: '₹',
                          currentValue: _amountValue,
                          min: 0,
                          max: 1000000, // Max 10 Lakh per month
                          isHapticsEnabled: _isHapticsEnabled,
                          onChanged: (val) {
                            setState(() {
                              _amountValue = val;
                            });
                          },
                        ),
                        const SizedBox(height: 15),

                        // --- PERCENTAGE SLIDER: Interest Rate ---
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

                        // --- DURATION CARD ---
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
                              // 1. RADIO BUTTONS: Year vs Month
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
                                        if (_tenureValue > 10) { // RD usually max 10 years
                                          _tenureValue = 10;
                                          _tenureController.text = '10';
                                        }
                                      });
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _tenureUnit == 'year' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                          color: _tenureUnit == 'year' ? AppColors.cyanColor(context) : AppColors.textGrey(context),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text('Year', style: TextStyle(color: _tenureUnit == 'year' ? AppColors.textColor(context) : AppColors.textGrey(context), fontSize: 14, fontWeight: FontWeight.w600)),
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
                                          _tenureUnit == 'month' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                          color: _tenureUnit == 'month' ? AppColors.cyanColor(context) : AppColors.textGrey(context),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text('Month', style: TextStyle(color: _tenureUnit == 'month' ? AppColors.textColor(context) : AppColors.textGrey(context), fontSize: 14, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Divider(color: AppColors.textGrey(context).withOpacity(0.5), thickness: 1, height: 1),
                              ),

                              // 2. INPUT FIELD
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Duration',
                                    style: TextStyle(
                                      color: AppColors.textGrey(context),
                                      fontSize: 15,
                                    ),
                                  ),
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
                                                // Banks generally have max 10 Years for RD
                                                double maxLimit = _tenureUnit == 'year' ? 10 : 120;
                                                String limitText = maxLimit.toInt().toString();

                                                if (newVal > maxLimit) {
                                                  newVal = maxLimit;
                                                  _tenureController.value = TextEditingValue(
                                                    text: limitText,
                                                    selection: TextSelection.collapsed(offset: limitText.length),
                                                  );
                                                  String timeUnit = _tenureUnit == 'year' ? 'years' : 'months';
                                                  showCustomToast(context, 'Maximum RD tenure can be $limitText $timeUnit');
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

                        // --- REAL-TIME RESULT CARD ---
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
                                  style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 10),

                              _buildResultRow('Total Investment', results['invested']!),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                              ),

                              _buildResultRow('Total Interest', results['returns']!, valueColor: AppColors.greenColor(context)),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                              ),

                              _buildResultRow('Maturity Amount', results['total']!, isHighlighted: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- COPY & SHARE BUTTONS ---
                        Row(
                          children: [
                            // 1. COPY BUTTON
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (_isHapticsEnabled) HapticFeedback.selectionClick();

                                  String tenureText = "${_tenureValue.toStringAsFixed(0)} ${_tenureUnit == 'year' ? 'Years' : 'Months'}";

                                  String copyText = "RD Calculation Result\n\n"
                                      "Monthly Deposit: ₹${_amountValue.toStringAsFixed(0)}\n"
                                      "Interest Rate: ${_interestRateValue.toStringAsFixed(1)}%\n"
                                      "Duration: $tenureText\n\n"
                                      "Total Invested: ₹${results['invested']!.toStringAsFixed(0)}\n"
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
                                        style: TextStyle(color: AppColors.textColor(context), fontWeight: FontWeight.bold),
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

                                  String tenureText = "${_tenureValue.toStringAsFixed(0)} ${_tenureUnit == 'year' ? 'Years' : 'Months'}";

                                  String shareText = "Hey! Check my RD Plan\n\n"
                                      "Monthly Deposit: ₹${_amountValue.toStringAsFixed(0)}\n"
                                      "Interest Rate: ${_interestRateValue.toStringAsFixed(1)}%\n"
                                      "Duration: $tenureText\n\n"
                                      "Total Invested: ₹${results['invested']!.toStringAsFixed(0)}\n"
                                      "Total Interest: ₹${results['returns']!.toStringAsFixed(0)}\n"
                                      "Maturity Amount: ₹${results['total']!.toStringAsFixed(0)}\n\n"
                                      "Calculated via Calculator Pro!";

                                  try {
                                    await SharePlus.instance.share(ShareParams(text: shareText, subject: "RD Calculation Result"));
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
                                        style: TextStyle(color: AppColors.cyanColor(context), fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 120), // Bottom padding for sticky bar space
                      ],
                    ),
                  ),

                  // --- STICKY BOTTOM BAR ---
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
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
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