import 'package:calculator_pro/unit_selector_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'action_button.dart';
import 'converter_keyboard.dart'; // NAYA: Reusable keyboard import kiya

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

  // Basic typing logic (Real formula hum aage add karenge)
  void _onKeyPress(String key) {
    setState(() {
      if (isFromSelected) {
        if (fromValue == '0' || fromValue == '1' && fromValue.length == 1) {
          fromValue = key;
        } else {
          fromValue += key;
        }
      } else {
        if (toValue == '0' || toValue == '3.28084') {
          toValue = key;
        } else {
          toValue += key;
        }
      }
      // TODO: Yahan dono ke beech real-time conversion math call hoga
    });
  }

  void _onBackspace() {
    setState(() {
      if (isFromSelected) {
        if (fromValue.isNotEmpty) fromValue = fromValue.substring(0, fromValue.length - 1);
        if (fromValue.isEmpty) fromValue = '0';
      } else {
        if (toValue.isNotEmpty) toValue = toValue.substring(0, toValue.length - 1);
        if (toValue.isEmpty) toValue = '0';
      }
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
      // 1. Sirf Units aur Symbols ko interchange karein
      String tempUnit = fromUnit;
      String tempSymbol = fromSymbol;

      fromUnit = toUnit;
      fromSymbol = toSymbol;

      toUnit = tempUnit;
      toSymbol = tempSymbol;

      // 2. VALUES SWAP NAHI KARNI HAIN!
      // Bas naye units ke hisaab se calculation dubara call kar deni hai.

      // _calculateConversion(); // Ye function hum aage math add karte waqt banayenge
    });
  }

  void _showUnitPicker(bool isFrom) async {
    if (_isHapticsEnabled) HapticFeedback.selectionClick();

    final selectedUnit = await showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return const UnitSelectorSheet(
          category: 'Length', // Bas Category bhej rahe hain
          // isFromUnit hata diya gaya hai
        );
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
        // _calculateConversion();
      });
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildConversionCard(
                      isActive: isFromSelected,
                      unitName: fromUnit,
                      unitSymbol: fromSymbol,
                      value: fromValue,
                      onTap: () {
                        setState(() { isFromSelected = true; });
                      },
                      onUnitTap: () => _showUnitPicker(true), // NAYA: From unit sheet open karega
                    ),
                    const SizedBox(height: 16),
                    _buildConversionCard(
                      isActive: !isFromSelected,
                      unitName: toUnit,
                      unitSymbol: toSymbol,
                      value: toValue,
                      onTap: () {
                        setState(() { isFromSelected = false; });
                      },
                      onUnitTap: () => _showUnitPicker(false), // NAYA: To unit sheet open karega
                    ),
                  ],
                ),

                // --- SWAP BUTTON (Dono cards ke beech mein over-lapping) ---
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

  Widget _buildConversionCard({
    required bool isActive,
    required String unitName,
    required String unitSymbol,
    required String value,
    required VoidCallback onTap,
    required VoidCallback onUnitTap, // NAYA PARAMETER
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: isActive ? surfaceColor.withOpacity(0.6) : surfaceColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? cyanColor : Colors.white.withOpacity(0.05),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // NAYA: Left Side Unit Info ko ek alag GestureDetector me wrap kiya
            GestureDetector(
              onTap: onUnitTap, // Unit ya arrow par click karne se bottom sheet open hoga
              behavior: HitTestBehavior.opaque, // Area ko perfectly clickable banane ke liye
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unitSymbol,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unitName,
                        style: TextStyle(color: textGrey.withOpacity(0.7), fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down_rounded, color: textGrey.withOpacity(0.5)),
                ],
              ),
            ),

            // Right Side: Typed Value
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? cyanColor : Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}