import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConverterKeyboard extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool isHapticsEnabled;
  final String buttonShape;

  const ConverterKeyboard({
    super.key,
    required this.onKeyPress,
    required this.onBackspace,
    required this.onClear,
    this.isHapticsEnabled = true,
    this.buttonShape = 'rounded',
  });

  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);

  void _triggerHaptic() {
    if (isHapticsEnabled) HapticFeedback.selectionClick();
  }

  BorderRadius _getShapeRadius() {
    return buttonShape == 'circle'
        ? BorderRadius.circular(100) // Circle ke liye full round
        : BorderRadius.circular(16); // Rounded ke liye normal curve
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Row 1: 7, 8, 9, C
          Row(
            children: [
              _buildKey('7', onTap: () => onKeyPress('7')),
              const SizedBox(width: 10),
              _buildKey('8', onTap: () => onKeyPress('8')),
              const SizedBox(width: 10),
              _buildKey('9', onTap: () => onKeyPress('9')),
              const SizedBox(width: 10),
              _buildKey('AC', textColor: Colors.orangeAccent, onTap: onClear),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: 4, 5, 6, Backspace
          Row(
            children: [
              _buildKey('4', onTap: () => onKeyPress('4')),
              const SizedBox(width: 10),
              _buildKey('5', onTap: () => onKeyPress('5')),
              const SizedBox(width: 10),
              _buildKey('6', onTap: () => onKeyPress('6')),
              const SizedBox(width: 10),
              _buildIconKey(Icons.backspace_outlined, onTap: onBackspace),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: 1, 2, 3, Empty Space
          Row(
            children: [
              _buildKey('1', onTap: () => onKeyPress('1')),
              const SizedBox(width: 10),
              _buildKey('2', onTap: () => onKeyPress('2')),
              const SizedBox(width: 10),
              _buildKey('3', onTap: () => onKeyPress('3')),
              const SizedBox(width: 10),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 10),

          // Row 4: 00, 0, ., Empty Space
          Row(
            children: [
              _buildKey('00', onTap: () => onKeyPress('00')),
              const SizedBox(width: 10),
              _buildKey('0', onTap: () => onKeyPress('0')),
              const SizedBox(width: 10),
              _buildKey('.', onTap: () => onKeyPress('.')),
              const SizedBox(width: 10),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String text, {required VoidCallback onTap, Color? textColor}) {
    return Expanded(
      child: Material(
        color: surfaceColor.withOpacity(0.5),
        //borderRadius: BorderRadius.circular(16),
        borderRadius: _getShapeRadius(),
        clipBehavior: Clip.antiAlias, // Ripple border ke bahar na nikle
        child: InkWell(
          onTap: () {
            _triggerHaptic();
            onTap();
          },
          //borderRadius: BorderRadius.circular(16),
          borderRadius: _getShapeRadius(),
          // NAYA: Ripple aur highlight animation colors
          splashColor: (textColor ?? cyanColor).withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            height: 65,
            alignment: Alignment.center, // Center mein laane ke liye
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 26,
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
        color: surfaceColor.withOpacity(0.5),
        //borderRadius: BorderRadius.circular(16),
        borderRadius: _getShapeRadius(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _triggerHaptic();
            onTap();
          },
          // Optional: Long press to clear
          onLongPress: () {
            _triggerHaptic();
            onClear();
          },
          //borderRadius: BorderRadius.circular(16),
          borderRadius: _getShapeRadius(),
          // NAYA: Icon key ke liye splash animation
          splashColor: cyanColor.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            height: 65,
            alignment: Alignment.center, // Center mein laane ke liye
            child: Icon(icon, color: cyanColor, size: 28),
          ),
        ),
      ),
    );
  }
}
