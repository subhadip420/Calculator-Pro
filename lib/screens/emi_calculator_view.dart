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

class EmiCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const EmiCalculatorView({super.key, required this.onBack});

  @override
  State<EmiCalculatorView> createState() => _EmiCalculatorViewState();
}

class _EmiCalculatorViewState extends State<EmiCalculatorView> {
  final ScrollController _scrollController = ScrollController();
  bool _showStickyResult = true;
  bool _isHapticsEnabled = true;

  // --- STATE VARIABLES ---
  double _loanAmountValue = 500000; // Default Loan Amount (5 Lakhs)
  double _interestRateValue = 8.5; // Default Home/Car Loan Interest Rate

  String _tenureUnit = 'year'; // 'year' or 'month'
  final TextEditingController _tenureController = TextEditingController(text: '5');
  double _tenureValue = 5.0;

  // NAYA: Fees & Charges Variables
  String _feeType = 'percentage'; // 'fixed' or 'percentage'
  final TextEditingController _feeController = TextEditingController(text: '0.0'); // 1% default fee
  double _feeValue = 0.0;

  // --- REAL-TIME MATH LOGIC (EMI FORMULA) ---
  Map<String, double> _getCalculatedValues() {
    double p = _loanAmountValue;
    double rAnnual = _interestRateValue;
    double n = _tenureUnit == 'year' ? _tenureValue * 12 : _tenureValue; // Total Months

    if (p == 0 || n == 0) {
      return {'emi': 0, 'principal': p, 'interest': 0, 'total': p, 'fees': 0, 'payable': p};
    }

    double emi = 0;
    double totalAmount = 0;
    double totalInterest = 0;

    if (rAnnual == 0) {
      emi = p / n;
      totalAmount = p;
      totalInterest = 0;
    } else {
      double rMonthly = rAnnual / 12 / 100; // Monthly interest rate
      // EMI Formula: P * r * (1+r)^n / ((1+r)^n - 1)
      emi = p * rMonthly * pow(1 + rMonthly, n) / (pow(1 + rMonthly, n) - 1);
      totalAmount = emi * n;
      totalInterest = totalAmount - p;
    }

    // Fees Calculation
    double calculatedFees = 0;
    if (_feeValue > 0) {
      if (_feeType == 'percentage') {
        calculatedFees = p * (_feeValue / 100);
      } else {
        calculatedFees = _feeValue;
      }
    }

    return {
      'emi': emi,
      'principal': p,
      'interest': totalInterest,
      'total': totalAmount,
      'fees': calculatedFees,
      'payable': totalAmount + calculatedFees, // Loan to repay + Upfront Fees
    };
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Scroll Listener for Sticky Bar
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent > 0 &&
          _scrollController.offset >= _scrollController.position.maxScrollExtent - 250) {
        if (_showStickyResult) setState(() => _showStickyResult = false);
      } else {
        if (!_showStickyResult) setState(() => _showStickyResult = true);
      }
    });
  }

  @override
  void dispose() {
    _tenureController.dispose();
    _feeController.dispose();
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
              toolId: 'emi',
              title: 'EMI Calculator',
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
                        // --- 1. LOAN AMOUNT RULER ---
                        CustomRulerSliderCard(
                          title: 'Loan Amount',
                          subtitle: 'Total amount you want to borrow',
                          symbol: '₹',
                          currentValue: _loanAmountValue,
                          min: 0,
                          max: 10000000,
                          // 1 Crore max
                          isHapticsEnabled: _isHapticsEnabled,
                          onChanged: (val) {
                            setState(() => _loanAmountValue = val);
                          },
                        ),
                        const SizedBox(height: 15),

                        // --- 2. INTEREST RATE SLIDER ---
                        PercentageSliderCard(
                          title: 'Interest Rate',
                          currentValue: _interestRateValue,
                          onChanged: (val) {
                            setState(() => _interestRateValue = val);
                          },
                        ),
                        const SizedBox(height: 15),

                        // --- 3. DURATION CARD ---
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
                                        if (_tenureValue > 40) {
                                          // Max 40 years for loan
                                          _tenureValue = 40;
                                          _tenureController.text = '40';
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
                                      setState(() => _tenureUnit = 'month');
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
                                  Text('Period', style: TextStyle(color: AppColors.textGrey(context), fontSize: 15)),
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
                                                double maxLimit = _tenureUnit == 'year' ? 40 : 480;
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

                        // --- 4. FEES & CHARGES CARD (OPTIONAL) ---
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
                                  Expanded(
                                    child: Text(
                                      '(Optional)',
                                      style: TextStyle(
                                        color: AppColors.orangeColor(context),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Loan Fees & Charges',
                                      style: TextStyle(
                                        color: AppColors.textColor(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Radio Options Inner Card
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.bgColor(context).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    // Percentage Radio
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                          setState(() => _feeType = 'percentage');
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Row(
                                          children: [
                                            Icon(
                                              _feeType == 'percentage'
                                                  ? Icons.radio_button_checked_rounded
                                                  : Icons.radio_button_off_rounded,
                                              color: _feeType == 'percentage'
                                                  ? AppColors.cyanColor(context)
                                                  : AppColors.textGrey(context),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Percentage (%)',
                                              style: TextStyle(
                                                color: _feeType == 'percentage'
                                                    ? AppColors.textColor(context)
                                                    : AppColors.textGrey(context),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Fixed Value Radio
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                          setState(() => _feeType = 'fixed');
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Row(
                                          children: [
                                            Icon(
                                              _feeType == 'fixed'
                                                  ? Icons.radio_button_checked_rounded
                                                  : Icons.radio_button_off_rounded,
                                              color: _feeType == 'fixed'
                                                  ? AppColors.cyanColor(context)
                                                  : AppColors.textGrey(context),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Fixed (₹)',
                                              style: TextStyle(
                                                color: _feeType == 'fixed'
                                                    ? AppColors.textColor(context)
                                                    : AppColors.textGrey(context),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                  Text(
                                    'Fee Amount',
                                    style: TextStyle(color: AppColors.textGrey(context), fontSize: 14),
                                  ),
                                  Container(
                                    width: 130,
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
                                            controller: _feeController,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.textColor(context),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            cursorColor: AppColors.cyanColor(context),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                              hintText: '0',
                                            ),
                                            onChanged: (val) {
                                              double? newVal = double.tryParse(val.replaceAll(',', ''));
                                              setState(() => _feeValue = newVal ?? 0.0);
                                            },
                                          ),
                                        ),
                                        Container(
                                          width: 45,
                                          decoration: BoxDecoration(
                                            color: AppColors.cyanColor(context).withOpacity(0.1),
                                            borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(11),
                                              bottomRight: Radius.circular(11),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _feeType == 'percentage' ? '%' : '₹',
                                            style: TextStyle(
                                              color: AppColors.cyanColor(context).withOpacity(0.9),
                                              fontSize: 16,
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

                              _buildResultRow(
                                'Monthly EMI',
                                results['emi']!,
                                valueColor: AppColors.cyanColor(context),
                                isHighlighted: true,
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                              ),

                              _buildResultRow('Principal Amount', results['principal']!),

                              if (results['fees']! > 0) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                                ),
                                _buildResultRow('Processing Fees', results['fees']!, valueColor: AppColors.orangeColor(context)),
                              ],

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                              ),

                              _buildResultRow(
                                'Total Interest',
                                results['interest']!,
                                valueColor: AppColors.greenColor(context),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                              ),

                              _buildResultRow('Total Amount Payable', results['payable']!, isHighlighted: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- 6. COPY & SHARE BUTTONS ---
                        Row(
                          children: [
                            // COPY BUTTON
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (_isHapticsEnabled) HapticFeedback.selectionClick();

                                  String tenureText =
                                      "${_tenureValue.toStringAsFixed(0)} ${_tenureUnit == 'year' ? 'Years' : 'Months'}";
                                  String feesText = results['fees']! > 0
                                      ? "Processing Fees: ₹${results['fees']!.toStringAsFixed(0)}\n"
                                      : "";

                                  String copyText =
                                      "EMI Calculation Result\n\n"
                                      "Loan Amount: ₹${_loanAmountValue.toStringAsFixed(0)}\n"
                                      "Interest Rate: ${_interestRateValue.toStringAsFixed(1)}%\n"
                                      "Period: $tenureText\n\n"
                                      "Monthly EMI: ₹${results['emi']!.toStringAsFixed(0)}\n"
                                      "Total Interest: ₹${results['interest']!.toStringAsFixed(0)}\n"
                                      "$feesText"
                                      "Total Payable: ₹${results['payable']!.toStringAsFixed(0)}";

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

                            // SHARE BUTTON
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (_isHapticsEnabled) HapticFeedback.selectionClick();

                                  String tenureText =
                                      "${_tenureValue.toStringAsFixed(0)} ${_tenureUnit == 'year' ? 'Years' : 'Months'}";
                                  String feesText = results['fees']! > 0
                                      ? "Processing Fees: ₹${results['fees']!.toStringAsFixed(0)}\n"
                                      : "";

                                  String shareText =
                                      "Hey! Check my EMI Plan\n\n"
                                      "Loan Amount: ₹${_loanAmountValue.toStringAsFixed(0)}\n"
                                      "Interest Rate: ${_interestRateValue.toStringAsFixed(1)}%\n"
                                      "Period: $tenureText\n\n"
                                      "Monthly EMI: ₹${results['emi']!.toStringAsFixed(0)}\n"
                                      "Total Interest: ₹${results['interest']!.toStringAsFixed(0)}\n"
                                      "$feesText"
                                      "Total Payable: ₹${results['payable']!.toStringAsFixed(0)}\n\n"
                                      "Calculated via Calculator Pro!";

                                  try {
                                    await SharePlus.instance.share(
                                      ShareParams(text: shareText, subject: "EMI Calculation Result"),
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
                                  'Based on your input, loan Period/ Tenure calculator total Years/Months for a loan.',
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
                                  'Monthly EMI',
                                  style: TextStyle(
                                    color: AppColors.textColor(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${results['emi']!.toStringAsFixed(0)}',
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
