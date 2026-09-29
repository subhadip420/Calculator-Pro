// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../custom_action_button.dart';
// import '../custom_top_bar.dart'; // Apna correct path check kar lena
//
// class RomanNumeralsConverterView extends StatefulWidget {
//   final VoidCallback onBack;
//   const RomanNumeralsConverterView({super.key, required this.onBack});
//
//   @override
//   State<RomanNumeralsConverterView> createState() => _RomanNumeralsConverterViewState();
// }
//
// class _RomanNumeralsConverterViewState extends State<RomanNumeralsConverterView> {
//   final Color surfaceColor = const Color(0xFF1E2638);
//   final Color textGrey = const Color(0xFFDBC2AD);
//
//   bool _isHapticsEnabled = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadHaptics();
//   }
//
//   Future<void> _loadHaptics() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // --- APP BAR ---
//         // Padding(
//         //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         //   child: Row(
//         //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         //     children: [
//         //       ActionButton(
//         //         icon: Icons.arrow_back_ios_new_rounded,
//         //         contentColor: textGrey,
//         //         bgColor: surfaceColor.withOpacity(0.5),
//         //         onTap: () {
//         //           if (_isHapticsEnabled) HapticFeedback.lightImpact();
//         //           widget.onBack();
//         //         },
//         //       ),
//         //       const Expanded(
//         //         child: Padding(
//         //           padding: EdgeInsets.symmetric(horizontal: 16.0),
//         //           child: Text(
//         //             'Roman Numerals',
//         //             style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//         //           ),
//         //         ),
//         //       ),
//         //       ActionButton(
//         //         icon: Icons.star_border_rounded,
//         //         contentColor: textGrey,
//         //         bgColor: surfaceColor.withOpacity(0.5),
//         //         onTap: () {
//         //           if (_isHapticsEnabled) HapticFeedback.selectionClick();
//         //         },
//         //       ),
//         //     ],
//         //   ),
//         // ),
//
//         CustomTopBar(
//           toolId: 'roman_numerals',
//           title: 'Roman Numerals',
//           iconPath: 'assets/images/roman_numerals.png',
//           onBack: widget.onBack,
//           isHapticsEnabled: _isHapticsEnabled,
//         ),
//
//         // --- SAMPLE TEXT (COMING SOON) ---
//         const Expanded(
//           child: Center(
//             child: Text(
//               'Roman Numerals UI Coming Soon...',
//               style: TextStyle(color: Colors.white54, fontSize: 16),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_toast.dart';
import '../custom_top_bar.dart';

class RomanNumeralsConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const RomanNumeralsConverterView({super.key, required this.onBack});

  @override
  State<RomanNumeralsConverterView> createState() => _RomanNumeralsConverterViewState();
}

class _RomanNumeralsConverterViewState extends State<RomanNumeralsConverterView> {
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  bool _isHapticsEnabled = true;

  // Active field: 'dec', 'rom'
  String activeField = 'dec';

  final TextEditingController _decController = TextEditingController(text: '0');
  final TextEditingController _romController = TextEditingController(text: '');

  final FocusNode _decFocus = FocusNode();
  final FocusNode _romFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadHaptics();
    // Page open hote hi Decimal field par focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _decController.dispose();
    _romController.dispose();
    _decFocus.dispose();
    _romFocus.dispose();
    super.dispose();
  }

  Future<void> _loadHaptics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    });
  }

  // --- CORE CONVERSION LOGIC ---
  String _intToRoman(int num) {
    if (num < 1 || num > 3999) return "";
    List<String> m = ["", "M", "MM", "MMM"];
    List<String> c = ["", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"];
    List<String> x = ["", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"];
    List<String> i = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"];
    return m[num ~/ 1000] + c[(num % 1000) ~/ 100] + x[(num % 100) ~/ 10] + i[num % 10];
  }

  int _romanToInt(String s) {
    Map<String, int> values = {'I': 1, 'V': 5, 'X': 10, 'L': 50, 'C': 100, 'D': 500, 'M': 1000};
    int total = 0;
    for (int i = 0; i < s.length; i++) {
      int current = values[s[i]] ?? 0;
      int next = (i + 1 < s.length) ? (values[s[i + 1]] ?? 0) : 0;
      if (current < next) {
        total -= current;
      } else {
        total += current;
      }
    }
    return total;
  }

  void _updateValues(String input, String sourceField) {
    if (input.isEmpty || input == '0') {
      _decController.text = '0';
      _romController.text = '';
      return;
    }

    if (sourceField == 'dec') {
      int val = int.tryParse(input) ?? 0;
      _romController.text = _intToRoman(val);
    } else {
      int val = _romanToInt(input.toUpperCase());
      _decController.text = val.toString();
    }
  }

  // --- KEYBOARD ACTIONS ---
  void _onKeyPress(String key) {
    setState(() {
      TextEditingController activeCtrl = activeField == 'dec' ? _decController : _romController;

      int cursorPos = activeCtrl.selection.baseOffset;
      if (cursorPos < 0) cursorPos = activeCtrl.text.length;

      String currentText = activeCtrl.text;
      String newText;

      // Handle replacing '0' for decimal
      if (activeField == 'dec' && currentText == '0') {
        newText = key;
        cursorPos = 0;
      } else {
        newText = currentText.substring(0, cursorPos) + key + currentText.substring(cursorPos);
      }

      // --- DECIMAL LIMIT CHECK ---
      if (activeField == 'dec') {
        int? testVal = int.tryParse(newText);
        if (testVal != null && testVal > 3999) {
          showCustomToast(context, 'Maximum limit is 3999');
          return;
        }
      }

      // --- NAYA FIX: STRICT ROMAN NUMERAL VALIDATION ---
      if (activeField == 'rom') {
        // Ye Regex sirf valid roman grammar ko hi allow karta hai (Max 3999 tak)
        bool isValid = RegExp(r'^M{0,3}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$').hasMatch(newText);

        if (!isValid) {
          showCustomToast(context, 'Invalid Roman Numeral format');
          return; // Galat type hone par wahi rok dega
        }
      }

      activeCtrl.text = newText;
      activeCtrl.selection = TextSelection.collapsed(offset: cursorPos + key.length);
      _updateValues(newText, activeField);
    });
  }

  void _onBackspace() {
    setState(() {
      TextEditingController activeCtrl = activeField == 'dec' ? _decController : _romController;
      int cursorPos = activeCtrl.selection.baseOffset;

      if (cursorPos <= 0) return;

      String currentText = activeCtrl.text;
      String newText = currentText.substring(0, cursorPos - 1) + currentText.substring(cursorPos);

      if (activeField == 'dec' && newText.isEmpty) newText = '0';

      activeCtrl.text = newText;
      activeCtrl.selection = TextSelection.collapsed(offset: newText == '0' ? (activeField == 'dec' ? 1 : 0) : cursorPos - 1);

      _updateValues(newText, activeField);
    });
  }

  void _onClear() {
    setState(() {
      _decController.text = '0';
      _romController.text = '';

      _decController.selection = const TextSelection.collapsed(offset: 1);
      _romController.selection = const TextSelection.collapsed(offset: 0);
    });
  }

  // --- UI WIDGETS ---
  Widget _buildInputCard(String title, TextEditingController controller, FocusNode focusNode, String fieldKey) {
    bool isActive = activeField == fieldKey;

    return GestureDetector(
      onTap: () {
        if (_isHapticsEnabled && !isActive) HapticFeedback.selectionClick();
        setState(() => activeField = fieldKey);
        focusNode.requestFocus();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? surfaceColor.withOpacity(0.8) : surfaceColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? cyanColor : Colors.white.withOpacity(0.05),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? cyanColor : textGrey.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 38,
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                readOnly: true,
                showCursor: isActive,
                cursorColor: cyanColor,
                cursorWidth: 2.5,
                scrollPhysics: const BouncingScrollPhysics(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  letterSpacing: fieldKey == 'rom' ? 2.0 : 1.0,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintText: fieldKey == 'rom' ? 'Roman Numeral' : '0',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                ),
                onTap: () {
                  if (_isHapticsEnabled && !isActive) HapticFeedback.selectionClick();
                  setState(() => activeField = fieldKey);
                  focusNode.requestFocus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Keyboard Helpers
  // bool _isKeyEnabled(String key) {
  //   if (activeField == 'dec') return ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '00'].contains(key);
  //   if (activeField == 'rom') return ['I', 'V', 'X', 'L', 'C', 'D', 'M'].contains(key);
  //   return false;
  // }

  bool _isKeyEnabled(String key) {
    if (activeField == 'dec') return ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '00'].contains(key);
    if (activeField == 'rom') return ['I', 'V', 'X', 'L', 'C', 'D', 'M'].contains(key);
    return false;
  }

  // Widget _buildKey(String text, {VoidCallback? onTap, bool isAction = false, Color? textColor}) {
  //   bool enabled = isAction || _isKeyEnabled(text);
  //
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: enabled ? () {
  //         if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //         if (onTap != null) onTap();
  //         else _onKeyPress(text);
  //       } : null,
  //       child: AnimatedContainer(
  //         duration: const Duration(milliseconds: 200),
  //         height: 55,
  //         decoration: BoxDecoration(
  //           color: isAction
  //               ? surfaceColor.withOpacity(0.5)
  //               : (enabled ? surfaceColor.withOpacity(0.3) : surfaceColor.withOpacity(0.1)),
  //           borderRadius: BorderRadius.circular(14),
  //         ),
  //         child: Center(
  //           child: Text(
  //             text,
  //             style: TextStyle(
  //               color: textColor ?? (enabled ? Colors.white : textGrey.withOpacity(0.2)),
  //               fontSize: 22,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildKey(String text, {VoidCallback? onTap, bool isAction = false, Color? textColor}) {
    bool enabled = isAction || _isKeyEnabled(text);

    // Background color set karna
    Color bgCol = isAction
        ? surfaceColor.withOpacity(0.5)
        : (enabled ? surfaceColor.withOpacity(0.3) : surfaceColor.withOpacity(0.1));

    return Expanded(
      child: Material(
        color: bgCol,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias, // Ripple rounded corners ke bahar na jaye
        child: InkWell(
          onTap: enabled ? () {
            if (_isHapticsEnabled) HapticFeedback.selectionClick();
            if (onTap != null) onTap();
            else _onKeyPress(text);
          } : null,
          borderRadius: BorderRadius.circular(14),
          // NAYA: Ripple/Splash Animation Colors
          splashColor: (textColor ?? cyanColor).withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            height: 55,
            alignment: Alignment.center, // Text ko center karne ke liye
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? (enabled ? Colors.white : textGrey.withOpacity(0.2)),
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildIconKey(IconData icon, {required VoidCallback onTap}) {
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: () {
  //         if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //         onTap();
  //       },
  //       child: Container(
  //         height: 55,
  //         decoration: BoxDecoration(
  //           color: surfaceColor.withOpacity(0.5),
  //           borderRadius: BorderRadius.circular(14),
  //         ),
  //         child: Center(
  //           child: Icon(icon, color: cyanColor, size: 26),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildIconKey(IconData icon, {required VoidCallback onTap}) {
    return Expanded(
      child: Material(
        color: surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (_isHapticsEnabled) HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(14),
          // NAYA: Icon key ke liye splash color
          splashColor: cyanColor.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            height: 55,
            alignment: Alignment.center, // Icon ko center karne ke liye
            child: Icon(icon, color: cyanColor, size: 26),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTopBar(
          toolId: 'roman_numerals',
          title: 'Roman Numerals',
          iconPath: 'assets/images/roman_numerals.png',
          onBack: widget.onBack,
          isHapticsEnabled: _isHapticsEnabled,
        ),

        // --- CONVERSION CARDS ---
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildInputCard('Decimal Value', _decController, _decFocus, 'dec'),
                _buildInputCard('Roman Numeral', _romController, _romFocus, 'rom'),

                // --- REFERENCE TEXT ---
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  child: Text(
                    'I=1    V=5    X=10    L=50    C=100    D=500    M=1000',
                    style: TextStyle(
                      color: textGrey.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- SMART DYNAMIC KEYBOARD (4 Column Layout) ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              // Row 1: I, V, X, L
              Row(
                children: [
                  _buildKey('I'), const SizedBox(width: 8),
                  _buildKey('V'), const SizedBox(width: 8),
                  _buildKey('X'), const SizedBox(width: 8),
                  _buildKey('L'),
                ],
              ),
              const SizedBox(height: 10),

              // Row 2: C, D, M, AC
              Row(
                children: [
                  _buildKey('C'), const SizedBox(width: 8),
                  _buildKey('D'), const SizedBox(width: 8),
                  _buildKey('M'), const SizedBox(width: 8),
                  _buildKey('AC', isAction: true, textColor: cyanColor, onTap: _onClear),
                ],
              ),
              const SizedBox(height: 10),

              // Row 3: 7, 8, 9, Backspace
              Row(
                children: [
                  _buildKey('7'), const SizedBox(width: 8),
                  _buildKey('8'), const SizedBox(width: 8),
                  _buildKey('9'), const SizedBox(width: 8),
                  _buildIconKey(Icons.backspace_outlined, onTap: _onBackspace),
                ],
              ),
              const SizedBox(height: 10),

              // Row 4: 4, 5, 6, Empty Placeholder
              Row(
                children: [
                  _buildKey('4'), const SizedBox(width: 8),
                  _buildKey('5'), const SizedBox(width: 8),
                  _buildKey('6'), const SizedBox(width: 8),
                  _buildKey('00'),
                ],
              ),
              const SizedBox(height: 10),

              // Row 5: 1, 2, 3, 0
              Row(
                children: [
                  _buildKey('1'), const SizedBox(width: 8),
                  _buildKey('2'), const SizedBox(width: 8),
                  _buildKey('3'), const SizedBox(width: 8),
                  _buildKey('0'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}