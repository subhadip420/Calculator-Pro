import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_action_button.dart';
import 'custom_converter_keyboard.dart';
import 'custom_conversion_card.dart';
import 'package:calculator_pro/custom_unit_selector_sheet.dart';

class TemperatureConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const TemperatureConverterView({super.key, required this.onBack});

  @override
  State<TemperatureConverterView> createState() => _TemperatureConverterViewState();
}

class _TemperatureConverterViewState extends State<TemperatureConverterView> {
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  bool _isHapticsEnabled = true;

  bool isFromSelected = true;

  String fromUnit = 'Celsius';
  String fromSymbol = '°C';
  String fromValue = '0';

  String toUnit = 'Fahrenheit';
  String toSymbol = '°F';
  String toValue = '32';

  late TextEditingController _fromController;
  late TextEditingController _toController;

  @override
  void initState() {
    super.initState();
    _loadHaptics();

    _fromController = TextEditingController(text: fromValue);
    _toController = TextEditingController(text: toValue);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _loadHaptics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    });
  }

  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) return '0';
    String res = value.toStringAsPrecision(8);
    // Remove trailing zeros if it's a decimal (but avoid corrupting scientific 'e' notation)
    if (res.contains('.') && !res.contains('e')) {
      res = res.replaceAll(RegExp(r'0*$'), '');
      res = res.replaceAll(RegExp(r'\.$'), '');
    }
    return (res == '-0' || res == '-0.0') ? '0' : res;
  }

  // --- NAYA FIX: EXACT TEMPERATURE FORMULAS (Base Unit: Kelvin) ---
  double _convertToKelvin(double val, String unit) {
    switch (unit) {
      case 'Celsius': return val + 273.15;
      case 'Fahrenheit': return (val - 32) * 5 / 9 + 273.15;
      case 'Kelvin': return val;
      case 'Rankine': return val * 5 / 9;
      case 'Electron volt': return val * 11604.525; // 1 eV ≈ 11604.5 K
      case 'Planck temperature': return val * 1.416784e32;
      case 'Gas mark': return (val * 14) + 121 + 273.15; // Celsius to Kelvin
      case 'Delisle': return 373.15 - (val * 2 / 3);
      case 'Newton': return val * 100 / 33 + 273.15;
      case 'Réaumur': return val * 5 / 4 + 273.15;
      case 'Rømer': return (val - 7.5) * 40 / 21 + 273.15;
      default: return val;
    }
  }

  double _convertFromKelvin(double kelvin, String unit) {
    switch (unit) {
      case 'Celsius': return kelvin - 273.15;
      case 'Fahrenheit': return (kelvin - 273.15) * 9 / 5 + 32;
      case 'Kelvin': return kelvin;
      case 'Rankine': return kelvin * 9 / 5;
      case 'Electron volt': return kelvin / 11604.525;
      case 'Planck temperature': return kelvin / 1.416784e32;
      case 'Gas mark': return (kelvin - 273.15 - 121) / 14;
      case 'Delisle': return (373.15 - kelvin) * 3 / 2;
      case 'Newton': return (kelvin - 273.15) * 33 / 100;
      case 'Réaumur': return (kelvin - 273.15) * 4 / 5;
      case 'Rømer': return (kelvin - 273.15) * 21 / 40 + 7.5;
      default: return kelvin;
    }
  }

  void _calculateConversion() {
    if (isFromSelected) {
      double inputValue = double.tryParse(fromValue) ?? 0.0;
      if (fromValue == '-' || fromValue.isEmpty) inputValue = 0.0; // Handle minus sign only

      double inKelvin = _convertToKelvin(inputValue, fromUnit);
      double result = _convertFromKelvin(inKelvin, toUnit);

      toValue = _formatResult(result);
      _toController.text = toValue;
    } else {
      double inputValue = double.tryParse(toValue) ?? 0.0;
      if (toValue == '-' || toValue.isEmpty) inputValue = 0.0;

      double inKelvin = _convertToKelvin(inputValue, toUnit);
      double result = _convertFromKelvin(inKelvin, fromUnit);

      fromValue = _formatResult(result);
      _fromController.text = fromValue;
    }
  }

  void _onKeyPress(String key) {
    setState(() {
      TextEditingController activeController = isFromSelected ? _fromController : _toController;

      int cursorPos = activeController.selection.baseOffset;
      if (cursorPos < 0) cursorPos = activeController.text.length;

      String currentText = activeController.text;

      // Handle Decimal
      if (key == '.' && currentText.contains('.')) return;

      String newText;

      // NAYA FIX: Minus/Negative Toggle Logic (Temperature can be negative)
      if (key == '-' || key == '+/-') {
        if (currentText.startsWith('-')) {
          newText = currentText.substring(1);
          if (cursorPos > 0) cursorPos -= 1;
        } else {
          if (currentText == '0') {
            newText = '-';
            cursorPos = 1;
          } else {
            newText = '-$currentText';
            cursorPos += 1;
          }
        }
      }
      // Normal Number Typing
      else {
        if (currentText == '0' && key != '.') {
          newText = key;
          cursorPos = 1;
        } else if (currentText == '-0' && key != '.') {
          newText = '-$key';
          cursorPos = 2;
        } else {
          newText = currentText.substring(0, cursorPos) + key + currentText.substring(cursorPos);
          cursorPos += key.length;
        }
      }

      activeController.text = newText;
      activeController.selection = TextSelection.collapsed(offset: cursorPos);

      if (isFromSelected) fromValue = newText;
      else toValue = newText;

      _calculateConversion();
    });
  }

  void _onBackspace() {
    setState(() {
      TextEditingController activeController = isFromSelected ? _fromController : _toController;
      int cursorPos = activeController.selection.baseOffset;

      if (cursorPos <= 0) return;

      String currentText = activeController.text;
      String newText = currentText.substring(0, cursorPos - 1) + currentText.substring(cursorPos);

      if (newText.isEmpty || newText == '-') {
        newText = '0';
      }

      activeController.text = newText;
      activeController.selection = TextSelection.collapsed(offset: newText == '0' ? 1 : cursorPos - 1);

      if (isFromSelected) fromValue = newText;
      else toValue = newText;

      _calculateConversion();
    });
  }

  void _onClear() {
    setState(() {
      fromValue = '0';
      toValue = '0';
      _fromController.text = '0';
      _toController.text = '0';

      _fromController.selection = const TextSelection.collapsed(offset: 1);
      _toController.selection = const TextSelection.collapsed(offset: 1);
      _calculateConversion();
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
        return const UnitSelectorSheet(category: 'Temperature');
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
    // Check if 1 degree equivalence looks good, else show formula or basic rate
    double inKelvin = _convertToKelvin(1.0, isFromSelected ? fromUnit : toUnit);
    double eqValue = _convertFromKelvin(inKelvin, isFromSelected ? toUnit : fromUnit);

    if (isFromSelected) {
      return '1 $fromSymbol = ${_formatResult(eqValue)} $toSymbol';
    } else {
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
                    'Temperature',
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
                        controller: _fromController,
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
                        controller: _toController,
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