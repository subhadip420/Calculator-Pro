import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';

class GcfLcmCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const GcfLcmCalculatorView({super.key, required this.onBack});

  @override
  State<GcfLcmCalculatorView> createState() => _GcfLcmCalculatorViewState();
}

class _GcfLcmCalculatorViewState extends State<GcfLcmCalculatorView> {
  bool _isHapticsEnabled = true;

  // Dynamic list of controllers for input fields
  final List<TextEditingController> _controllers = [];

  // Variables to hold real-time results
  String _gcfResult = '--';
  String _lcmResult = '--';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // Default 2 inputs
    _addNewInput();
    _addNewInput();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
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

  // --- LOGIC: Add New Input Box ---
  void _addNewInput() {
    final controller = TextEditingController();
    controller.addListener(_calculateGcfLcm);
    setState(() {
      _controllers.add(controller);
    });
  }

  // --- MATH HELPER: GCD of two numbers ---
  int _gcd(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a.abs();
  }

  // --- MATH HELPER: LCM of two numbers ---
  int _lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a ~/ _gcd(a, b)) * b.abs();
  }

  // --- LOGIC: Real-time Calculation (GCF & LCM) ---
  void _calculateGcfLcm() {
    List<int> numbers = [];

    // Saare input fields se valid INTEGERS nikalna (GCF/LCM sirf whole numbers pe kaam karta hai)
    for (var controller in _controllers) {
      int? val = int.tryParse(controller.text.trim());
      if (val != null && val > 0) { // 0 ya negative numbers ko skip karo
        numbers.add(val);
      }
    }

    if (numbers.isEmpty) {
      setState(() {
        _gcfResult = '--';
        _lcmResult = '--';
      });
      return;
    }

    if (numbers.length == 1) {
      // Agar sirf 1 number hai, toh wahi GCF aur LCM hoga
      setState(() {
        _gcfResult = numbers[0].toString();
        _lcmResult = numbers[0].toString();
      });
      return;
    }

    // 1. Calculate GCF (GCD) array ke liye
    int resultGcf = numbers[0];
    for (int i = 1; i < numbers.length; i++) {
      resultGcf = _gcd(resultGcf, numbers[i]);
    }

    // 2. Calculate LCM array ke liye
    int resultLcm = numbers[0];
    for (int i = 1; i < numbers.length; i++) {
      resultLcm = _lcm(resultLcm, numbers[i]);
    }

    // State Update karein
    setState(() {
      _gcfResult = resultGcf.toString();
      _lcmResult = resultLcm.toString();
    });
  }

  // --- LOGIC: Remove Input Box ---
  void _removeInput(int index) {
    if (_isHapticsEnabled) HapticFeedback.lightImpact();
    setState(() {
      _controllers[index].removeListener(_calculateGcfLcm);
      _controllers[index].dispose();
      _controllers.removeAt(index);
      _calculateGcfLcm();
    });
  }

  // --- WIDGET HELPER: Result Row (Updated with Sub-label) ---
  Widget _buildResultRow(String label, String subLabel, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Side: Title and Full Form
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subLabel, style: TextStyle(color: AppColors.textGrey(context).withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          // Right Side: Calculated Value
          Text(value, style: TextStyle(color: AppColors.cyanColor(context), fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // --- 1. TOP BAR ---
          CustomTopBar(
            toolId: 'gcf_lcm',
            title: 'GCF & LCM',
            iconPath: 'assets/images/gcf_and_lcm.png',
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

                  // Label
                  Text('Values', style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // --- 3, 4, 5, 6. DYNAMIC GRID FOR INPUTS ---
                  Container(
                    padding: const EdgeInsets.all(10), // Card ke andar ki spacing
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor(context).withOpacity(0.5), // Main card background
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                      border: Border.all(color: Colors.white.withOpacity(0.05)), // Subtle border
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 240, // Max height set kar di
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 2,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: _controllers.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              // Main Input Field
                              TextField(
                                controller: _controllers[index],
                                keyboardType: TextInputType.number, // GCF/LCM sirf integer pe hoga
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                                cursorColor: AppColors.cyanColor(context),
                                decoration: InputDecoration(
                                  hintText: 'No. ${index + 1}',
                                  hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.4), fontSize: 16),
                                  filled: true,
                                  fillColor: AppColors.surfaceColor(context).withOpacity(0.9), // Darker inner box
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.textGrey(context).withOpacity(0.5)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.cyanColor(context), width: 1.5),
                                  ),
                                ),
                              ),

                              // Delete 'x' Button
                              if (_controllers[index].text.isEmpty && _controllers.length > 2)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeInput(index),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgColor(context).withOpacity(0.9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: AppColors.textGrey(context),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- 7 & 8. ADD VALUES TEXT & ADD BUTTON ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add more values',
                        style: TextStyle(color: AppColors.textGrey(context), fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_isHapticsEnabled) HapticFeedback.lightImpact();
                          _addNewInput();
                          FocusScope.of(context).unfocus();
                        },
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- 9. RESULTS SECTION ---
                  Text('Results', style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor(context).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.textGrey(context).withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        // NAYA: Label ke sath sub-label (full form) pass kiya
                        _buildResultRow('GCF', 'Greatest Common Factor', _gcfResult),
                        _buildResultRow('LCM', 'Lowest Common Multiple', _lcmResult, isLast: true),
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
    );
  }
}