import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConverterKeyboard extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool isHapticsEnabled;

  const ConverterKeyboard({
    super.key,
    required this.onKeyPress,
    required this.onBackspace,
    required this.onClear,
    this.isHapticsEnabled = true,
  });

  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);

  void _triggerHaptic() {
    if (isHapticsEnabled) HapticFeedback.selectionClick();
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
              _buildKey('C', textColor: cyanColor, onTap: onClear),
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
              const Expanded(child: SizedBox()), // Empty space matching 4th column
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
              const Expanded(child: SizedBox()), // Empty space matching 4th column
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper Methods to Build Keys ---

  Widget _buildKey(String text, {required VoidCallback onTap, Color? textColor}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _triggerHaptic();
          onTap();
        },
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
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
      child: GestureDetector(
        onTap: () {
          _triggerHaptic();
          onTap();
        },
        // Optional: Long press to clear if you still want it, but 'C' is there now
        onLongPress: () {
          _triggerHaptic();
          onClear();
        },
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(icon, color: cyanColor, size: 28),
          ),
        ),
      ),
    );
  }
}