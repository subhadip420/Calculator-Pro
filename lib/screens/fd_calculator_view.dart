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

class FdCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const FdCalculatorView({super.key, required this.onBack});

  @override
  State<FdCalculatorView> createState() => _FdCalculatorViewState();
}

class _FdCalculatorViewState extends State<FdCalculatorView> {
  bool _isHapticsEnabled = true;

  // State Variables
  String _fdType = 'cumulative'; // 'simple' or 'cumulative'
  double _amountValue = 50000; // Default FD amount
  double _interestRateValue = 7.0; // Default Interest Rate
  String _customerType = 'general';
  String _tenureUnit = 'year'; // Default unit
  String _compoundingFreq = 'Monthly'; // Default frequency

  final TextEditingController _tenureController = TextEditingController(text: '5');
  double _tenureValue = 5.0;

  // --- REAL-TIME MATH LOGIC FOR FD ---
  Map<String, double> _getCalculatedValues() {
    double p = _amountValue;
    double r = _interestRateValue;
    // Agar month hai toh 12 se divide karke saal (years) mein convert karenge
    double t = _tenureUnit == 'year' ? _tenureValue : _tenureValue / 12;

    if (p == 0 || t == 0) return {'invested': p, 'returns': 0, 'total': p};

    double total = 0;
    double returns = 0;

    if (_fdType == 'simple') {
      // Simple Interest Logic: (P * R * T) / 100
      returns = p * (r / 100) * t;
      total = p + returns;
    } else {
      // Cumulative (Compound) Interest Logic
      int n = 4; // Default Quarterly (Banks mostly use quarterly compounding)
      if (_compoundingFreq == 'Monthly') n = 12;
      else if (_compoundingFreq == 'Quarterly') n = 4;
      else if (_compoundingFreq == 'Semiannually') n = 2;
      else if (_compoundingFreq == 'Annually') n = 1;

      // Formula: P * (1 + r/n)^(n*t)
      total = p * pow(1 + (r / 100) / n, n * t);
      returns = total - p;
    }

    if (returns < 0) returns = 0;

    return {
      'invested': p,
      'returns': returns,
      'total': total,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _tenureController.dispose(); // Memory leak rokne ke liye zaroori hai
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
    String formattedValue = value.toStringAsFixed(0); // Badi value crash na ho isliye string convert

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
              toolId: 'fd',
              title: 'FD Calculator',
              iconPath: 'assets/images/percentage-discount-symbol.png',
              onBack: widget.onBack,
              isHapticsEnabled: _isHapticsEnabled,
            ),

            // --- MAIN SCROLL VIEW ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- RADIO BUTTONS: Simple FD vs Cumulative FD ---
                    // --- RADIO BUTTONS: Simple FD vs Cumulative FD ---
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
                            'FD Type',
                            style: TextStyle(
                              color: AppColors.textColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16), // Divider hatakar space lagaya

                          // --- NAYA: RADIO OPTIONS KE LIYE INNER CARD ---
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.bgColor(context).withOpacity(0.5), // Darker inner background
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.2)), // Halka sa cyan border
                            ),
                            child: Row(
                              children: [
                                // Left Radio: Simple FD
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                      setState(() => _fdType = 'simple');
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _fdType == 'simple'
                                              ? Icons.radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: _fdType == 'simple'
                                              ? AppColors.cyanColor(context)
                                              : AppColors.textGrey(context),
                                          size: 20, // Icon thoda compact kiya inner card ke hisaab se
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Simple FD',
                                            style: TextStyle(
                                              color: _fdType == 'simple'
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

                                // Right Radio: Cumulative FD
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                      setState(() => _fdType = 'cumulative');
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _fdType == 'cumulative'
                                              ? Icons.radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: _fdType == 'cumulative'
                                              ? AppColors.cyanColor(context)
                                              : AppColors.textGrey(context),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Cumulative',
                                            style: TextStyle(
                                              color: _fdType == 'cumulative'
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

                    // --- RULER SCALE: Deposit Amount ---
                    CustomRulerSliderCard(
                      title: 'Deposit Amount',
                      subtitle: 'One-time Investment',
                      symbol: '₹',
                      currentValue: _amountValue,
                      min: 0,
                      max: 5000000, // Maximum 50 Lakhs limit (aap badha sakte hain)
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

                    // (Aapka PercentageSliderCard yahan khatam hota hai)
                    const SizedBox(height: 15),

                    // --- NAYA: CUSTOMER TYPE (General vs Senior Citizen) ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20), // Outer radius 20 kiya taaki baaki cards se match ho
                        border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Type',
                            style: TextStyle(
                              color: AppColors.textColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16), // Divider ki jagah gap

                          // --- NAYA: RADIO OPTIONS KE LIYE INNER CARD ---
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.bgColor(context).withOpacity(0.5), // Darker inner background
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                // Left Radio: General
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                      setState(() {
                                        _customerType = 'general';
                                      });
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _customerType == 'general'
                                              ? Icons.radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: _customerType == 'general'
                                              ? AppColors.cyanColor(context)
                                              : AppColors.textGrey(context),
                                          size: 20, // Icon size adjust kiya
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'General',
                                            style: TextStyle(
                                              color: _customerType == 'general'
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

                                // Right Radio: Senior Citizen
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                      setState(() {
                                        _customerType = 'senior';
                                      });
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _customerType == 'senior'
                                              ? Icons.radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: _customerType == 'senior'
                                              ? AppColors.cyanColor(context)
                                              : AppColors.textGrey(context),
                                          size: 20, // Icon size adjust kiya
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Senior Citizen',
                                            style: TextStyle(
                                              color: _customerType == 'senior'
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
                          // --- 1. RADIO BUTTONS: Year vs Month ---
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
                                    // Agar value 50 se zyada hai aur year select kiya, toh 50 par le aao
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

                          // --- 2. INPUT FIELD ---
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

                                            // NAYA: Dynamic Max Limit Check
                                            double maxLimit = _tenureUnit == 'year' ? 50 : 600; // Max 50 saal ya 600 mahine
                                            String limitText = maxLimit.toInt().toString();

                                            if (newVal > maxLimit) {
                                              newVal = maxLimit;

                                              _tenureController.value = TextEditingValue(
                                                text: limitText,
                                                selection: TextSelection.collapsed(offset: limitText.length),
                                              );

                                              String timeUnit = _tenureUnit == 'year' ? 'years' : 'months';
                                              showCustomToast(context, 'Maximum tenure can be $limitText $timeUnit');
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
                                        // NAYA: Dynamic Unit Name
                                        _tenureUnit == 'year' ? 'Year' : 'Month',
                                        style: TextStyle(
                                          color: AppColors.cyanColor(context).withOpacity(0.9),
                                          fontSize: _tenureUnit == 'year' ? 16 : 13, // Month thoda lamba text hai
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

                    // --- COMPOUNDING FREQUENCY CARD (Only for Cumulative FD) ---
                    if (_fdType == 'cumulative') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor(context).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Compounding\nFrequency', // 2 line mein neat dikhega
                                style: TextStyle(
                                  color: AppColors.textColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _showCompoundingFrequencyDialog, // Pop-up open karega
                              child: Container(
                                width: 145,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.bgColor(context).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          _compoundingFreq,
                                          style: TextStyle(
                                            color: AppColors.textColor(context),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.cyanColor(context).withOpacity(0.1), // Screenshot jaisa exact purple color
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(11),
                                          bottomRight: Radius.circular(11),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.cyanColor(context)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],

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

                    const SizedBox(height: 15), // Result card pachi gap

                    // --- NAYA: COPY AUR SHARE BUTTONS ---
                    Row(
                      children: [
                        // 1. COPY BUTTON
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_isHapticsEnabled) HapticFeedback.selectionClick();

                              // FD mate dynamic labels
                              String fdTypeText = _fdType == 'simple' ? 'Simple FD' : 'Cumulative FD';
                              String customerTypeText = _customerType == 'general' ? 'General' : 'Senior Citizen';
                              String tenureText = "${_tenureValue.toStringAsFixed(0)} ${_tenureUnit == 'year' ? 'Years' : 'Months'}";

                              // Agar cumulative chhe to j compounding frequency dekhase
                              String compoundingText = _fdType == 'cumulative' ? "\nCompounding: $_compoundingFreq" : "";

                              String copyText = "FD Calculation Result\n\n"
                                  "FD Type: $fdTypeText\n"
                                  "Customer: $customerTypeText\n"
                                  "Deposit Amount: ₹${_amountValue.toStringAsFixed(0)}\n"
                                  "Interest Rate: ${_interestRateValue.toStringAsFixed(1)}%\n"
                                  "Duration: $tenureText$compoundingText\n\n"
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

                        const SizedBox(width: 15), // Dono buttons ke beech gap

                        // 2. SHARE BUTTON
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (_isHapticsEnabled) HapticFeedback.selectionClick();

                              String fdTypeText = _fdType == 'simple' ? 'Simple FD' : 'Cumulative FD';
                              String customerTypeText = _customerType == 'general' ? 'General' : 'Senior Citizen';
                              String tenureText = "${_tenureValue.toStringAsFixed(0)} ${_tenureUnit == 'year' ? 'Years' : 'Months'}";
                              String compoundingText = _fdType == 'cumulative' ? "\nCompounding: $_compoundingFreq" : "";

                              String shareText = "Hey! Check my FD Calculation\n\n"
                                  "FD Type: $fdTypeText\n"
                                  "Customer: $customerTypeText\n"
                                  "Deposit Amount: ₹${_amountValue.toStringAsFixed(0)}\n"
                                  "Interest Rate: ${_interestRateValue.toStringAsFixed(1)}%\n"
                                  "Duration: $tenureText$compoundingText\n\n"
                                  "Total Invested: ₹${results['invested']!.toStringAsFixed(0)}\n"
                                  "Total Interest: ₹${results['returns']!.toStringAsFixed(0)}\n"
                                  "Maturity Amount: ₹${results['total']!.toStringAsFixed(0)}\n\n"
                                  "Calculated via Calculator Pro!";

                              try {
                                await SharePlus.instance.share(ShareParams(text: shareText, subject: "FD Calculation Result"));
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

                    const SizedBox(height: 15),

                    // --- NOTE CARD ---
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
                              text: 'Senior Citizen will be earn 0.25% to 0.75% Extra interest based on government rules & banking rates. FD interest rates are depend on bank. This will give overview & Basic Calculations for FD',
                              style: TextStyle(
                                color: AppColors.textColor(context).withOpacity(0.9), // White/Light grey text
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Niche ke liye thoda gap

                    const SizedBox(height: 40),

                    // Yahan par hum aage Tenure aur Result Card add karenge...
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPOUNDING FREQUENCY DIALOG ---
  void _showCompoundingFrequencyDialog() {
    if (_isHapticsEnabled) HapticFeedback.lightImpact();

    final List<String> frequencies = ['Monthly', 'Quarterly', 'Semiannually', 'Annually'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context), // Ya koi dark color (0xFF131620)
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.textGrey(context)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Title and Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Compounding Frequency',
                      style: TextStyle(
                          color: AppColors.textColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_isHapticsEnabled) HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orangeAccent, width: 1.5),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.orangeAccent, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // List of Options
                ...frequencies.map((freq) {
                  bool isSelected = _compoundingFreq == freq;
                  return GestureDetector(
                    onTap: () {
                      if (_isHapticsEnabled) HapticFeedback.selectionClick();
                      setState(() {
                        _compoundingFreq = freq;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        // Selected item par purple background aur border
                        color: isSelected ? AppColors.cyanColor(context).withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppColors.cyanColor(context).withOpacity(0.5) : AppColors.textGrey(context).withOpacity(0.5)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        freq,
                        style: TextStyle(
                          color: isSelected ? AppColors.cyanColor(context) : AppColors.textColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}