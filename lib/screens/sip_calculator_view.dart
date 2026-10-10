import 'dart:math';

import 'package:calculator_pro/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _showStickyResult = true;
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

    // --- NAYA: Scroll Listener ---
    _scrollController.addListener(() {
      // Agar user bottom se 250 pixels ke andar hai, toh sticky bar hide kar do
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
    _amountController.dispose();
    _tenureController.dispose();
    _scrollController.dispose();
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
  // Widget _buildOptionCard({required String id, required String title, required IconData icon}) {
  //   bool isSelected = _selectedMode == id;
  //
  //   return GestureDetector(
  //     onTap: () => _onModeSelect(id),
  //     behavior: HitTestBehavior.opaque,
  //     child: Container(
  //       //height: 100, // Fixed height taaki dono cards barabar dikhein
  //       padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
  //       decoration: BoxDecoration(
  //         color: isSelected
  //             ? AppColors.cyanColor(context).withOpacity(0.1)
  //             : AppColors.surfaceColor(context).withOpacity(0.6),
  //         borderRadius: BorderRadius.circular(16),
  //         border: Border.all(
  //           color: isSelected ? AppColors.cyanColor(context) : AppColors.textGrey(context).withOpacity(0.5),
  //           width: isSelected ? 2 : 1,
  //         ),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(icon, color: isSelected ? AppColors.cyanColor(context) : AppColors.textGrey(context), size: 22),
  //           const SizedBox(height: 5),
  //           Text(
  //             title,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               color: isSelected ? AppColors.cyanColor(context) : AppColors.textColor(context),
  //               fontSize: 12,
  //               fontWeight: FontWeight.bold,
  //               height: 1.2,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // --- HELPER: Option Card (Side-by-Side) ---
  Widget _buildOptionCard({required String id, required String title, required IconData icon}) {
    bool isSelected = _selectedMode == id;

    return GestureDetector(
      onTap: () => _onModeSelect(id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        // Padding thodi adjust ki hai taaki Row layout mein button premium lage
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
        // NAYA: Column ki jagah Row lagaya
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Content ko center mein rakhega
          children: [
            Icon(icon, color: isSelected ? AppColors.cyanColor(context) : AppColors.textGrey(context), size: 22),
            const SizedBox(width: 8), // NAYA: Height ki jagah Width mein gap diya
            Expanded( // Expanded lagaya taaki lambi text overflow na kare
              child: Text(
                title,
                textAlign: TextAlign.start, // Left align text
                style: TextStyle(
                  color: isSelected ? AppColors.cyanColor(context) : AppColors.textColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER TO BUILD RESULT ROWS ---
  // Widget _buildResultRow(String label, double value, {bool isHighlighted = false, Color? valueColor}) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(
  //         label,
  //         style: TextStyle(
  //           color: isHighlighted ? AppColors.textColor(context) : AppColors.textGrey(context),
  //           fontSize: isHighlighted ? 18 : 15,
  //           fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
  //         ),
  //       ),
  //       Text(
  //         '₹${value.toInt()}', // Comma formatting aap apne hisaab se baad mein add kar sakte hain
  //         style: TextStyle(
  //           color: valueColor ?? (isHighlighted ? AppColors.cyanColor(context) : AppColors.textColor(context)),
  //           fontSize: isHighlighted ? 22 : 16,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // --- HELPER TO BUILD RESULT ROWS ---
  Widget _buildResultRow(String label, double value, {bool isHighlighted = false, Color? valueColor}) {
    String formattedValue = value.toStringAsFixed(0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label ko Expanded mein rakha taaki lamba label hone par wo agli line mein aa jaye
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

        const SizedBox(width: 12), // Text aur amount ke beech safe gap

        // Value ko Flexible aur FittedBox mein rakha taaki bada amount shrink ho jaye par kate nahi
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
            // Expanded(
            //   child: SingleChildScrollView(
            Expanded(
              child: Stack(
                children: [
                SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Method',
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

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
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildOptionCard(
                            id: 'goal_amount',
                            title: 'Know Goal\nAmount',
                            icon: Icons.flag_circle_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context).withOpacity(0.6),
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

                    const SizedBox(height: 15),

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

                    const SizedBox(height: 15), // Gap

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

                    const SizedBox(height: 15),

                    // --- NAYA: TENURE / DURATION CARD ---
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context).withOpacity(0.6),
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
                                        // NAYA: Max 50 Year Condition
                                        if (newVal > 50) {
                                          newVal = 50;

                                          _tenureController.value = const TextEditingValue(
                                            text: '50',
                                            selection: TextSelection.collapsed(offset: 2),
                                          );

                                          // --- AAPKA CUSTOM TOAST ---
                                          // Apne function ka exact naam yahan likh lijiye (eg. showToast)
                                          showCustomToast(context,'Maximum tenure can be 50 years');
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

                    const SizedBox(height: 15),

                    // --- REAL-TIME RESULT CARD ---
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
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
                            _buildResultRow('Total Interest', results['returns']!, valueColor: AppColors.greenColor(context)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: AppColors.textGrey(context), thickness: 1, height: 1),
                            ),
                            _buildResultRow('Maturity Amount', results['total']!, isHighlighted: true),
                          ],
                        ],
                      ),
                    ),

                    // ... (Aapki aakhiri _buildResultRow line yahan hogi)

                    const SizedBox(height: 15), // Thoda gap

                    // --- NAYA: COPY AUR SHARE BUTTONS ---
                    Row(
                      children: [
                        // 1. COPY BUTTON
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_isHapticsEnabled) HapticFeedback.selectionClick();

                              // Dynamic label jo SIP, Lumpsum ya Goal mode ke hisaab se change hoga
                              String inputTypeLabel = _selectedMode == 'invested_amount'
                                  ? (_investmentType == 'sip' ? 'Monthly SIP' : 'Lumpsum Amount')
                                  : 'Target Goal Amount';

                              // Agar Goal mode hai toh Required Amount bhi text mein add hoga
                              String requiredText = _selectedMode == 'goal_amount'
                                  ? "Required ${_investmentType == 'sip' ? 'Monthly SIP' : 'Lumpsum'}: ₹${results['required']!.toStringAsFixed(0)}\n"
                                  : "";

                              String copyText = "Investment Calculation Result\n\n"
                                  "$inputTypeLabel: ₹${_amountValue.toStringAsFixed(0)}\n"
                                  "Interest Rate: ${_interestRateValue.toStringAsFixed(1)}%\n"
                                  "Duration: ${_tenureValue.toStringAsFixed(0)} Years\n\n"
                                  "$requiredText"
                                  "Total Invested: ₹${results['invested']!.toStringAsFixed(0)}\n"
                                  "Total Interest: ₹${results['returns']!.toStringAsFixed(0)}\n"
                                  "Maturity Amount: ₹${results['total']!.toStringAsFixed(0)}";

                              Clipboard.setData(ClipboardData(text: copyText));

                              // Yahan apna custom toast call kar lijiye
                              // showToast('Result Copied!');
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

                              // Share button ke onTap mein:
                              String inputTypeLabel = _selectedMode == 'invested_amount'
                                  ? (_investmentType == 'sip' ? 'Monthly SIP' : 'Lumpsum Amount')
                                  : 'Target Goal Amount';

                              String requiredText = _selectedMode == 'goal_amount'
                                  ? "Required ${_investmentType == 'sip' ? 'Monthly SIP' : 'Lumpsum'}: ₹${results['required']!.toStringAsFixed(0)}\n"
                                  : "";

                              String shareText = "Hey! Check my Investment Plan\n\n"
                                  "$inputTypeLabel: ₹${_amountValue.toStringAsFixed(0)}\n"
                                  "Interest Rate: ${_interestRateValue.toStringAsFixed(1)}%\n"
                                  "Duration: ${_tenureValue.toStringAsFixed(0)} Years\n\n"
                                  "$requiredText"
                                  "Total Invested: ₹${results['invested']!.toStringAsFixed(0)}\n"
                                  "Total Interest: ₹${results['returns']!.toStringAsFixed(0)}\n"
                                  "Maturity Amount: ₹${results['total']!.toStringAsFixed(0)}\n\n"
                                  "Calculated via Calculator Pro!";

                              // Note: Share karne ke liye aapko 'share_plus' package chahiye
                              // Share.share(shareText);
                              try {
                                await SharePlus.instance.share(ShareParams(text: shareText, subject: "Investment Calculation Result"));
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



                    const SizedBox(height: 50),
                  ],
                ),
              ),

                  // --- NAYA: DYNAMIC STICKY BOTTOM BAR ---
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      offset: _showStickyResult ? Offset.zero : const Offset(0, 1.2), // Hide hone par niche slide hoga
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
                            ),// Background color
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyanColor(context).withOpacity(0.3),
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
                                // Column(
                                //   mainAxisSize: MainAxisSize.min,
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                Text(
                                  'Maturity Amount',
                                  style: TextStyle(
                                    color: AppColors.textColor(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // const SizedBox(height: 4),
                                Text(
                                  '₹${results['total']!.toStringAsFixed(0)}', // Real-time calculate value
                                  style: TextStyle(
                                    color: AppColors.cyanColor(context),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            // Optional: Ek chota sa arrow taaki user ko pata chale ki niche aur details hain
                            // Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey(context)),
                            //   ],
                            // ),
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
