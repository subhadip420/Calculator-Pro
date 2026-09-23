import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_action_button.dart';
import 'custom_converter_keyboard.dart';
import 'custom_conversion_card.dart';
import 'package:calculator_pro/unit_selector_sheet.dart';

class SpeedConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const SpeedConverterView({super.key, required this.onBack});

  @override
  State<SpeedConverterView> createState() => _SpeedConverterViewState();
}

class _SpeedConverterViewState extends State<SpeedConverterView> {
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  bool _isHapticsEnabled = true;

  bool isFromSelected = true;

  String fromUnit = 'Kilometers per hour';
  String fromSymbol = 'km/h';
  String fromValue = '1';

  String toUnit = 'Miles per hour';
  String toSymbol = 'mph';
  String toValue = '0.621371';

  // Base unit for speed: Meters per second (m/s)
  final Map<String, double> speedConversionRates = {
    'Meters per second': 1.0,
    'Kilometers per hour': 0.277777777778, // 1 km/h = 1/3.6 m/s
    'Miles per hour': 0.44704,
    'Feet per second': 0.3048,
    'Knots': 0.514444444444,
    'Mach': 343.0, // Approximate speed of sound at 20°C
  };

  @override
  void initState() {
    super.initState();
    _loadHaptics();
  }

  Future<void> _loadHaptics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    });
  }

  String _formatResult(double value) {
    if (value == 0) return '0';
    String res = value.toStringAsPrecision(8);
    if (res.contains('.')) {
      res = res.replaceAll(RegExp(r'0*$'), '');
      res = res.replaceAll(RegExp(r'\.$'), '');
    }
    return res;
  }

  void _calculateConversion() {
    double rateFrom = speedConversionRates[fromUnit] ?? 1.0;
    double rateTo = speedConversionRates[toUnit] ?? 1.0;

    if (isFromSelected) {
      double inputValue = double.tryParse(fromValue) ?? 0.0;
      double result = (inputValue * rateFrom) / rateTo;
      toValue = _formatResult(result);
    } else {
      double inputValue = double.tryParse(toValue) ?? 0.0;
      double result = (inputValue * rateTo) / rateFrom;
      fromValue = _formatResult(result);
    }
  }

  void _onKeyPress(String key) {
    setState(() {
      String currentValue = isFromSelected ? fromValue : toValue;

      if (key == '.' && currentValue.contains('.')) return;

      if (currentValue == '0' && key != '.') {
        currentValue = key;
      } else {
        currentValue += key;
      }

      if (isFromSelected) fromValue = currentValue;
      else toValue = currentValue;

      _calculateConversion();
    });
  }

  void _onBackspace() {
    setState(() {
      if (isFromSelected) {
        if (fromValue.isNotEmpty) fromValue = fromValue.substring(0, fromValue.length - 1);
        if (fromValue.isEmpty || fromValue == '-') fromValue = '0';
      } else {
        if (toValue.isNotEmpty) toValue = toValue.substring(0, toValue.length - 1);
        if (toValue.isEmpty || toValue == '-') toValue = '0';
      }
      _calculateConversion();
    });
  }

  void _onClear() {
    setState(() {
      fromValue = '0';
      toValue = '0';
    });
  }

  void _swapUnits() {
    if (_isHapticsEnabled) HapticFeedback.lightImpact();
    setState(() {
      String tempUnit = fromUnit;
      String tempSymbol = fromSymbol;

      fromUnit = toUnit;
      fromSymbol = toSymbol;

      toUnit = tempUnit;
      toSymbol = tempSymbol;

      _calculateConversion();
    });
  }

  void _showUnitPicker(bool isFrom) async {
    if (_isHapticsEnabled) HapticFeedback.selectionClick();

    final selectedUnit = await showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return const UnitSelectorSheet(category: 'Speed');
      },
    );

    if (selectedUnit != null) {
      setState(() {
        if (isFrom) {
          fromUnit = selectedUnit['name']!;
          fromSymbol = selectedUnit['symbol']!;
        } else {
          toUnit = selectedUnit['name']!;
          toSymbol = selectedUnit['symbol']!;
        }
        _calculateConversion();
      });
    }
  }

  String _getEquivalenceText() {
    double rateFrom = speedConversionRates[fromUnit] ?? 1.0;
    double rateTo = speedConversionRates[toUnit] ?? 1.0;

    if (isFromSelected) {
      double eqValue = rateFrom / rateTo;
      return '1 $fromSymbol = ${_formatResult(eqValue)} $toSymbol';
    } else {
      double eqValue = rateTo / rateFrom;
      return '1 $toSymbol = ${_formatResult(eqValue)} $fromSymbol';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- 1. TOP BAR ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionButton(
                icon: Icons.arrow_back_ios_new_rounded,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {
                  if (_isHapticsEnabled) HapticFeedback.lightImpact();
                  widget.onBack();
                },
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Speed Conversion',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ActionButton(
                icon: Icons.star_border_rounded,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {
                  if (_isHapticsEnabled) HapticFeedback.selectionClick();
                },
              ),
            ],
          ),
        ),

        // --- 2. MAIN CONVERSION CARDS ---
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConversionCard(
                        isActive: isFromSelected,
                        unitName: fromUnit,
                        unitSymbol: fromSymbol,
                        value: fromValue,
                        onTap: () {
                          setState(() { isFromSelected = true; });
                        },
                        onUnitTap: () => _showUnitPicker(true),
                      ),
                      const SizedBox(height: 16),
                      ConversionCard(
                        isActive: !isFromSelected,
                        unitName: toUnit,
                        unitSymbol: toSymbol,
                        value: toValue,
                        onTap: () {
                          setState(() { isFromSelected = false; });
                        },
                        onUnitTap: () => _showUnitPicker(false),
                      ),
                    ],
                  ),

                  // --- SWAP BUTTON ---
                  GestureDetector(
                    onTap: _swapUnits,
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: cyanColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: bgColor, width: 4),
                        boxShadow: [
                          BoxShadow(color: cyanColor.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                      child: const Icon(Icons.swap_vert_rounded, color: Color(0xFF003640), size: 26),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- 3. REAL-TIME EQUIVALENCE TEXT ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey<String>(_getEquivalenceText()),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(
                _getEquivalenceText(),
                style: TextStyle(
                  color: cyanColor.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // --- 4. REUSABLE KEYBOARD ---
        ConverterKeyboard(
          isHapticsEnabled: _isHapticsEnabled,
          onKeyPress: _onKeyPress,
          onBackspace: _onBackspace,
          onClear: _onClear,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}