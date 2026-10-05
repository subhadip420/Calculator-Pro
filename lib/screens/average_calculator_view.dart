import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';

class AverageCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const AverageCalculatorView({super.key, required this.onBack});

  @override
  State<AverageCalculatorView> createState() => _AverageCalculatorViewState();
}

class _AverageCalculatorViewState extends State<AverageCalculatorView> {
  bool _isHapticsEnabled = true;

  // Dynamic list of controllers for input fields
  final List<TextEditingController> _controllers = [];

  // Variables to hold real-time results
  String _mean = '--';
  String _median = '--';
  String _mode = '--';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // Default 2 inputs as requested
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
    // Real-time calculation ke liye listener attach kiya hai
    controller.addListener(_calculateAverageMetrics);
    setState(() {
      _controllers.add(controller);
    });
  }

  // --- LOGIC: Real-time Calculation (Mean, Median, Mode) ---
  void _calculateAverageMetrics() {
    List<double> numbers = [];

    // Saare input fields se valid numbers nikalna
    for (var controller in _controllers) {
      double? val = double.tryParse(controller.text.trim());
      if (val != null) {
        numbers.add(val);
      }
    }

    if (numbers.isEmpty) {
      setState(() {
        _mean = '--';
        _median = '--';
        _mode = '--';
      });
      return;
    }

    // 1. Calculate Mean (Average)
    double sum = numbers.reduce((a, b) => a + b);
    double meanVal = sum / numbers.length;

    // 2. Calculate Median
    numbers.sort();
    double medianVal;
    int mid = numbers.length ~/ 2;
    if (numbers.length % 2 != 0) {
      medianVal = numbers[mid];
    } else {
      medianVal = (numbers[mid - 1] + numbers[mid]) / 2;
    }

    // 3. Calculate Mode
    Map<double, int> frequency = {};
    for (var n in numbers) {
      frequency[n] = (frequency[n] ?? 0) + 1;
    }

    int maxFreq = 0;
    frequency.forEach((key, value) {
      if (value > maxFreq) maxFreq = value;
    });

    String modeResult = '--';
    if (maxFreq <= 1 && numbers.length > 1) {
      modeResult = 'None'; // Agar koi number repeat nahi hua
    } else {
      List<double> modes = [];
      frequency.forEach((key, value) {
        if (value == maxFreq) modes.add(key);
      });
      modeResult = modes.map((e) => _formatNumber(e)).join(', ');
    }

    // State Update karein
    setState(() {
      _mean = _formatNumber(meanVal);
      _median = _formatNumber(medianVal);
      _mode = modeResult;
    });
  }

  // --- LOGIC: Remove Input Box ---
  void _removeInput(int index) {
    if (_isHapticsEnabled) HapticFeedback.lightImpact();
    setState(() {
      // Listener hatana aur controller dispose karna zaroori hai memory leak se bachne ke liye
      _controllers[index].removeListener(_calculateAverageMetrics);
      _controllers[index].dispose();
      _controllers.removeAt(index);

      // Delete hone ke baad average wapas calculate karo
      _calculateAverageMetrics();
    });
  }

  // Helper method: Remove extra decimals (e.g. 5.0 -> 5)
  String _formatNumber(double num) {
    if (num == num.toInt()) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(2); // Max 2 decimal places
  }

  // --- WIDGET HELPER: Result Row ---
  Widget _buildResultRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: AppColors.cyanColor(context), fontSize: 20, fontWeight: FontWeight.bold)),
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
            toolId: 'average',
            title: 'Average Calculator',
            iconPath: 'assets/images/percentage-discount-symbol.png',
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

                  // --- 3, 4, 5, 6. DYNAMIC GRID FOR INPUTS (With Max Height & Delete Button) ---
                  // --- 3, 4, 5, 6. DYNAMIC GRID FOR INPUTS (Inside Main Card) ---
                  Container(
                    padding: const EdgeInsets.all(10), // Card ke andar ki spacing
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor(context).withOpacity(0.5), // Main card background
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                      border: Border.all(color: Colors.white.withOpacity(0.05)), // Subtle border
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 240, // Max height set kar di. Isse zyada hote hi scroll chalu hoga
                      ),
                      child: GridView.builder(
                        shrinkWrap: true, // Items kam honge toh ye chhota rahega
                        physics: const BouncingScrollPhysics(), // Max height cross karne par sub-scroll chalu
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
                                keyboardType: TextInputType.number,
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

                              // Delete 'x' Button (Top Right)
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
                                        color: AppColors.bgColor(context).withOpacity(0.9), // Background ke sath match
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
                          // Naya box add karne ka function
                          _addNewInput();

                          // Optional: Keyboard hide karna taaki naya box dikh jaye
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
                  const SizedBox(height: 32),

                  // --- 9, 10, 11, 12. RESULTS SECTION ---
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
                        _buildResultRow('Mean (Average)', _mean),
                        _buildResultRow('Median', _median),
                        _buildResultRow('Mode', _mode, isLast: true),
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