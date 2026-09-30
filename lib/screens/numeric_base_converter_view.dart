import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';
import '../custom_top_bar.dart';

class NumericBaseConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const NumericBaseConverterView({super.key, required this.onBack});

  @override
  State<NumericBaseConverterView> createState() => _NumericBaseConverterViewState();
}

class _NumericBaseConverterViewState extends State<NumericBaseConverterView> {
  // final Color bgColor = const Color(0xFF0E131D);
  // final Color surfaceColor = const Color(0xFF1E2638);
  // final Color cyanColor = const Color(0xFF4CD7F6);
  // final Color textGrey = const Color(0xFFDBC2AD);

  bool _isHapticsEnabled = true;
  String _buttonShape = 'rounded';
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
    //_loadHaptics();
    _loadSettings();
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

  // Future<void> _loadHaptics() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
  //   });
  // }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
      _buttonShape = prefs.getString('button_shape') ?? 'rounded';
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
          color: isActive ? AppColors.surfaceColor(context).withOpacity(0.8) : AppColors.surfaceColor(context).withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.cyanColor(context) : Colors.white.withOpacity(0.05),
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
                    color: isActive ? AppColors.cyanColor(context) : AppColors.textGrey(context).withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  baseText,
                  style: TextStyle(
                    color: AppColors.textGrey(context).withOpacity(0.8),
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
                cursorColor: AppColors.cyanColor(context),
                focusNode: focusNode,
                cursorWidth: 2.5,
                textAlign: TextAlign.right, // Text right side se shuru hoga
                scrollPhysics: const BouncingScrollPhysics(),
                style: TextStyle(
                  // color: isActive ? Colors.white : Colors.white70,
                  color: isActive ? AppColors.textColor(context) : AppColors.textColor(context).withOpacity(0.7),
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

  bool _isKeyEnabled(String key) {
    if (activeField == 'bin') return ['0', '1'].contains(key);
    if (activeField == 'oct') return ['0', '1', '2', '3', '4', '5', '6', '7'].contains(key);
    if (activeField == 'dec') return ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(key);
    return true; // hex allows everything
  }

  BorderRadius _getShapeRadius() {
    return _buttonShape == 'circle'
        ? BorderRadius.circular(100)
        : BorderRadius.circular(14);
  }

  Widget _buildKey(String text, {VoidCallback? onTap, bool isAction = false, Color? textColor}) {
    bool enabled = isAction || _isKeyEnabled(text);

    // Background color set karna based on state
    Color bgCol = isAction
        ? AppColors.surfaceColor(context).withOpacity(0.5)
        : (enabled ? AppColors.surfaceColor(context).withOpacity(0.3) : AppColors.surfaceColor(context).withOpacity(0.1));

    return Expanded(
      child: Material(
        color: bgCol,
        //borderRadius: BorderRadius.circular(14),
        borderRadius: _getShapeRadius(),
        clipBehavior: Clip.antiAlias, // Ripple border ke bahar na nikle
        child: InkWell(
          onTap: enabled ? () {
            if (_isHapticsEnabled) HapticFeedback.selectionClick();
            if (onTap != null) onTap();
            else _onKeyPress(text);
          } : null, // Agar disabled hai toh tap register nahi hoga
          //borderRadius: BorderRadius.circular(14),
          borderRadius: _getShapeRadius(),
          // NAYA: Premium splash colors
          splashColor: (textColor ?? AppColors.cyanColor(context)).withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            height: 55,
            alignment: Alignment.center, // Text ko center karne ke liye
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? (enabled ? AppColors.textColor(context) : AppColors.textGrey(context).withOpacity(0.2)),
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
      child: Material(
        color: AppColors.surfaceColor(context)
            .withOpacity(0.5),
        //borderRadius: BorderRadius.circular(14),
        borderRadius: _getShapeRadius(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (_isHapticsEnabled) HapticFeedback.selectionClick();
            onTap();
          },
          //borderRadius: BorderRadius.circular(14),
          borderRadius: _getShapeRadius(),
          // NAYA: Icon key (Backspace) ke liye splash color
          splashColor: AppColors.cyanColor(context).withOpacity(0.2),
          highlightColor: AppColors.textColor(context).withOpacity(0.1),
          child: Container(
            height: 55,
            alignment: Alignment.center, // Icon ko center karne ke liye
            child: Icon(icon, color: AppColors.cyanColor(context), size: 26),
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
                  _buildKey('AC', isAction: true, textColor: AppColors.cyanColor(context), onTap: _onClear),
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