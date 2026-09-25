import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_action_button.dart';
import '../custom_converter_keyboard.dart';
import '../custom_conversion_card.dart';
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

  bool isFromSelected = true;

  String fromUnit = 'Liter';
  String fromSymbol = 'l';
  String fromValue = '1';

  String toUnit = 'Milliliter';
  String toSymbol = 'ml';
  String toValue = '1000';

  late TextEditingController _fromController;
  late TextEditingController _toController;

  // --- REAL MATH LOGIC: Har unit ki value in 1 Liter (Base Unit: l) ---
  final Map<String, double> volumeConversionRates = {
    // Standard Units (Liters)
    'Picoliter': 1e-12, 'Nanoliter': 1e-9, 'Microliter': 1e-6,
    'Milliliter': 0.001, 'Centiliter': 0.01, 'Deciliter': 0.1,
    'Liter': 1.0, 'Decaliter': 10.0, 'Hectoliter': 100.0, 'Kiloliter': 1000.0,

    // Metric Units (Cubic)
    'Picometer³': 1e-33, 'Nanometer³': 1e-24, 'Micrometer³': 1e-15,
    'Millimeter³': 1e-6, 'Centimeter³': 0.001, 'Decimeter³': 1.0,
    'Meter³': 1000.0, 'Decameter³': 1000000.0, 'Hectometer³': 1000000000.0,
    'Kilometer³': 1e12,

    // US Units
    'Minim (US)': 0.0000616115, 'Fluid dram (US)': 0.00369669,
    'Teaspoon (US)': 0.00492892, 'Tablespoon (US)': 0.0147868,
    'Ounce (US)': 0.0295735, 'Gill (US)': 0.118294, 'Cup (US)': 0.236588,
    'Pint (US)': 0.473176, 'Quart (US)': 0.946353, 'Gallon (US)': 3.78541,
    'Dry pint (US)': 0.55061, 'Dry quart (US)': 1.10122,
    'Dry gallon (US)': 4.40488, 'Peck (US)': 8.80977,
    'Bushel (US)': 35.2391, 'Beer barrel (US)': 117.348,

    // UK Units
    'Minim (UK)': 0.0000591939, 'Fluid dram (UK)': 0.00355163,
    'Teaspoon (UK)': 0.00591939, 'Tablespoon (UK)': 0.0177582,
    'Ounce (UK)': 0.0284131, 'Gill (UK)': 0.142065, 'Cup (UK)': 0.284131,
    'Pint (UK)': 0.568261, 'Quart (UK)': 1.13652, 'Gallon (UK)': 4.54609,
    'Peck (UK)': 9.09218, 'Bushel (UK)': 36.3687,

    // Imperial Units (Cubic)
    'Mil³': 1.6387e-11, 'Inch³': 0.0163871, 'Link³': 8.136,
    'Foot³': 28.3168, 'Yard³': 764.555, 'Rod³': 127202.8,
    'Chain³': 8140980.13, 'Furlong³': 8140980127.81,
    'Mile³': 4.16818182544e12,

    // Scientific & Engineering
    'Planck volume': 4.2217e-105, 'Lambda': 1e-6,
    'Oil barrel': 158.987, 'Register ton': 2831.68, 'Acre foot': 1233481.84,

    // Other Units
    'Metric cup': 0.25,

    // Regional Units
    'Arabic mudd': 0.543, 'Arabic qist': 1.01, 'Arabic sa\'': 2.17,
    'Arabic wasq': 130.32, 'Australian tablespoon': 0.02,
    'Chinese shao': 0.01, 'Chinese ge': 0.1, 'Chinese sheng': 1.0,
    'Chinese dou': 10.0, 'Chinese dan': 100.0, 'German maß': 1.069,
    'Indian pav': 0.23, 'Indian seer': 0.933, 'Indian maund': 37.324,
    'Japanese gō': 0.18039, 'Japanese cup': 0.2, 'Japanese shō': 1.8039,
    'Japanese to': 18.039, 'Japanese koku': 180.39,
    'Korean hop': 0.18039, 'Korean doe': 1.8039, 'Korean mal': 18.039,
    'Russian charka': 0.12299, 'Russian shtof': 1.2299,
    'Russian chetvert': 3.0748, 'Russian vedro': 12.299,
    'Russian bochka': 491.98, 'Spanish arroba': 16.133,
    'Thai tanan': 1.0, 'Thai thang': 20.0,

    // Historical Units
    'Biblical log': 0.31, 'Biblical cab': 1.22, 'Biblical omer': 2.2,
    'Biblical hin': 3.67, 'Biblical seah': 7.33, 'Biblical bath': 22.0,
    'Biblical ephah': 22.0, 'Biblical kor': 220.0,
    'Egyptian hin': 0.48, 'Egyptian hekat': 4.8,
    'Greek kyathos': 0.0456, 'Greek kotyle': 0.2736,
    'Greek chous': 3.283, 'Greek metretes': 39.39,
    'Roman cyathus': 0.0456, 'Roman acetabulum': 0.0684,
    'Roman hemina': 0.2736, 'Roman sextarius': 0.547,
    'Roman congius': 3.283, 'Roman modius': 8.754,
    'Roman urna': 13.13, 'Roman amphora': 26.26, 'Roman culeus': 525.2,
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
    double rateFrom = volumeConversionRates[fromUnit] ?? 1.0;
    double rateTo = volumeConversionRates[toUnit] ?? 1.0;

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