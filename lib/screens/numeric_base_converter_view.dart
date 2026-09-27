// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../custom_action_button.dart';
// import '../custom_top_bar.dart'; // Apna correct path check kar lena
//
// class NumericBaseConverterView extends StatefulWidget {
//   final VoidCallback onBack;
//   const NumericBaseConverterView({super.key, required this.onBack});
//
//   @override
//   State<NumericBaseConverterView> createState() => _NumericBaseConverterViewState();
// }
//
// class _NumericBaseConverterViewState extends State<NumericBaseConverterView> {
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
//         //             'Numeric Base',
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
//           toolId: 'numeric_base',
//           title: 'Numeric Base',
//           iconPath: 'assets/images/numeric_base.png',
//           onBack: widget.onBack,
//           isHapticsEnabled: _isHapticsEnabled,
//         ),
//
//         // --- SAMPLE TEXT (COMING SOON) ---
//         const Expanded(
//           child: Center(
//             child: Text(
//               'Numeric Base UI Coming Soon...',
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
import '../custom_top_bar.dart';

class NumericBaseConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const NumericBaseConverterView({super.key, required this.onBack});

  @override
  State<NumericBaseConverterView> createState() => _NumericBaseConverterViewState();
}

class _NumericBaseConverterViewState extends State<NumericBaseConverterView> {
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  bool _isHapticsEnabled = true;

  // Active field: 'dec', 'bin', 'oct', 'hex'
  String activeField = 'dec';

  // Controllers for 4 inputs
  final TextEditingController _decController = TextEditingController(text: '0');
  final TextEditingController _binController = TextEditingController(text: '0');
  final TextEditingController _octController = TextEditingController(text: '0');
  final TextEditingController _hexController = TextEditingController(text: '0');

  final FocusNode _decFocus = FocusNode();
  final FocusNode _binFocus = FocusNode();
  final FocusNode _octFocus = FocusNode();
  final FocusNode _hexFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadHaptics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _decController.dispose();
    _binController.dispose();
    _octController.dispose();
    _hexController.dispose();
    _decFocus.dispose();
    _binFocus.dispose();
    _octFocus.dispose();
    _hexFocus.dispose();
    super.dispose();
  }

  Future<void> _loadHaptics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    });
  }

  // --- CORE CONVERSION LOGIC (Using BigInt to prevent overflow with large binaries) ---
  void _updateValues(String input, int sourceBase) {
    if (input.isEmpty) {
      _decController.text = '0';
      _binController.text = '0';
      _octController.text = '0';
      _hexController.text = '0';
      return;
    }

    try {
      // Parse source string to BigInt
      BigInt value = BigInt.parse(input, radix: sourceBase);

      // Convert to other bases
      if (sourceBase != 10) _decController.text = value.toRadixString(10).toUpperCase();
      if (sourceBase != 2) _binController.text = value.toRadixString(2).toUpperCase();
      if (sourceBase != 8) _octController.text = value.toRadixString(8).toUpperCase();
      if (sourceBase != 16) _hexController.text = value.toRadixString(16).toUpperCase();
    } catch (e) {
      // Ignore invalid input (though keyboard restricts it anyway)
    }
  }

  // --- KEYBOARD ACTIONS ---
  // void _onKeyPress(String key) {
  //   setState(() {
  //     TextEditingController activeCtrl;
  //     int base;
  //
  //     switch (activeField) {
  //       case 'bin': activeCtrl = _binController; base = 2; break;
  //       case 'oct': activeCtrl = _octController; base = 8; break;
  //       case 'hex': activeCtrl = _hexController; base = 16; break;
  //       default: activeCtrl = _decController; base = 10; break;
  //     }
  //
  //     String currentText = activeCtrl.text;
  //
  //     // Remove leading zero unless it's just '0'
  //     if (currentText == '0') {
  //       currentText = key;
  //     } else {
  //       currentText += key;
  //     }
  //
  //     activeCtrl.text = currentText;
  //     _updateValues(currentText, base);
  //   });
  // }

  void _onKeyPress(String key) {
    setState(() {
      TextEditingController activeCtrl;
      int base;

      switch (activeField) {
        case 'bin': activeCtrl = _binController; base = 2; break;
        case 'oct': activeCtrl = _octController; base = 8; break;
        case 'hex': activeCtrl = _hexController; base = 16; break;
        default: activeCtrl = _decController; base = 10; break;
      }

      // Cursor position pata karo
      int cursorPos = activeCtrl.selection.baseOffset;
      if (cursorPos < 0) cursorPos = activeCtrl.text.length;

      String currentText = activeCtrl.text;
      String newText;

      // Agar '0' hai toh replace karo, nahi toh cursor position par add karo
      if (currentText == '0') {
        newText = key;
        cursorPos = 0;
      } else {
        newText = currentText.substring(0, cursorPos) + key + currentText.substring(cursorPos);
      }

      activeCtrl.text = newText;
      activeCtrl.selection = TextSelection.collapsed(offset: cursorPos + key.length);
      _updateValues(newText, base);
    });
  }

  void _onBackspace() {
    setState(() {
      TextEditingController activeCtrl;
      int base;

      switch (activeField) {
        case 'bin': activeCtrl = _binController; base = 2; break;
        case 'oct': activeCtrl = _octController; base = 8; break;
        case 'hex': activeCtrl = _hexController; base = 16; break;
        default: activeCtrl = _decController; base = 10; break;
      }

      int cursorPos = activeCtrl.selection.baseOffset;

      // Agar cursor ekdum shuru mein hai, toh kuch delete nahi hoga
      if (cursorPos <= 0) return;

      String currentText = activeCtrl.text;

      // Cursor ke pehle wala character delete karo
      String newText = currentText.substring(0, cursorPos - 1) + currentText.substring(cursorPos);

      if (newText.isEmpty) newText = '0';

      activeCtrl.text = newText;
      activeCtrl.selection = TextSelection.collapsed(offset: newText == '0' ? 1 : cursorPos - 1);

      _updateValues(newText, base);
    });
  }

  void _onClear() {
    setState(() {
      _decController.text = '0';
      _binController.text = '0';
      _octController.text = '0';
      _hexController.text = '0';
    });
  }

  // --- UI WIDGETS ---
  // Widget _buildInputCard(String title, String baseText, TextEditingController controller, String fieldKey) {
  //   bool isActive = activeField == fieldKey;
  //
  //   return GestureDetector(
  //     onTap: () {
  //       if (_isHapticsEnabled && !isActive) HapticFeedback.selectionClick();
  //       setState(() => activeField = fieldKey);
  //     },
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 250),
  //       margin: const EdgeInsets.only(bottom: 12),
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //       decoration: BoxDecoration(
  //         color: isActive ? surfaceColor.withOpacity(0.8) : surfaceColor.withOpacity(0.3),
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(
  //           color: isActive ? cyanColor : Colors.white.withOpacity(0.05),
  //           width: isActive ? 1.5 : 1.0,
  //         ),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 title,
  //                 style: TextStyle(
  //                   color: isActive ? cyanColor : textGrey.withOpacity(0.7),
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               Text(
  //                 baseText,
  //                 style: TextStyle(
  //                   color: textGrey.withOpacity(0.4),
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 8),
  //           SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             reverse: true, // Type from right to left like a calculator
  //             physics: const BouncingScrollPhysics(),
  //             child: Text(
  //               controller.text,
  //               style: TextStyle(
  //                 color: isActive ? Colors.white : Colors.white70,
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.w400,
  //                 letterSpacing: fieldKey == 'bin' ? 2.0 : 1.0, // Thoda extra space binary ke liye
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // --- UI WIDGETS ---
  Widget _buildInputCard(String title, String baseText, TextEditingController controller,FocusNode focusNode, String fieldKey) {
    bool isActive = activeField == fieldKey;

    return GestureDetector(
      onTap: () {
        if (_isHapticsEnabled && !isActive) HapticFeedback.selectionClick();
        setState(() => activeField = fieldKey);
        focusNode.requestFocus();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? surfaceColor.withOpacity(0.8) : surfaceColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? cyanColor : Colors.white.withOpacity(0.05),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? cyanColor : textGrey.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  baseText,
                  style: TextStyle(
                    color: textGrey.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // YAHAN CHANGE HUA HAI: Text ki jagah TextField add kiya hai
            Container(
              height: 35,
              alignment: Alignment.centerRight,
              child: TextField(
                controller: controller,
                readOnly: true, // Natively keyboard open nahi hoga
                showCursor: isActive,
                cursorColor: cyanColor,
                focusNode: focusNode,
                cursorWidth: 2.5,
                textAlign: TextAlign.right, // Text right side se shuru hoga
                scrollPhysics: const BouncingScrollPhysics(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  letterSpacing: fieldKey == 'bin' ? 2.0 : 1.0,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onTap: () {
                  if (_isHapticsEnabled && !isActive) HapticFeedback.selectionClick();
                  setState(() => activeField = fieldKey);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to check if a key should be enabled based on active field
  bool _isKeyEnabled(String key) {
    if (activeField == 'bin') return ['0', '1'].contains(key);
    if (activeField == 'oct') return ['0', '1', '2', '3', '4', '5', '6', '7'].contains(key);
    if (activeField == 'dec') return ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(key);
    return true; // hex allows everything
  }

  Widget _buildKey(String text, {VoidCallback? onTap, bool isAction = false, Color? textColor}) {
    bool enabled = isAction || _isKeyEnabled(text);

    return Expanded(
      child: GestureDetector(
        onTap: enabled ? () {
          if (_isHapticsEnabled) HapticFeedback.selectionClick();
          if (onTap != null) onTap();
          else _onKeyPress(text);
        } : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 55,
          decoration: BoxDecoration(
            color: isAction
                ? surfaceColor.withOpacity(0.5)
                : (enabled ? surfaceColor.withOpacity(0.3) : surfaceColor.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
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

  Widget _buildIconKey(IconData icon, {required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isHapticsEnabled) HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
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
          toolId: 'numeric_base',
          title: 'Numeric Base',
          iconPath: 'assets/images/numeric_base.png',
          onBack: widget.onBack,
          isHapticsEnabled: _isHapticsEnabled,
        ),

        // --- 4 DIRECT INPUT FIELDS ---
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Column(
              children: [
                // _buildInputCard('Decimal', 'Base 10', _decController, 'dec'),
                // _buildInputCard('Binary', 'Base 2', _binController, 'bin'),
                // _buildInputCard('Octal', 'Base 8', _octController, 'oct'),
                // _buildInputCard('Hexadecimal', 'Base 16', _hexController, 'hex'),
                _buildInputCard('Decimal', 'Base 10', _decController, _decFocus, 'dec'),
                _buildInputCard('Binary', 'Base 2', _binController, _binFocus, 'bin'),
                _buildInputCard('Octal', 'Base 8', _octController, _octFocus, 'oct'),
                _buildInputCard('Hexadecimal', 'Base 16', _hexController, _hexFocus, 'hex'),
              ],
            ),
          ),
        ),

        // --- SMART DYNAMIC KEYBOARD ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              // HEX Row: A B C D E F
              Row(
                children: [
                  _buildKey('A'), const SizedBox(width: 8),
                  _buildKey('B'), const SizedBox(width: 8),
                  _buildKey('C'), const SizedBox(width: 8),
                  _buildKey('D'), const SizedBox(width: 8),
                  _buildKey('E'), const SizedBox(width: 8),
                  _buildKey('F'),
                ],
              ),
              const SizedBox(height: 10),
              // Row 1: 7 8 9 AC
              Row(
                children: [
                  _buildKey('7'), const SizedBox(width: 8),
                  _buildKey('8'), const SizedBox(width: 8),
                  _buildKey('9'), const SizedBox(width: 8),
                  _buildKey('AC', isAction: true, textColor: cyanColor, onTap: _onClear),
                ],
              ),
              const SizedBox(height: 10),
              // Row 2: 4 5 6 BACKSPACE
              Row(
                children: [
                  _buildKey('4'), const SizedBox(width: 8),
                  _buildKey('5'), const SizedBox(width: 8),
                  _buildKey('6'), const SizedBox(width: 8),
                  _buildIconKey(Icons.backspace_outlined, onTap: _onBackspace),
                ],
              ),
              const SizedBox(height: 10),
              // Row 3: 1 2 3 0
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