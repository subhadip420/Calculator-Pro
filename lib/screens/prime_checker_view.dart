import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';

class PrimeCheckerView extends StatefulWidget {
  final VoidCallback onBack;

  const PrimeCheckerView({super.key, required this.onBack});

  @override
  State<PrimeCheckerView> createState() => _PrimeCheckerViewState();
}

class _PrimeCheckerViewState extends State<PrimeCheckerView> {
  bool _isHapticsEnabled = true;

  final TextEditingController _inputController = TextEditingController();

  // Results store karne ke liye variables
  String _isPrimeResult = '--';
  String _nextPrimeResult = '--';
  String _primeFactorsResult = '--';

  // NAYA: Prime check track karne ke liye (Tick mark ke liye)
  bool _isPrime = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _inputController.addListener(_calculatePrimeInfo);
  }

  @override
  void dispose() {
    _inputController.dispose();
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

  // --- MATH HELPER: Check if a number is prime ---
  bool _isPrimeCheck(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6) {
      if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
  }

  // --- MATH HELPER: Find the next prime number ---
  int _getNextPrime(int n) {
    if (n < 2) return 2;
    int prime = n;
    bool found = false;
    while (!found) {
      prime++;
      if (_isPrimeCheck(prime)) {
        found = true;
      }
    }
    return prime;
  }

  // --- MATH HELPER: Calculate prime factors ---
  String _getPrimeFactors(int n) {
    if (n <= 1) return 'None';
    List<int> factors = [];
    while (n % 2 == 0) {
      factors.add(2);
      n ~/= 2;
    }
    for (int i = 3; i * i <= n; i += 2) {
      while (n % i == 0) {
        factors.add(i);
        n ~/= i;
      }
    }
    if (n > 2) {
      factors.add(n);
    }
    return factors.join(' × ');
  }

  // --- LOGIC: Real-time Calculation ---
  void _calculatePrimeInfo() {
    String text = _inputController.text.trim();
    int? number = int.tryParse(text);

    setState(() {
      if (number == null || number < 0) {
        _isPrimeResult = '--';
        _nextPrimeResult = '--';
        _primeFactorsResult = '--';
        _isPrime = false; // Reset
        return;
      }

      // 1. Is Prime?
      _isPrime = _isPrimeCheck(number);
      _isPrimeResult = _isPrime ? 'Yes' : 'No';

      // 2. Next Prime
      _nextPrimeResult = _getNextPrime(number).toString();

      // 3. Prime Factors
      _primeFactorsResult = _getPrimeFactors(number);
    });
  }

  // --- WIDGET HELPER: Result Row (Updated with Click & Color logic) ---
  Widget _buildResultRow({
    IconData? icon,
    Color? iconColor,
    String? customIconText,
    required String title,
    required String value,
    bool isLast = false,
    VoidCallback? onTap, // Click event ke liye naya parameter
  }) {
    Widget content = Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                child: icon != null
                    ? Icon(icon, color: iconColor ?? AppColors.textGrey(context), size: 22)
                    : Text(
                        customIconText ?? '',
                        style: TextStyle(color: AppColors.textGrey(context), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                // Agar clickable hai toh thoda alag highlight dikha sakte hain (optional)
                color: AppColors.cyanColor(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    // Agar onTap pass kiya hai aur value '--' nahi hai, toh clickable banayein
    if (onTap != null && value != '--') {
      return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: content);
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          // Screen pe kahin bhi click karne se keyboard hide ho jayega
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.opaque, // Khali jagah par bhi click detect karne ke liye
        child: Column(
          children: [
            CustomTopBar(
              toolId: 'prime_checker',
              title: 'Prime Checker',
              iconPath: 'assets/images/percentage-discount-symbol.png',
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
                    Text(
                      'Value',
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _inputController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 22, fontWeight: FontWeight.bold),
                      cursorColor: AppColors.cyanColor(context),
                      decoration: InputDecoration(
                        hintText: '--',
                        hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.4), fontSize: 22),
                        filled: true,
                        fillColor: AppColors.surfaceColor(context).withOpacity(0.4),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: Icon(Icons.edit_rounded, color: AppColors.textGrey(context)),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 50),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.cyanColor(context), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Check if this value is prime',
                            style: TextStyle(color: AppColors.textColor(context), fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    Text(
                      'Result',
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.textGrey(context).withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          // 1. Is Prime (Green Tick Logic added)
                          _buildResultRow(
                            icon: _isPrime ? Icons.check_circle_rounded : Icons.help_outline_rounded,
                            iconColor: _isPrime ? AppColors.greenColor(context) : AppColors.textGrey(context),
                            title: 'Is prime',
                            value: _isPrimeResult,
                          ),
                          // 2. Next Prime (Clickable Logic added)
                          _buildResultRow(
                            icon: Icons.arrow_forward_rounded,
                            title: 'Next prime',
                            value: _nextPrimeResult,
                            onTap: () {
                              if (_isHapticsEnabled) HapticFeedback.lightImpact();
                              // Input controller update karte hi listener apne aap calculation trigger kar dega
                              _inputController.text = _nextPrimeResult;
                            },
                          ),
                          // 3. Prime Factors
                          _buildResultRow(
                            customIconText: 'x²',
                            title: 'Prime factors',
                            value: _primeFactorsResult,
                            isLast: true,
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
      ),
    );
  }
}
