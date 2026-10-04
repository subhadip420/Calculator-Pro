import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';
import '../custom_toast.dart'; // Apna custom toast import karein

class BodyFatCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const BodyFatCalculatorView({super.key, required this.onBack});

  @override
  State<BodyFatCalculatorView> createState() => _BodyFatCalculatorViewState();
}

class _BodyFatCalculatorViewState extends State<BodyFatCalculatorView> {
  bool _isHapticsEnabled = true;

  // --- STATE VARIABLES ---
  String selectedGender = 'Male';
  int selectedAge = 25;
  String weightUnit = 'kg';
  String heightUnit = 'ft-in';
  String measureUnit = 'cm'; // For Neck, Waist, Hip

  late PageController _agePageController;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightCmController = TextEditingController();
  final TextEditingController _heightFtController = TextEditingController();
  final TextEditingController _heightInController = TextEditingController();

  // New Controllers for Body Fat
  final TextEditingController _neckController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _agePageController = PageController(viewportFraction: 0.2, initialPage: selectedAge - 1);
  }

  @override
  void dispose() {
    _agePageController.dispose();
    _weightController.dispose();
    _heightCmController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _hipController.dispose();
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

  void _onGenderSelect(String gender) {
    if (_isHapticsEnabled) HapticFeedback.selectionClick();
    setState(() {
      selectedGender = gender;
    });
  }

  // --- BODY FAT CALCULATION LOGIC (US Navy Method) ---
  void _calculateBodyFat() {
    if (_isHapticsEnabled) HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    // 1. Validation for Weight
    if (_weightController.text.trim().isEmpty) {
      showCustomToast(context, 'Please enter your weight');
      return;
    }
    double weight = double.tryParse(_weightController.text) ?? 0;
    if (weight <= 0) {
      showCustomToast(context, 'Invalid weight');
      return;
    }

    // 2. Validation for Height
    double heightCm = 0;
    if (heightUnit == 'cm') {
      if (_heightCmController.text.trim().isEmpty) {
        showCustomToast(context, 'Please enter height in cm');
        return;
      }
      heightCm = double.tryParse(_heightCmController.text) ?? 0;
    } else {
      if (_heightFtController.text.trim().isEmpty && _heightInController.text.trim().isEmpty) {
        showCustomToast(context, 'Please enter your height');
        return;
      }
      double ft = double.tryParse(_heightFtController.text) ?? 0;
      double inches = double.tryParse(_heightInController.text) ?? 0;
      heightCm = ((ft * 12) + inches) * 2.54; // Inches to cm convert
    }
    if (heightCm <= 0) {
      showCustomToast(context, 'Invalid height');
      return;
    }

    // 3. Validation for Body Measurements
    if (_neckController.text.trim().isEmpty) {
      showCustomToast(context, 'Please enter neck measurement');
      return;
    }
    double neck = double.tryParse(_neckController.text) ?? 0;

    if (_waistController.text.trim().isEmpty) {
      showCustomToast(context, 'Please enter waist measurement');
      return;
    }
    double waist = double.tryParse(_waistController.text) ?? 0;

    double hip = 0;
    if (selectedGender == 'Female') {
      if (_hipController.text.trim().isEmpty) {
        showCustomToast(context, 'Please enter hip measurement');
        return;
      }
      hip = double.tryParse(_hipController.text) ?? 0;
    }

    // Agar measurement inches me hai, toh formula ke liye usko CM me convert karna zaroori hai
    if (measureUnit == 'in') {
      neck *= 2.54;
      waist *= 2.54;
      hip *= 2.54;
    }

    if (neck <= 0 || waist <= 0 || (selectedGender == 'Female' && hip <= 0)) {
      showCustomToast(context, 'Please enter valid measurements');
      return;
    }

    // 4. US Navy Method Real Calculation
    double bodyFat = 0;

    try {
      if (selectedGender == 'Male') {
        // Safe check: Waist hamesha Neck se badi honi chahiye
        if (waist <= neck) {
          showCustomToast(context, 'Waist must be larger than neck');
          return;
        }

        // dart math.log natural log (base e) return karta hai, base 10 ke liye usko math.ln10 se divide karte hain
        double logWaistNeck = math.log(waist - neck) / math.ln10;
        double logHeight = math.log(heightCm) / math.ln10;

        bodyFat = 495 / (1.0324 - 0.19077 * logWaistNeck + 0.15456 * logHeight) - 450;

      } else {
        // Female calculation
        if ((waist + hip) <= neck) {
          showCustomToast(context, 'Waist + Hip must be larger than neck');
          return;
        }

        double logWaistHipNeck = math.log(waist + hip - neck) / math.ln10;
        double logHeight = math.log(heightCm) / math.ln10;

        bodyFat = 495 / (1.29579 - 0.35004 * logWaistHipNeck + 0.22100 * logHeight) - 450;
      }

      // Final boundary validation
      if (bodyFat.isNaN || bodyFat.isInfinite || bodyFat < 1 || bodyFat > 80) {
        showCustomToast(context, 'Measurements seem incorrect. Please verify.');
        return;
      }

    } catch (e) {
      showCustomToast(context, 'Error calculating Body Fat');
      return;
    }

    // 5. Open Result Dialog
    _showResultDialog(bodyFat);
  }

  void _showResultDialog(double bodyFat) {
    // Basic categories based on ACE Body Fat % chart
    String category = '';
    Color catColor = Colors.green;

    if (selectedGender == 'Male') {
      if (bodyFat < 6) { category = 'Essential Fat'; catColor = Colors.blueAccent; }
      else if (bodyFat <= 13) { category = 'Athletes'; catColor = Colors.green; }
      else if (bodyFat <= 17) { category = 'Fitness'; catColor = Colors.lightGreen; }
      else if (bodyFat <= 24) { category = 'Average'; catColor = Colors.orange; }
      else { category = 'Obese'; catColor = Colors.redAccent; }
    } else {
      if (bodyFat < 14) { category = 'Essential Fat'; catColor = Colors.blueAccent; }
      else if (bodyFat <= 20) { category = 'Athletes'; catColor = Colors.green; }
      else if (bodyFat <= 24) { category = 'Fitness'; catColor = Colors.lightGreen; }
      else if (bodyFat <= 31) { category = 'Average'; catColor = Colors.orange; }
      else { category = 'Obese'; catColor = Colors.redAccent; }
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.bgColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),
              side: BorderSide(
              color: AppColors.cyanColor(context).withOpacity(0.9,), // Theme ke hisaab se color
          width: 2, // Border ki motai
        ),
        ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Body Fat Percentage',
                  style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  '${bodyFat.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: AppColors.cyanColor(context),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    category,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isHapticsEnabled) HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.cyanColor(context).withOpacity(0.5), width: 1.5),
                      ),
                      elevation: 0,
                    ),
                    child: Text('Close', style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- REUSABLE WIDGETS ---
  Widget _buildUnitToggle(String option1, String option2, String currentValue, Function(String) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(option1, currentValue == option1, () => onChanged(option1)),
          _buildToggleOption(option2, currentValue == option2, () => onChanged(option2)),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        if (_isHapticsEnabled) HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bgColor(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.cyanColor(context) : Colors.transparent, width: 1.5),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)] : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.cyanColor(context) : AppColors.textGrey(context),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Widget _buildInputField({required TextEditingController controller, required String hint, required IconData icon}) {
  //   return TextField(
  //     controller: controller,
  //     keyboardType: TextInputType.number,
  //     style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.w600),
  //     cursorColor: AppColors.cyanColor(context),
  //     decoration: InputDecoration(
  //       hintText: hint,
  //       hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.4), fontSize: 16),
  //       prefixIcon: Icon(icon, color: AppColors.cyanColor(context).withOpacity(0.7)),
  //       filled: true,
  //       fillColor: AppColors.surfaceColor(context).withOpacity(0.3),
  //       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
  //       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textGrey(context).withOpacity(0.2))),
  //       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.cyanColor(context), width: 1.5)),
  //     ),
  //   );
  // }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    String? prefixLabel,
  }) {

    // NAYA LOGIC: Check karega ki Icon dikhana hai ya Text Label
    Widget? prefixWidget;
    if (prefixLabel != null) {
      prefixWidget = Container(
        width: 75,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          prefixLabel,
          style: TextStyle(
            color: AppColors.textColor(context),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (icon != null) {
      prefixWidget = Icon(icon, color: AppColors.cyanColor(context).withOpacity(0.7));
    }

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.w600),
      cursorColor: AppColors.cyanColor(context),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.4), fontSize: 16),
        prefixIcon: prefixWidget, // Yahan dynamic widget set ho jayega
        filled: true,
        fillColor: AppColors.surfaceColor(context).withOpacity(0.9),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textGrey(context).withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.cyanColor(context), width: 1.5)),
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
          CustomTopBar(
            toolId: 'body_fat',
            title: 'Body Fat Calculator',
            iconPath: 'assets/images/body_fat.png',
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
                  // Gender
                  Text('Gender', style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onGenderSelect('Male'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedGender == 'Male' ? AppColors.cyanColor(context).withOpacity(0.1) : AppColors.surfaceColor(context).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: selectedGender == 'Male' ? AppColors.cyanColor(context) : Colors.white.withOpacity(0.05), width: selectedGender == 'Male' ? 2 : 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.man_rounded, color: selectedGender == 'Male' ? AppColors.cyanColor(context) : AppColors.textGrey(context), size: 28),
                                const SizedBox(width: 8),
                                Text('Male', style: TextStyle(color: selectedGender == 'Male' ? AppColors.cyanColor(context) : AppColors.textGrey(context), fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onGenderSelect('Female'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedGender == 'Female' ? AppColors.cyanColor(context).withOpacity(0.1) : AppColors.surfaceColor(context).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: selectedGender == 'Female' ? AppColors.cyanColor(context) : Colors.white.withOpacity(0.05), width: selectedGender == 'Female' ? 2 : 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.woman_rounded, color: selectedGender == 'Female' ? AppColors.cyanColor(context) : AppColors.textGrey(context), size: 28),
                                const SizedBox(width: 8),
                                Text('Female', style: TextStyle(color: selectedGender == 'Female' ? AppColors.cyanColor(context) : AppColors.textGrey(context), fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Age
                  Text('Age', style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor(context).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.5), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.arrow_drop_down_rounded, color: AppColors.cyanColor(context), size: 30),
                        SizedBox(
                          height: 50,
                          child: PageView.builder(
                            controller: _agePageController,
                            onPageChanged: (index) {
                              if (_isHapticsEnabled) HapticFeedback.selectionClick();
                              setState(() => selectedAge = index + 1);
                            },
                            itemCount: 120,
                            itemBuilder: (context, index) {
                              bool isSelected = (index + 1) == selectedAge;
                              return Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: isSelected ? 32 : 18,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? AppColors.textColor(context) : AppColors.textGrey(context).withOpacity(0.5),
                                  ),
                                  child: Text('${index + 1}'),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Years', style: TextStyle(color: AppColors.textGrey(context), fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weight & Height
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Weight', style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildUnitToggle('lb', 'kg', weightUnit, (val) => setState(() => weightUnit = val)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(controller: _weightController, hint: 'Enter weight', icon: Icons.monitor_weight_outlined),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Height', style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildUnitToggle('ft-in', 'cm', heightUnit, (val) => setState(() => heightUnit = val)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (heightUnit == 'ft-in')
                    Row(
                      children: [
                        Expanded(child: _buildInputField(controller: _heightFtController, hint: 'Feet', icon: Icons.height_rounded)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInputField(controller: _heightInController, hint: 'Inches', icon: Icons.straighten_rounded)),
                      ],
                    )
                  else
                    _buildInputField(controller: _heightCmController, hint: 'Enter height in cm', icon: Icons.height_rounded),
                  const SizedBox(height: 24),

                  // Body Measurements
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Measurements', style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildUnitToggle('in', 'cm', measureUnit, (val) => setState(() => measureUnit = val)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  //_buildInputField(controller: _neckController, hint: 'Neck size', icon: Icons.accessibility_new_rounded),
                  _buildInputField(controller: _neckController, hint: 'Size', prefixLabel: 'Neck:'),
                  const SizedBox(height: 12),
                  //_buildInputField(controller: _waistController, hint: 'Waist size (at navel)', icon: Icons.straighten_rounded),
                  _buildInputField(controller: _waistController, hint: 'At navel', prefixLabel: 'Waist:'),
                  const SizedBox(height: 12),

                  // Hip measurement only for Females
                  if (selectedGender == 'Female')
                    Column(
                      children: [
                        //_buildInputField(controller: _hipController, hint: 'Hip size (widest part)', icon: Icons.boy_rounded),
                        _buildInputField(controller: _hipController, hint: 'Widest part', prefixLabel: 'Hip:'),
                        const SizedBox(height: 12),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_isHapticsEnabled) HapticFeedback.mediumImpact();
                        FocusManager.instance.primaryFocus?.unfocus();
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (mounted) _calculateBodyFat();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyanColor(context).withOpacity(0.9),
                        foregroundColor: const Color(0xFF003640),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      child: const Text('Calculate Body Fat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const SizedBox(height: 30),

                  // --- 10. BODY FAT INFORMATION CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor(context).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Description Section ---
                        Text(
                          'How is Body Fat calculated?',
                          style: TextStyle(
                            color: AppColors.textColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "This calculator uses the U.S. Navy Method to estimate your body fat percentage. It requires your height, neck, and waist measurements (along with hip measurements for women) to provide a reasonably accurate estimation without needing specialized equipment.",
                          style: TextStyle(
                            color: AppColors.textGrey(context).withOpacity(0.9),
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 24),

                        // --- Formula Section ---
                        Text(
                          'U.S. Navy Formulas',
                          style: TextStyle(
                            color: AppColors.textColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'For Men:',
                          style: TextStyle(color: AppColors.cyanColor(context), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '495 / (1.0324 - 0.19077 * log10(waist - neck) + 0.15456 * log10(height)) - 450',
                          style: TextStyle(color: AppColors.textGrey(context), fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'For Women:',
                          style: TextStyle(color: AppColors.cyanColor(context), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '495 / (1.29579 - 0.35004 * log10(waist + hip - neck) + 0.22100 * log10(height)) - 450',
                          style: TextStyle(color: AppColors.textGrey(context), fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 24),

                        // --- Categories Section ---
                        Text(
                          "Body Fat Categories (ACE Chart)",
                          style: TextStyle(
                            color: AppColors.textColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Body Fat Table Section ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Table(
                            border: TableBorder.all(
                              color: AppColors.cyanColor(context).withOpacity(0.5),
                              width: 1,
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(1.5),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                            },
                            children: [
                              // Header Row
                              TableRow(
                                decoration: BoxDecoration(
                                  color: AppColors.cyanColor(context).withOpacity(0.2), // Themed Header
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Text('Category', style: TextStyle(color: AppColors.cyanColor(context), fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Text('Men', style: TextStyle(color: AppColors.cyanColor(context), fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Text('Women', style: TextStyle(color: AppColors.cyanColor(context), fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                  ),
                                ],
                              ),
                              // Data Rows
                              _buildFatTableRow('Essential Fat', '2-5%', '10-13%', context),
                              _buildFatTableRow('Athletes', '6-13%', '14-20%', context),
                              _buildFatTableRow('Fitness', '14-17%', '21-24%', context),
                              _buildFatTableRow('Average', '18-24%', '25-31%', context),
                              _buildFatTableRow('Obese', '25%+', '32%+', context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for Body Fat table rows
  TableRow _buildFatTableRow(String category, String men, String women, BuildContext context) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            category,
            style: TextStyle(color: AppColors.textGrey(context), fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              men,
              style: TextStyle(color: AppColors.textColor(context), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              women,
              style: TextStyle(color: AppColors.textColor(context), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}