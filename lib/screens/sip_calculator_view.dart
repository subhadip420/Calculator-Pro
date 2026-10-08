import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';
import '../widgets/custom_ruler_slider_card.dart';
import '../widgets/percentage_slider_card.dart';

class SipCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const SipCalculatorView({super.key, required this.onBack});

  @override
  State<SipCalculatorView> createState() => _SipCalculatorViewState();
}

class _SipCalculatorViewState extends State<SipCalculatorView> {
  bool _isHapticsEnabled = true;

  // Default selected option
  String _selectedMode = 'invested_amount';
  String _investmentType = 'sip';

  // Input Controller
  final TextEditingController _amountController = TextEditingController();

  // Slider Value (Start with a default value like 20,000)
  double _amountValue = 20000;
  double _interestRateValue = 12.0; // Default interest rate

  // Tenure (Years) State
  final TextEditingController _tenureController = TextEditingController(text: '10');
  double _tenureValue = 10.0;

  // Result Variables
  // bool _showResult = false;
  // double _totalInvestment = 0;
  // double _estimatedReturns = 0;
  // double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _amountController.text = _amountValue.toInt().toString();
    // NAYA: TextField mein type karne par slider bhi update ho
    _amountController.addListener(() {
      String text = _amountController.text.replaceAll(',', ''); // Comma wagera hata do
      double? val = double.tryParse(text);
      if (val != null && val >= 0) {
        setState(() {
          // Slider max 10,00,000 tak jayega, agar user manually 15 Lakh type kare
          // toh bhi value update ho jayegi
          _amountValue = val;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  // --- REAL-TIME MATH LOGIC ---
  Map<String, double> _getCalculatedValues() {
    double p = _amountValue; // Invested Amount ya Goal Amount
    double r = _interestRateValue;
    double t = _tenureValue;

    if (p == 0 || t == 0) return {'invested': 0, 'returns': 0, 'total': p, 'required': 0};

    double invested = 0;
    double total = 0;
    double requiredAmt = 0;

    if (_selectedMode == 'invested_amount') {
      // 1. Know Invested Amount -> Find Total
      if (_investmentType == 'sip') {
        double i = (r / 100) / 12; // Monthly rate
        double n = t * 12; // Total months
        invested = p * n;
        total = (r == 0) ? invested : p * ((pow(1 + i, n) - 1) / i) * (1 + i);
      } else {
        // Lumpsum
        invested = p;
        total = (r == 0) ? invested : p * pow(1 + (r / 100), t);
      }
    } else {
      // 2. Know Goal Amount -> Find Required Investment
      total = p; // Jo amount input kiya wo Target hai
      if (_investmentType == 'sip') {
        double i = (r / 100) / 12;
        double n = t * 12;
        requiredAmt = (r == 0) ? (total / n) : (total * i) / (((pow(1 + i, n) - 1)) * (1 + i));
        invested = requiredAmt * n;
      } else {
        // Lumpsum
        requiredAmt = (r == 0) ? total : total / pow(1 + (r / 100), t);
        invested = requiredAmt;
      }
    }

    double returns = total - invested;
    if (returns < 0) returns = 0; // Floating point safety

    return {'invested': invested, 'returns': returns, 'total': total, 'required': requiredAmt};
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true);
    }
  }

  // --- LOGIC: Option Select ---
  void _onModeSelect(String mode) {
    if (_isHapticsEnabled) HapticFeedback.selectionClick();
    setState(() {
      _selectedMode = mode;
      // Yahan baad mein hum input fields clear karne ka logic daalenge
    });
  }

  // --- HELPER: Option Card (Side-by-Side) ---
  Widget _buildOptionCard({required String id, required String title, required IconData icon}) {
    bool isSelected = _selectedMode == id;

    return GestureDetector(
      onTap: () => _onModeSelect(id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        //height: 100, // Fixed height taaki dono cards barabar dikhein
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cyanColor(context).withOpacity(0.1)
              : AppColors.surfaceColor(context).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.cyanColor(context) : AppColors.textGrey(context).withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.cyanColor(context) : AppColors.textGrey(context), size: 22),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? AppColors.cyanColor(context) : AppColors.textColor(context),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER TO BUILD RESULT ROWS ---
  Widget _buildResultRow(String label, double value, {bool isHighlighted = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isHighlighted ? AppColors.textColor(context) : AppColors.textGrey(context),
            fontSize: isHighlighted ? 18 : 15,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${value.toInt()}', // Comma formatting aap apne hisaab se baad mein add kar sakte hain
          style: TextStyle(
            color: valueColor ?? (isHighlighted ? AppColors.cyanColor(context) : AppColors.textColor(context)),
            fontSize: isHighlighted ? 22 : 16,
            fontWeight: FontWeight.bold,
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
      // NAYA: GestureDetector bahar click karne pe keyboard hide karne ke liye
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            CustomTopBar(
              toolId: 'sip',
              title: 'SIP Calculator',
              iconPath: 'assets/images/percentage-discount-symbol.png',
              onBack: widget.onBack,
              isHapticsEnabled: _isHapticsEnabled,
            ),

            // --- MAIN SCROLL VIEW ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Method',
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),

                    // --- 2 OPTIONS CARD (Side by Side) ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildOptionCard(
                            id: 'invested_amount',
                            title: 'Know Invested\nAmount',
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildOptionCard(
                            id: 'goal_amount',
                            title: 'Know Goal\nAmount',
                            icon: Icons.flag_circle_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          // Left Radio: SIP
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                setState(() => _investmentType = 'sip');
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                children: [
                                  Icon(
                                    _investmentType == 'sip'
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: _investmentType == 'sip'
                                        ? AppColors.cyanColor(context)
                                        : AppColors.textGrey(context),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'SIP',
                                    style: TextStyle(
                                      color: _investmentType == 'sip'
                                          ? AppColors.textColor(context)
                                          : AppColors.textGrey(context),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Right Radio: Lumpsum
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                setState(() => _investmentType = 'lumpsum');
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                children: [
                                  Icon(
                                    _investmentType == 'lumpsum'
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: _investmentType == 'lumpsum'
                                        ? AppColors.cyanColor(context)
                                        : AppColors.textGrey(context),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Lumpsum',
                                    style: TextStyle(
                                      color: _investmentType == 'lumpsum'
                                          ? AppColors.textColor(context)
                                          : AppColors.textGrey(context),
                                      fontSize: 16,
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

                    const SizedBox(height: 10),

                    CustomRulerSliderCard(
                      title: 'Investment Amount',
                      //subtitle: _selectedMode == 'invested_amount' ? 'Monthly Amount' : 'Goal Amount',
                      subtitle: _selectedMode == 'invested_amount'
                          ? (_investmentType == 'sip' ? 'Monthly Amount' : 'Lumpsum Amount')
                          : 'Goal Amount',
                      symbol: '₹',
                      currentValue: _amountValue,
                      min: 0,
                      max: 1000000,
                      isHapticsEnabled: _isHapticsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _amountValue = val;
                        });
                      },
                    ),

                    const SizedBox(height: 10), // Gap
                    // --- NAYA: INTEREST RATE SLIDER ---
                    PercentageSliderCard(
                      title: 'Interest Rate', // Ya 'Interest Rate'
                      currentValue: _interestRateValue,
                      onChanged: (val) {
                        setState(() {
                          _interestRateValue = val;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // --- NAYA: TENURE / DURATION CARD ---
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tenure/Duration',
                            style: TextStyle(
                              color: AppColors.textColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                                        setState(() => _tenureValue = newVal);
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  width: 55, // "Year" text ke liye thoda bada width
                                  decoration: BoxDecoration(
                                    color: AppColors.cyanColor(context).withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(11),
                                      bottomRight: Radius.circular(11),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Year',
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
                    ),

                    const SizedBox(height: 10),

                    // --- REAL-TIME RESULT CARD ---
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                        color: AppColors.cyanColor(context).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.5), width: 1.5),
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

                          // Agar GOAL AMOUNT mode hai, toh pehle Required amount dikhayenge
                          if (_selectedMode == 'goal_amount') ...[
                            _buildResultRow(
                              'Required ${_investmentType == 'sip' ? 'Monthly SIP' : 'Lumpsum'}',
                              results['required']!,
                              isHighlighted: true,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                            ),
                            _buildResultRow('Total Investment', results['invested']!),
                            const SizedBox(height: 6),
                            _buildResultRow('Total Interest', results['returns']!, valueColor: AppColors.textColor(context)),
                          ]
                          // Agar INVESTED AMOUNT mode hai, toh standard layout dikhayenge
                          else ...[
                            _buildResultRow('Total Investment', results['invested']!),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                            ),
                            _buildResultRow('Total Interest', results['returns']!, valueColor: AppColors.textColor(context)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                            ),
                            _buildResultRow('Maturity Amount', results['total']!, isHighlighted: true),
                          ],
                        ],
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
