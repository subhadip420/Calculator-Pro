import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_conversion_card.dart';
import '../custom_converter_keyboard.dart';
import '../custom_top_bar.dart';
import '../custom_unit_selector_sheet.dart';

class TimeConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const TimeConverterView({super.key, required this.onBack});

  @override
  State<TimeConverterView> createState() => _TimeConverterViewState();
}

class _TimeConverterViewState extends State<TimeConverterView> {
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  bool _isHapticsEnabled = true;

  // --- FOCUS STATE ---
  // activeField can be: 'd', 'hr', 'm', 's', 'from', 'to'
  String activeField = 'hr';

  // --- MULTI-INPUT VARIABLES ---
  String inputDays = '0';
  String inputHours = '0';
  String inputMins = '0';
  String inputSecs = '0';

  // --- STANDARD CARD VARIABLES ---
  String fromUnit = 'Hour';
  String fromSymbol = 'h';
  String fromValue = '0';

  String toUnit = 'Minute';
  String toSymbol = 'min';
  String toValue = '0';

  late TextEditingController _fromController;
  late TextEditingController _toController;

  // --- ALL NEW TIME UNITS IN SECONDS ---
  final Map<String, double> timeConversionRates = {
    // Standard
    'Minute': 60.0, 'Hour': 3600.0, 'Day': 86400.0, 'Week': 604800.0, 'Month': 2629800.0,
    'Year': 31557600.0, 'Decade': 315576000.0, 'Century': 3155760000.0, 'Millennium': 31557600000.0,
    // Metric
    'Picosecond': 1e-12, 'Nanosecond': 1e-9, 'Microsecond': 1e-6, 'Millisecond': 1e-3, 'Second': 1.0,
    // Scientific
    'Planck time': 5.39e-44, 'Atomic unit of time': 2.4189e-17, 'Svedberg': 1e-13, 'Jiffy': 0.01, 'Shake': 1e-8,
    // Astronomical
    'Sidereal day': 86164.09, 'Synodic month': 2551442.8, 'Julian year': 31557600.0,
    'Tropical year': 31556925.0, 'Sidereal year': 31558149.0, 'Galactic year': 7.1e15,
    // Regional
    'Chinese ke': 864.0, 'Chinese shichen': 7200.0, 'Hebrew helek': 3.333,
    'Indian ghati': 1440.0, 'Indian muhurta': 2880.0, 'Indian prahara': 10800.0,
    // Historical
    'Biblical jubilee': 1577880000.0, 'Byzantine indiction': 473364000.0, 'English score': 631152000.0,
    'Greek olympiad': 126230400.0, 'Medieval moment': 108.0, 'Roman lustrum': 157788000.0,
  };

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController(text: fromValue);
    _toController = TextEditingController(text: toValue);
    _loadHaptics();
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

  // --- SMART SYNC: Update Cards when Multi-Input changes ---
  void _syncFromMulti() {
    double d = double.tryParse(inputDays) ?? 0;
    double h = double.tryParse(inputHours) ?? 0;
    double m = double.tryParse(inputMins) ?? 0;
    double s = double.tryParse(inputSecs) ?? 0;

    double totalSec = (d * 86400) + (h * 3600) + (m * 60) + s;

    double rateFrom = timeConversionRates[fromUnit] ?? 1.0;
    double rateTo = timeConversionRates[toUnit] ?? 1.0;

    fromValue = _formatResult(totalSec / rateFrom);
    toValue = _formatResult(totalSec / rateTo);

    _fromController.text = fromValue;
    _toController.text = toValue;
  }

  // --- SMART SYNC: Update Multi-Input when Cards change ---
  void _syncFromStandard(bool isFromUpdated) {
    double rateFrom = timeConversionRates[fromUnit] ?? 1.0;
    double rateTo = timeConversionRates[toUnit] ?? 1.0;

    double totalSec = 0;
    if (isFromUpdated) {
      double val = double.tryParse(fromValue) ?? 0;
      totalSec = val * rateFrom;
      toValue = _formatResult(totalSec / rateTo);
      _toController.text = toValue;
    } else {
      double val = double.tryParse(toValue) ?? 0;
      totalSec = val * rateTo;
      fromValue = _formatResult(totalSec / rateFrom);
      _fromController.text = fromValue;
    }

    // Break down total seconds into Days, Hrs, Mins, Secs
    if (totalSec == 0) {
      inputDays = '0'; inputHours = '0'; inputMins = '0'; inputSecs = '0';
    } else {
      int days = totalSec ~/ 86400;
      double rem = totalSec % 86400;
      int hours = rem ~/ 3600;
      rem %= 3600;
      int mins = rem ~/ 60;
      double secs = rem % 60;

      inputDays = days > 0 ? days.toString() : '0';
      inputHours = hours > 0 ? hours.toString() : '0';
      inputMins = mins > 0 ? mins.toString() : '0';
      inputSecs = secs > 0 ? _formatResult(secs) : '0';
    }
  }

  // --- KEYBOARD GETTER/SETTER FOR MULTI-INPUT ---
  String _getMultiValue() {
    switch (activeField) {
      case 'd': return inputDays;
      case 'hr': return inputHours;
      case 'm': return inputMins;
      case 's': return inputSecs;
      default: return '0';
    }
  }
  void _setMultiValue(String val) {
    switch (activeField) {
      case 'd': inputDays = val; break;
      case 'hr': inputHours = val; break;
      case 'm': inputMins = val; break;
      case 's': inputSecs = val; break;
    }
  }

  // --- UNIFIED KEYBOARD LOGIC ---
  void _onKeyPress(String key) {
    setState(() {
      if (['d', 'hr', 'm', 's'].contains(activeField)) {
        // Multi-input typing logic
        String currentVal = _getMultiValue();
        if (key == '.' && currentVal.contains('.')) return;
        if (currentVal == '0' && key != '.') currentVal = key;
        else currentVal += key;
        _setMultiValue(currentVal);
        _syncFromMulti();
      } else {
        // Standard Conversion Card cursor typing logic
        TextEditingController activeController = activeField == 'from' ? _fromController : _toController;
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

        if (activeField == 'from') fromValue = newText;
        else toValue = newText;

        _syncFromStandard(activeField == 'from');
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (['d', 'hr', 'm', 's'].contains(activeField)) {
        String currentVal = _getMultiValue();
        if (currentVal.isNotEmpty) currentVal = currentVal.substring(0, currentVal.length - 1);
        if (currentVal.isEmpty || currentVal == '-') currentVal = '0';
        _setMultiValue(currentVal);
        _syncFromMulti();
      } else {
        TextEditingController activeController = activeField == 'from' ? _fromController : _toController;
        int cursorPos = activeController.selection.baseOffset;
        if (cursorPos <= 0) return;

        String currentText = activeController.text;
        String newText = currentText.substring(0, cursorPos - 1) + currentText.substring(cursorPos);
        if (newText.isEmpty || newText == '-') newText = '0';

        activeController.text = newText;
        activeController.selection = TextSelection.collapsed(offset: newText == '0' ? 1 : cursorPos - 1);

        if (activeField == 'from') fromValue = newText;
        else toValue = newText;

        _syncFromStandard(activeField == 'from');
      }
    });
  }

  void _onClear() {
    setState(() {
      inputDays = '0'; inputHours = '0'; inputMins = '0'; inputSecs = '0';
      fromValue = '0'; toValue = '0';
      _fromController.text = '0'; _toController.text = '0';
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

      _syncFromStandard(true);
    });
  }

  void _showUnitPicker(bool isFrom) async {
    if (_isHapticsEnabled) HapticFeedback.selectionClick();

    final selectedUnit = await showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return const UnitSelectorSheet(category: 'Time');
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

        // Agar multi-input focus me hai toh waha se calculate karo, warna standard card se
        if (['d', 'hr', 'm', 's'].contains(activeField)) {
          _syncFromMulti();
        } else {
          _syncFromStandard(activeField == 'from');
        }
      });
    }
  }

  String _getEquivalenceText() {
    double rateFrom = timeConversionRates[fromUnit] ?? 1.0;
    double rateTo = timeConversionRates[toUnit] ?? 1.0;
    double eqValue = rateFrom / rateTo;
    return '1 $fromSymbol = ${_formatResult(eqValue)} $toSymbol';
  }

  Widget _buildTimeBlock(String label, String value, String fieldKey) {
    bool isActive = (activeField == fieldKey);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isHapticsEnabled) HapticFeedback.selectionClick();
          setState(() => activeField = fieldKey);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? cyanColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isActive ? cyanColor : Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isActive ? cyanColor : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: textGrey.withOpacity(isActive ? 0.9 : 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isShortScreen = screenHeight < 720;
    final double swapBtnSize = isShortScreen ? 40.0 : 46.0;

    return Column(
      children: [
        CustomTopBar(
          toolId: 'time',
          title: 'Time',
          iconPath: 'assets/images/time.png',
          onBack: widget.onBack,
          isHapticsEnabled: _isHapticsEnabled,
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Column(
                children: [

                  // --- 1. TOP CARD: Custom Multi-Input ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: ['d', 'hr', 'm', 's'].contains(activeField) ? cyanColor : Colors.white.withOpacity(0.05),
                          width: 1.5
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                          child: Text(
                            'Compound Input',
                            style: TextStyle(color: textGrey, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTimeBlock('Days', inputDays, 'd'),
                            Text(':', style: TextStyle(color: textGrey.withOpacity(0.3), fontSize: 24)),
                            _buildTimeBlock('Hours', inputHours, 'hr'),
                            Text(':', style: TextStyle(color: textGrey.withOpacity(0.3), fontSize: 24)),
                            _buildTimeBlock('Mins', inputMins, 'm'),
                            Text(':', style: TextStyle(color: textGrey.withOpacity(0.3), fontSize: 24)),
                            _buildTimeBlock('Secs', inputSecs, 's'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- 2. STANDARD CONVERSION CARDS ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConversionCard(
                            isActive: activeField == 'from',
                            unitName: fromUnit,
                            unitSymbol: fromSymbol,
                            controller: _fromController,
                            onTap: () => setState(() => activeField = 'from'),
                            onUnitTap: () => _showUnitPicker(true),
                          ),
                          const SizedBox(height: 16),
                          ConversionCard(
                            isActive: activeField == 'to',
                            unitName: toUnit,
                            unitSymbol: toSymbol,
                            controller: _toController,
                            onTap: () => setState(() => activeField = 'to'),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(
                _getEquivalenceText(),
                style: TextStyle(
                  color: cyanColor.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // --- 4. REUSABLE KEYBOARD ---
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