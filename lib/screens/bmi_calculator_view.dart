import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_toast.dart';
import '../custom_top_bar.dart';

class BmiCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const BmiCalculatorView({super.key, required this.onBack});

  @override
  State<BmiCalculatorView> createState() => _BmiCalculatorViewState();
}

class _BmiCalculatorViewState extends State<BmiCalculatorView> {
  bool _isHapticsEnabled = true;

  // --- STATE VARIABLES ---
  String selectedGender = 'Male'; // Default Male
  int selectedAge = 25; // Default Age
  String weightUnit = 'kg'; // Default kg
  String heightUnit = 'ft-in'; // Default ft-in

  late PageController _agePageController;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightCmController = TextEditingController();
  final TextEditingController _heightFtController = TextEditingController();
  final TextEditingController _heightInController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // Age selector ke liye PageController (viewportFraction 0.2 se 5 items dikhenge screen par)
    _agePageController = PageController(viewportFraction: 0.2, initialPage: selectedAge - 1);
  }

  @override
  void dispose() {
    _agePageController.dispose();
    _weightController.dispose();
    _heightCmController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
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

// --- BMI CALCULATION LOGIC ---
  void _calculateBMI() {
    if (_isHapticsEnabled) HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus(); // Hide keyboard

    if (_weightController.text.trim().isEmpty) {
      showCustomToast(context, 'Please enter your weight');
      return;
    }

    double weight = double.tryParse(_weightController.text) ?? 0;
    if (weight <= 0) {
      showCustomToast(context, 'Please enter a valid weight');
      return;
    }

    double heightInMeters = 0;

    if (heightUnit == 'cm') {
      if (_heightCmController.text.trim().isEmpty) {
        showCustomToast(context, 'Please enter your height in cm');
        return;
      }
      double cm = double.tryParse(_heightCmController.text) ?? 0;
      if (cm <= 0) {
        showCustomToast(context, 'Please enter a valid height');
        return;
      }
      heightInMeters = cm / 100;
    } else {
      if (_heightFtController.text.trim().isEmpty && _heightInController.text.trim().isEmpty) {
        showCustomToast(context, 'Please enter your height');
        return;
      }
      double ft = double.tryParse(_heightFtController.text) ?? 0;
      double inches = double.tryParse(_heightInController.text) ?? 0;
      if (ft <= 0 && inches <= 0) {
        showCustomToast(context, 'Please enter a valid height');
        return;
      }
      heightInMeters = ((ft * 12) + inches) * 0.0254; // Convert inches to meters
    }

    // Convert lb to kg if needed
    if (weightUnit == 'lb') {
      weight = weight * 0.453592;
    }

    // Formula: BMI = kg / m^2
    double bmi = weight / (heightInMeters * heightInMeters);

    _showResultDialog(bmi);
  }

  // --- SHOW RESULT DIALOG ---
  void _showResultDialog(double bmi) {
    String category = '';
    Color catColor = Colors.green;
    String message = '';

    // WHO Categories
    if (bmi < 18.5) {
      category = 'Underweight';
      catColor = Colors.blueAccent;
      message = 'You are underweight. Focus on a nutrient-rich diet.';
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      category = 'Normal';
      catColor = Colors.green;
      message = 'You are doing great. Keep up the good work!';
    } else if (bmi >= 25.0 && bmi <= 29.9) {
      category = 'Overweight';
      catColor = Colors.orange;
      message = 'You are slightly overweight. Regular exercise will help.';
    } else {
      category = 'Obese';
      catColor = Colors.redAccent;
      message = 'You are in the obese category. Focus on diet and exercise.';
    }

    // Format Strings for Summary
    String heightStr = heightUnit == 'cm'
        ? '${_heightCmController.text} cm'
        : '${_heightFtController.text} ft ${_heightInController.text.isNotEmpty ? _heightInController.text : "0"} in';
    String weightStr = '${_weightController.text} $weightUnit';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.bgColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppColors.cyanColor(context).withOpacity(0.9), // Border ka color
              width: 2, // Border ki motai
            ),),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. GAUGE & BMI VALUE
                SizedBox(
                  height: 160,
                  width: 250,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CustomPaint(
                        size: const Size(250, 150),
                        painter: BmiGaugePainter(
                          bmi,
                          AppColors.surfaceColor(context).withOpacity(0.5),
                          AppColors.textColor(context)
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            bmi.toStringAsFixed(1),
                            style: TextStyle(
                              color: AppColors.cyanColor(context),
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'BMI',
                            style: TextStyle(
                              color: AppColors.textColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. CATEGORY PILL
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: catColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. SUMMARY ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCol(selectedGender, '', icon: selectedGender == 'Male' ? Icons.man_rounded : Icons.woman_rounded),
                    _buildSummaryCol('Age', '$selectedAge Yrs'),
                    _buildSummaryCol('Weight', weightStr),
                    _buildSummaryCol('Height', heightStr),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. MESSAGE CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor(context).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.health_and_safety_rounded, color: catColor, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: catColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5. CLOSE BUTTON
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
                        borderRadius: BorderRadius.circular(26),
                        side: BorderSide(
                          color: AppColors.cyanColor(context).withOpacity(0.5), // Border ka color
                          width: 1.5, // Border ki motai
                        ),),
                      elevation: 0,
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCol(String title, String value, {IconData? icon}) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: AppColors.textGrey(context).withOpacity(0.7), fontSize: 13)),
        const SizedBox(height: 6),
        if (icon != null)
          Icon(icon, color: AppColors.cyanColor(context), size: 28)
        else
          Text(value, style: TextStyle(color: AppColors.textColor(context), fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- REUSABLE TOGGLE BUTTON (For Weight & Height Units) ---
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
          border: Border.all(
            color: isSelected ? AppColors.cyanColor(context) : Colors.transparent,
            width: 1.5, // Border ki motai
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)]
              : [],
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

  // --- REUSABLE INPUT FIELD ---
  // --- REUSABLE INPUT FIELD ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    // Outer Container se decoration hata diya hai, ab sab kuch TextField ke andar hoga
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.w600),
      cursorColor: AppColors.cyanColor(context),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.4), fontSize: 16),
        prefixIcon: Icon(icon, color: AppColors.cyanColor(context).withOpacity(0.7)),

        // Background color
        filled: true,
        fillColor: AppColors.surfaceColor(context).withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),

        // 1. Default (Unfocused) Border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.textGrey(context).withOpacity(0.2)),
        ),

        // 2. Focused (Active) Border - Jab user type karne ke liye click karega
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.cyanColor(context), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // Screen lock karne ke liye taaki scroll smoothly ho
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // --- 1. TOP BAR ---
          CustomTopBar(
            toolId: 'bmi',
            title: 'BMI Calculator',
            iconPath: 'assets/images/percentage-discount-symbol.png',
            onBack: widget.onBack,
            isHapticsEnabled: _isHapticsEnabled,
          ),

          // --- MAIN SCROLLABLE BODY ---
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 2. BANNER AD PLACEHOLDER ---
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(12),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.surfaceColor(context).withOpacity(0.5),
                  //     borderRadius: BorderRadius.circular(16),
                  //     border: Border.all(color: Colors.white.withOpacity(0.05)),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.info_outline_rounded, color: AppColors.cyanColor(context)),
                  //       const SizedBox(width: 12),
                  //       Expanded(
                  //         child: Text(
                  //           'Smaller meals help prevent overeating and weight gain.',
                  //           style: TextStyle(color: AppColors.textGrey(context), fontSize: 13),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

                  // --- 3. GENDER SELECTION ---
                  Text(
                    'Gender',
                    style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onGenderSelect('Male'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedGender == 'Male'
                                  ? AppColors.cyanColor(context).withOpacity(0.1)
                                  : AppColors.surfaceColor(context).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selectedGender == 'Male'
                                    ? AppColors.cyanColor(context)
                                    : Colors.white.withOpacity(0.05),
                                width: selectedGender == 'Male' ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.man_rounded,
                                    color: selectedGender == 'Male' ? AppColors.cyanColor(context) : AppColors.textGrey(context),
                                    size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  'Male',
                                  style: TextStyle(
                                    color: selectedGender == 'Male' ? AppColors.cyanColor(context) : AppColors.textGrey(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                              color: selectedGender == 'Female'
                                  ? AppColors.cyanColor(context).withOpacity(0.1)
                                  : AppColors.surfaceColor(context).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selectedGender == 'Female'
                                    ? AppColors.cyanColor(context)
                                    : Colors.white.withOpacity(0.05),
                                width: selectedGender == 'Female' ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.woman_rounded,
                                    color: selectedGender == 'Female' ? AppColors.cyanColor(context) : AppColors.textGrey(context),
                                    size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  'Female',
                                  style: TextStyle(
                                    color: selectedGender == 'Female' ? AppColors.cyanColor(context) : AppColors.textGrey(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // --- 4. HORIZONTAL AGE SELECTOR ---
                  // --- 4. HORIZONTAL AGE SELECTOR (IN CARD) ---
                  Text(
                    'Age',
                    style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor(context).withOpacity(0.7), // App ka default card color
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
                            itemCount: 120, // Max age 120
                            itemBuilder: (context, index) {
                              int age = index + 1;
                              bool isSelected = age == selectedAge;
                              return Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: isSelected ? 32 : 18, // Selected number ko thoda aur bada (32) kiya hai
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? AppColors.textColor(context) : AppColors.textGrey(context).withOpacity(0.5),
                                  ),
                                  child: Text(age.toString()),
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
                  const SizedBox(height: 12),

                  // --- 5 & 6. WEIGHT SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weight',
                        style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      _buildUnitToggle('lb', 'kg', weightUnit, (val) => setState(() => weightUnit = val)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _weightController,
                    hint: 'Enter weight',
                    icon: Icons.monitor_weight_outlined,
                  ),
                  const SizedBox(height: 12),

                  // --- 7 & 8. HEIGHT SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Height',
                        style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      _buildUnitToggle('ft-in', 'cm', heightUnit, (val) => setState(() => heightUnit = val)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Conditional Height Input Boxes
                  if (heightUnit == 'ft-in')
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _heightFtController,
                            hint: 'Feet',
                            icon: Icons.height_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            controller: _heightInController,
                            hint: 'Inches',
                            icon: Icons.straighten_rounded,
                          ),
                        ),
                      ],
                    )
                  else
                    _buildInputField(
                      controller: _heightCmController,
                      hint: 'Enter height in cm',
                      icon: Icons.height_rounded,
                    ),

                  const SizedBox(height: 20),

                  // --- 9. CALCULATE BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_isHapticsEnabled) HapticFeedback.mediumImpact();
                        // FocusManager.instance.primaryFocus?.unfocus();
                        // _calculateBMI();
                        FocusManager.instance.primaryFocus?.unfocus();

                        // 2. Thoda wait karo taaki keyboard smoothly poora neeche chala jaye
                        await Future.delayed(const Duration(milliseconds: 300));

                        // 3. Phir BMI calculate aur Dialog open karo
                        if (mounted) {
                          _calculateBMI();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyanColor(context).withOpacity(0.9),
                        foregroundColor: const Color(0xFF003640), // Dark text on Cyan button
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Calculate BMI',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

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
                        // --- Formula Section ---
                        Text(
                          'How is the BMI calculated?',
                          style: TextStyle(
                            color: AppColors.textColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'BMI  =  ',
                              style: TextStyle(
                                color: AppColors.textColor(context),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Weight (Kg)',
                                  style: TextStyle(color: AppColors.textColor(context), fontSize: 15),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  height: 1,
                                  width: 140,
                                  color: AppColors.textGrey(context).withOpacity(0.5),
                                ),
                                Text(
                                  'Height (m) * Height (m)',
                                  style: TextStyle(color: AppColors.textColor(context), fontSize: 15),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 32),

                        // --- Description Section ---
                        Text(
                          'What is the Body Mass Index (BMI)',
                          style: TextStyle(
                            color: AppColors.textColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "The Body Mass Index or BMI is a useful estimation of your health based on your weight and your height. Although the BMI does not indicate your percentage of body fat, it is the most widely used diagnostic indicator of a person's optimal weight. Your BMI number will inform you if you are underweight, normal weight, or overweight. However, due to the wide variety of body types, muscle, bone mass, etc., it's not appropriate to use this as the only indication for diagnosis.",
                          style: TextStyle(
                            color: AppColors.textGrey(context).withOpacity(0.9),
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "According to the World Health Organization's (WHO), the BMI values for the average adult are:",
                          style: TextStyle(
                            color: AppColors.textGrey(context).withOpacity(0.9),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- BMI Table Section ---
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
                                      child: Text(
                                        'Category',
                                        style: TextStyle(
                                          color: AppColors.cyanColor(context),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Text(
                                        'BMI',
                                        style: TextStyle(
                                          color: AppColors.cyanColor(context),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Data Rows
                              _buildTableRow('Severe Thinness', '< 15.9', context),
                              _buildTableRow('Moderate Thinness', '16 - 16.9', context),
                              _buildTableRow('Mild Thinness', '17 - 18.4', context),
                              _buildTableRow('Normal Weight', '18.5 - 24.9', context),
                              _buildTableRow('Overweight', '25 - 29.9', context),
                              _buildTableRow('Obese Class I', '30 - 34.9', context),
                              _buildTableRow('Obese Class II', '35 - 39.9', context),
                              _buildTableRow('Obese Class III', '> 40', context),
                            ],
                          ),
                        ),
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

  // Helper method for table rows to keep code clean
  TableRow _buildTableRow(String category, String bmi, BuildContext context) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            category,
            style: TextStyle(color: AppColors.textGrey(context), fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              bmi,
              style: TextStyle(color: AppColors.textColor(context), fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}

// --- CUSTOM GAUGE PAINTER ---
class BmiGaugePainter extends CustomPainter {
  final double bmi;
  final Color innerColor;
  final Color needleColor;
  BmiGaugePainter(this.bmi, this.innerColor, this.needleColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw inner filled semi-circle
    final innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.70), math.pi, math.pi, true, innerPaint);

    final strokeWidth = 14.0;

    // Function to draw arc segments
    void drawSegment(double startVal, double endVal, Color color) {
      // Mapping BMI 12 to 42 across 180 degrees (pi)
      double startAngle = math.pi + ((startVal - 12) / 30) * math.pi;
      double sweepAngle = ((endVal - startVal) / 30) * math.pi;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Minor gap between segments for clean look
      canvas.drawArc(rect, startAngle, sweepAngle - 0.05, false, paint);
    }

    // Segments (Underweight, Normal, Overweight, Obese)
    drawSegment(12, 18.5, Colors.blueAccent);
    drawSegment(18.5, 25, Colors.green);
    drawSegment(25, 30, Colors.orange);
    drawSegment(30, 42, Colors.redAccent);

    // Draw Needle Indicator
    double needleBmi = bmi.clamp(12.0, 42.0);
    double needleAngle = math.pi + ((needleBmi - 12) / 30) * math.pi;

    final needleLength = radius * 0.90;
    final needleEndX = center.dx + needleLength * math.cos(needleAngle);
    final needleEndY = center.dy + needleLength * math.sin(needleAngle);

    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, Offset(needleEndX, needleEndY), needlePaint);
    canvas.drawCircle(center, 6, Paint()..color = needleColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}