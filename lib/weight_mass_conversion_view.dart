import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_action_button.dart';
import 'custom_conversion_card.dart';
import 'custom_converter_keyboard.dart';
import 'package:calculator_pro/custom_unit_selector_sheet.dart';

import 'custom_unit_selector_sheet.dart';

class WeightMassConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const WeightMassConverterView({super.key, required this.onBack});

  @override
  State<WeightMassConverterView> createState() => _WeightMassConverterViewState();
}

class _WeightMassConverterViewState extends State<WeightMassConverterView> {
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  bool _isHapticsEnabled = true;

  // State Variables for Conversions
  bool isFromSelected = true;

  String fromUnit = 'Kilogram';
  String fromSymbol = 'kg';
  String fromValue = '1';

  String toUnit = 'Gram';
  String toSymbol = 'g';
  String toValue = '1000';

  // Controllers for Cursor Support
  late TextEditingController _fromController;
  late TextEditingController _toController;

  // --- REAL MATH LOGIC: Har unit ki value in 1 Kilogram (Base Unit: kg) ---
  final Map<String, double> weightConversionRates = {
    // Metric Units
    'Picogram': 1e-15, 'Nanogram': 1e-12, 'Microgram': 1e-9, 'Milligram': 1e-6,
    'Centigram': 1e-5, 'Decigram': 1e-4, 'Gram': 0.001, 'Decagram': 0.01,
    'Hectogram': 0.1, 'Kilogram': 1.0, 'Quintal': 100.0, 'Metric ton': 1000.0, 'Tonne': 1000.0,

    // Imperial Units
    'Grain': 0.00006479891, 'Dram': 0.001771845, 'Ounce': 0.02834952, 'Pound': 0.45359237,
    'Stone': 6.35029318, 'Quarter': 12.70058636, 'Short ton': 907.18474, 'Long ton': 1016.0469,

    // Scientific Units
    'Electron mass': 9.10938356e-31, 'Atomic mass unit': 1.66053904e-27, 'Dalton': 1.66053904e-27,
    'Proton mass': 1.6726219e-27, 'Planck mass': 2.176470e-8,

    // Astronomical Units
    'Earth mass': 5.9722e24, 'Solar mass': 1.98847e30,

    // Regional & Historical Units
    'Arabic dirham': 0.003125, 'Arabic mithqal': 0.00425, 'Arabic ratl': 0.45,
    'Babylonian shekel': 0.01, 'Babylonian mina': 0.5, 'Babylonian talent': 30.24,
    'Biblical gerah': 0.00057, 'Biblical bekah': 0.01, 'Biblical pim': 0.01, 'Biblical shekel': 0.01,
    'Biblical mina': 0.57, 'Biblical talent': 34.2,
    'Byzantine nomisma': 0.00455, 'Byzantine litra': 0.32,
    'Carat': 0.0002, 'Pennyweight': 0.001555, 'Troy ounce': 0.031103,
    'Chinese fen': 0.0005, 'Chinese qian': 0.005, 'Chinese liang': 0.05, 'Chinese jin': 0.5, 'Chinese dan': 50.0,
    'Egyptian qedet': 0.01, 'Egyptian deben': 0.09,
    'German pfund': 0.5, 'German zentner': 50.0,
    'Greek obol': 0.00072, 'Greek drachma': 0.0043, 'Greek stater': 0.01, 'Greek mina': 0.43, 'Greek talent': 25.86,
    'Indian ratti': 0.00012, 'Indian masha': 0.00097, 'Indian tola': 0.01, 'Indian pala': 0.04,
    'Indian chatak': 0.06, 'Indian seer': 0.93, 'Indian maund': 37.32,
    'Japanese fun': 0.000375, 'Japanese momme': 0.00375, 'Japanese ryō': 0.0375, 'Japanese kin': 0.6, 'Japanese kan': 3.75,
    'Korean don': 0.00375, 'Korean nyang': 0.04, 'Korean geun': 0.6, 'Korean gwan': 3.75,
    'Medieval mark': 0.23,
    'Myanmar kyattha': 0.02, 'Myanmar peittha': 0.16, 'Myanmar viss': 1.63,
    'Persian misqal': 0.00469, 'Persian sir': 0.07, 'Persian man': 2.94,
    'Portuguese arratel': 0.46, 'Portuguese arroba': 14.69,
    'Roman siliqua': 0.00019, 'Roman scripulum': 0.00114, 'Roman semiuncia': 0.01, 'Roman uncia': 0.03, 'Roman libra': 0.33,
    'Russian dolya': 0.00004, 'Russian zolotnik': 0.00427, 'Russian lot': 0.01, 'Russian funt': 0.41, 'Russian pood': 16.38, 'Russian berkovets': 163.8,
    'Southeast Asian tahil': 0.04, 'Southeast Asian catty': 0.6, 'Southeast Asian picul': 60.48,
    'Thai salung': 0.00381, 'Thai baht': 0.02, 'Thai chang': 1.22,
    'Turkish oka': 1.28,
  };


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
    double rateFrom = weightConversionRates[fromUnit] ?? 1.0;
    double rateTo = weightConversionRates[toUnit] ?? 1.0;

    if (isFromSelected) {
      double inputValue = double.tryParse(fromValue) ?? 0.0;
      double result = (inputValue * rateFrom) / rateTo;
      toValue = _formatResult(result);
      _toController.text = toValue;
    } else {
      double inputValue = double.tryParse(toValue) ?? 0.0;
      double result = (inputValue * rateTo) / rateFrom;
      fromValue = _formatResult(result);
      _fromController.text = fromValue;
    }
  }

  // --- CURSOR BASED KEYBOARD LOGIC ---
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
        // Updated Category to fetch Weight units
        return const UnitSelectorSheet(category: 'Weight & Mass');
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

  // --- Exact Realtime Equivalence Generator ---
  String _getEquivalenceText() {
    double rateFrom = weightConversionRates[fromUnit] ?? 1.0;
    double rateTo = weightConversionRates[toUnit] ?? 1.0;

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
                    'Weight & Mass',
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

        // --- 2.5 REAL-TIME EQUIVALENCE CARD ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey<String>(_getEquivalenceText()),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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

        // --- 3. REUSABLE KEYBOARD ---
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