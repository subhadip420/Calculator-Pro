import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_action_button.dart';
import '../custom_conversion_card.dart';
import '../custom_converter_keyboard.dart';
import 'package:calculator_pro/custom_unit_selector_sheet.dart'; // Apna correct path check kar lena

class AngleConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const AngleConverterView({super.key, required this.onBack});

  @override
  State<AngleConverterView> createState() => _AngleConverterViewState();
}

class _AngleConverterViewState extends State<AngleConverterView> {
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  bool _isHapticsEnabled = true;

  // --- State Variables ---
  bool isFromSelected = true;

  String fromUnit = 'Degree'; // Base Unit
  String fromSymbol = '°';
  String fromValue = '1';

  String toUnit = 'Radian';
  String toSymbol = 'rad';
  String toValue = '0.0174533';

  late TextEditingController _fromController;
  late TextEditingController _toController;

  // --- MATH LOGIC: Base is 1 Degree (°) ---
  final Map<String, double> angleConversionRates = {
    'Degree': 1.0,
    'Radian': 57.295779513,
    'Gradian': 0.9,
    'Minute': 0.0166666667,
    'Second': 0.0002777778,
    'Microarcsecond': 2.77777778e-10,
    'Milliarcsecond': 2.77777778e-7,
    'Centesimal minute': 0.009,
    'Centesimal second': 0.00009,
    'Nanoradian': 5.72957795e-8,
    'Microradian': 0.0000572958,
    'Milliradian': 0.0572957795,
    'Sign': 30.0,
    'Octant': 45.0,
    'Sextant': 60.0,
    'Quadrant': 90.0,
    'Semicircle': 180.0,
    'Circle': 360.0,
    'Percent grade': 0.572957795,
    'Per mille grade': 0.05729578,
    'Streck': 0.057142857,
    'Mil (NATO)': 0.05625,
    'Mil (Warsaw pact)': 0.06,
    'Binary degree': 1.40625,
    'Compass point': 11.25,
    'Hour angle': 15.0,
  };

  @override
  void initState() {
    super.initState();
    _loadHaptics();
    _fromController = TextEditingController(text: fromValue);
    _toController = TextEditingController(text: toValue);
  }

  Future<void> _loadHaptics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    });
  }

  // --- Decimal Formatting ---
  String _formatResult(double value) {
    if (value == 0) return '0';
    String res = value.toStringAsPrecision(8);
    if (res.contains('.')) {
      res = res.replaceAll(RegExp(r'0*$'), '');
      res = res.replaceAll(RegExp(r'\.$'), '');
    }
    return res;
  }

  // --- Calculation Logic ---
  void _calculateConversion() {
    double rateFrom = angleConversionRates[fromUnit] ?? 1.0;
    double rateTo = angleConversionRates[toUnit] ?? 1.0;

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

  // --- Keyboard & Cursor Logic ---
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

      if (newText.isEmpty || newText == '-') newText = '0';

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
        return const UnitSelectorSheet(category: 'Angle'); // Update category name
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
    double rateFrom = angleConversionRates[fromUnit] ?? 1.0;
    double rateTo = angleConversionRates[toUnit] ?? 1.0;

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
    // --- Screen Size Adjustments ---
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isShortScreen = screenHeight < 720;

    final double topBarPadding = isShortScreen ? 4.0 : 8.0;
    final double cardVerticalPadding = isShortScreen ? 4.0 : 10.0;
    final double cardGap = isShortScreen ? 12.0 : 16.0;
    final double swapBtnSize = isShortScreen ? 40.0 : 46.0;
    final double swapIconSize = isShortScreen ? 22.0 : 26.0;

    return Column(
      children: [
        // --- 1. TOP BAR ---
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: topBarPadding),
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
                    'Angle',
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
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: cardVerticalPadding),
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
                        onTap: () => setState(() => isFromSelected = true),
                        onUnitTap: () => _showUnitPicker(true),
                      ),

                      SizedBox(height: cardGap),

                      ConversionCard(
                        isActive: !isFromSelected,
                        unitName: toUnit,
                        unitSymbol: toSymbol,
                        controller: _toController,
                        onTap: () => setState(() => isFromSelected = false),
                        onUnitTap: () => _showUnitPicker(false),
                      ),
                    ],
                  ),

                  // --- SWAP BUTTON ---
                  GestureDetector(
                    onTap: _swapUnits,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: swapBtnSize,
                      width: swapBtnSize,
                      decoration: BoxDecoration(
                        color: cyanColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: bgColor, width: isShortScreen ? 3 : 4),
                        boxShadow: [
                          BoxShadow(color: cyanColor.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                      child: Icon(Icons.swap_vert_rounded, color: const Color(0xFF003640), size: swapIconSize),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- 3. REAL-TIME EQUIVALENCE CARD ---
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: isShortScreen ? 2.0 : 5.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey<String>(_getEquivalenceText()),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: isShortScreen ? 4.0 : 6.0),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(
                _getEquivalenceText(),
                style: TextStyle(
                  color: cyanColor.withOpacity(0.9),
                  fontSize: isShortScreen ? 13 : 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: isShortScreen ? 4 : 8),

        // --- 4. KEYBOARD ---
        ConverterKeyboard(
          isHapticsEnabled: _isHapticsEnabled,
          onKeyPress: _onKeyPress,
          onBackspace: _onBackspace,
          onClear: _onClear,
        ),

        SizedBox(height: isShortScreen ? 4 : 10),
      ],
    );
  }
}