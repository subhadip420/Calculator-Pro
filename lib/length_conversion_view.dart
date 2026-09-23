import 'package:calculator_pro/unit_selector_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_action_button.dart';
import 'custom_conversion_card.dart';
import 'custom_converter_keyboard.dart'; // NAYA: Reusable keyboard import kiya

class LengthConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const LengthConverterView({super.key, required this.onBack});

  @override
  State<LengthConverterView> createState() => _LengthConverterViewState();
}

class _LengthConverterViewState extends State<LengthConverterView> {
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  bool _isHapticsEnabled = true;

  // State Variables for Conversions
  bool isFromSelected = true; // Track karega ki kaunsa card active hai

  String fromUnit = 'Meter';
  String fromSymbol = 'm';
  String fromValue = '1';

  String toUnit = 'Foot';
  String toSymbol = 'ft';
  String toValue = '3.28084'; // Default 1 meter in feet

  // --- REAL MATH LOGIC: Har unit ki value in 1 Meter ---
  final Map<String, double> lengthConversionRates = {
    // Metric
    'Kilometer': 1000.0, 'Hectometer': 100.0, 'Decameter': 10.0, 'Meter': 1.0,
    'Decimeter': 0.1, 'Centimeter': 0.01, 'Millimeter': 0.001,
    'Micrometer': 1e-6, 'Nanometer': 1e-9, 'Picometer': 1e-12,

    // Imperial
    'Mil': 0.0000254, 'Inch': 0.0254, 'Link': 0.201168, 'Foot': 0.3048,
    'Yard': 0.9144, 'Rod': 5.0292, 'Chain': 20.1168, 'Furlong': 201.168,
    'Mile': 1609.344, 'League': 4828.032,

    // Scientific
    'Bohr radius': 5.29177e-11, 'Angstrom': 1e-10,

    // Astronomical
    'Parsec': 3.085677581e16, 'Light year': 9.46073047258e15, 'Astronomical unit': 149597870700.0,

    // Regional (Standard Approximations in meters)
    'Arabic assba': 0.0318, 'Arabic qabda': 0.127, 'Arabic shibr': 0.254, "Arabic ba'a": 2.032,
    'Arabic qasab': 3.99, 'Arabic farsakh': 5985.0, 'Arabic marhala': 47880.0,
    'Chinese cum': 0.0333333, 'Chinese chi': 0.333333, 'Chinese zhang': 3.33333, 'Chinese li': 500.0,
    'German linie': 0.002179, 'German zoll': 0.02615, 'German elle': 0.523, 'German klafter': 1.88,
    'German rute': 3.766, 'German meile': 7532.5,
    'Indian angula': 0.019, 'Indian hasta': 0.457, 'Indian dhira': 0.457, 'Indian gaz': 0.9144,
    'Indian kos': 3000.0, 'Indian yojana': 12000.0, 'Italian palmo': 0.25,
    'Japanese sun': 0.030303, 'Japanese shaku': 0.30303, 'Japanese ken': 1.81818, 'Japanese ri': 3927.27,
    'Korean pun': 0.00303, 'Korean chon': 0.0303, 'Korean ja': 0.303, 'Korean gan': 1.818,
    'Korean jeong': 109.09, 'Korean ri': 392.72,
    'Persian zar': 1.04, 'Persian farsang': 6240.0, 'Portuguese braça': 2.2,
    'Russian vershok': 0.04445, 'Russian arshin': 0.7112, 'Russian sazhen': 2.1336, 'Russian verst': 1066.8,
    'Scandinavian mile': 10000.0, 'Spanish vara': 0.8359, 'Spanish legua': 4179.5,
    'Thai wah': 2.0, 'Thai sen': 40.0, 'Thai yote': 16000.0,
    'Turkish parmak': 0.0315, 'Turkish endaze': 0.65, 'Turkish arşın': 0.68, 'Turkish kulaç': 1.89,

    // Historical
    'Biblical etzba (finger)': 0.0185, 'Biblical zereth (span)': 0.222, 'Biblical ammah (cubit)': 0.444,
    'Biblical qaneh (reed)': 2.664, 'Egyptian cubit': 0.523, 'English ell': 1.143,
    'Greek daktylos (finger)': 0.0193, 'Greek palaiste (palm)': 0.0771, 'Greek pous (foot)': 0.308,
    'Greek pechys (cubit)': 0.462, 'Greek orgyia (fathom)': 1.85, 'Greek plethron': 30.8, 'Greek stadion': 184.8,
    'Roman digitus (finger)': 0.0185, 'Roman palmus (palm)': 0.074, 'Roman pes (foot)': 0.296,
    'Roman cubitus (cubit)': 0.444, 'Roman pace': 1.48, 'Roman actus': 35.5, 'Roman mile': 1480.0,

    // Others
    'Cable Length': 185.2, 'Nautical Mile': 1852.0,
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

  // --- HELPER: Decimal Formatting (Clean Results ke liye) ---
  String _formatResult(double value) {
    if (value == 0) return '0';
    // Max 8 decimal places tak dikhayega aur trailing zero hata dega
    String res = value.toStringAsPrecision(8);
    if (res.contains('.')) {
      res = res.replaceAll(RegExp(r'0*$'), ''); // Piche ke extra 0 hatao
      res = res.replaceAll(RegExp(r'\.$'), ''); // Agar aakhir me sirf dot bacha h to hatao
    }
    return res;
  }

  // --- CORE: Calculation Logic (Bi-directional) ---
  void _calculateConversion() {
    double rateFrom = lengthConversionRates[fromUnit] ?? 1.0;
    double rateTo = lengthConversionRates[toUnit] ?? 1.0;

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

  // --- KEYBOARD LOGIC ---
  void _onKeyPress(String key) {
    setState(() {
      String currentValue = isFromSelected ? fromValue : toValue;

      // Decimal sirf ek baar allowed hai
      if (key == '.' && currentValue.contains('.')) return;

      if (currentValue == '0' && key != '.') {
        currentValue = key; // Replace default 0
      } else {
        currentValue += key; // Append digit
      }

      if (isFromSelected) {
        fromValue = currentValue;
      } else {
        toValue = currentValue;
      }

      _calculateConversion(); // Type hote hi convert karega
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

      _calculateConversion(); // Delete hone pe wapas update karega
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

      // Swap hone par calculation bhi update hogi (Value wahi rahegi par answer badlega)
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
        return const UnitSelectorSheet(category: 'Length');
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

        _calculateConversion(); // NAYA: Naya unit choose hote hi calculation update hoga
      });
    }
  }

  // --- NAYA: Exact Realtime Equivalence Generator ---
  String _getEquivalenceText() {
    double rateFrom = lengthConversionRates[fromUnit] ?? 1.0;
    double rateTo = lengthConversionRates[toUnit] ?? 1.0;

    if (isFromSelected) {
      double eqValue = rateFrom / rateTo; // 1 FromUnit = X ToUnit
      return '1 $fromSymbol = ${_formatResult(eqValue)} $toSymbol';
    } else {
      double eqValue = rateTo / rateFrom; // 1 ToUnit = X FromUnit
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
                    'Length Conversion',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ActionButton(
                icon: Icons.star_border_rounded, // Right side star icon
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {
                  if (_isHapticsEnabled) HapticFeedback.selectionClick();
                  // TODO: Add to favorites logic
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
                    mainAxisSize: MainAxisSize.min, // NAYA: Isse Swap button theek center me lock ho jayega
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
                      const SizedBox(height: 16), // Swap button exactly is gap ke upar aayega
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

        // --- NAYA: 2.5 REAL-TIME EQUIVALENCE CARD ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey<String>(_getEquivalenceText()), // Text change hone par smooth animation aayegi
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(
                _getEquivalenceText(),
                style: TextStyle(
                  color: cyanColor.withOpacity(0.9), // Cyan color se premium look aayega
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
        const SizedBox(height: 10), // Bottom Safe Area space
      ],
    );
  }
}