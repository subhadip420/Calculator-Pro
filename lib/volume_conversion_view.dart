import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_action_button.dart';
import 'custom_converter_keyboard.dart';
import 'custom_conversion_card.dart';
import 'package:calculator_pro/custom_unit_selector_sheet.dart';

class VolumeConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const VolumeConverterView({super.key, required this.onBack});

  @override
  State<VolumeConverterView> createState() => _VolumeConverterViewState();
}

class _VolumeConverterViewState extends State<VolumeConverterView> {
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  bool _isHapticsEnabled = true;

  // State Variables for Conversions
  bool isFromSelected = true;

  String fromUnit = 'Liter';
  String fromSymbol = 'L';
  String fromValue = '1';

  String toUnit = 'Milliliter';
  String toSymbol = 'mL';
  String toValue = '1000';

  // NAYA FIX: Controllers add kiye
  late TextEditingController _fromController;
  late TextEditingController _toController;

  // --- REAL MATH LOGIC: Har unit ki value in 1 Liter (Base Unit: L) ---
  final Map<String, double> volumeConversionRates = {
    'Cubic Meter': 1000.0,
    'Liter': 1.0,
    'Milliliter': 0.001,
    'Cubic Centimeter': 0.001,
    'Cubic Millimeter': 0.000001,
    'Gallon (US)': 3.785411784,
    'Quart (US)': 0.946352946,
    'Pint (US)': 0.473176473,
    'Cup (US)': 0.24,
    'Fluid Ounce (US)': 0.0295735,
    'Tablespoon (US)': 0.0147868,
    'Teaspoon (US)': 0.0049289,
    'Gallon (UK)': 4.54609,
    'Fluid Ounce (UK)': 0.0284131,
  };

  @override
  void initState() {
    super.initState();
    _loadHaptics();

    // NAYA FIX: Controllers initialize kiye
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

  // --- HELPER: Decimal Formatting ---
  String _formatResult(double value) {
    if (value == 0) return '0';
    String res = value.toStringAsPrecision(8);
    if (res.contains('.')) {
      res = res.replaceAll(RegExp(r'0*$'), '');
      res = res.replaceAll(RegExp(r'\.$'), '');
    }
    return res;
  }

  // --- CORE: Calculation Logic ---
  void _calculateConversion() {
    double rateFrom = volumeConversionRates[fromUnit] ?? 1.0;
    double rateTo = volumeConversionRates[toUnit] ?? 1.0;

    if (isFromSelected) {
      double inputValue = double.tryParse(fromValue) ?? 0.0;
      double result = (inputValue * rateFrom) / rateTo;
      toValue = _formatResult(result);
      _toController.text = toValue; // NAYA: Dusra controller update karna
    } else {
      double inputValue = double.tryParse(toValue) ?? 0.0;
      double result = (inputValue * rateTo) / rateFrom;
      fromValue = _formatResult(result);
      _fromController.text = fromValue; // NAYA: Dusra controller update karna
    }
  }

  // --- NAYA FIX: CURSOR BASED KEYBOARD LOGIC ---
  void _onKeyPress(String key) {
    setState(() {
      TextEditingController activeController = isFromSelected ? _fromController : _toController;

      int cursorPos = activeController.selection.baseOffset;
      if (cursorPos < 0) cursorPos = activeController.text.length;

      String currentText = activeController.text;

      if (key == '.' && currentText.contains('.')) return;

      String newText;
      if (currentText == '0' && key != '.') {
        newText = key;
        cursorPos = 0;
      } else {
        newText = currentText.substring(0, cursorPos) + key + currentText.substring(cursorPos);
      }

      activeController.text = newText;
      activeController.selection = TextSelection.collapsed(offset: cursorPos + key.length);

      if (isFromSelected) fromValue = newText;
      else toValue = newText;

      _calculateConversion();
    });
  }

  // --- NAYA FIX: CURSOR BASED BACKSPACE LOGIC ---
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
        return const UnitSelectorSheet(category: 'Volume');
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
    double rateFrom = volumeConversionRates[fromUnit] ?? 1.0;
    double rateTo = volumeConversionRates[toUnit] ?? 1.0;

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
                    'Volume Conversion',
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
                        controller: _fromController, // NAYA
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
                        controller: _toController, // NAYA
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