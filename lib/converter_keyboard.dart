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
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 10),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 10),
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 10),
          Row(
            children: [
              // '.' Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: _buildButton('.', onTap: () { _triggerHaptic(); onKeyPress('.'); }),
                ),
              ),

              // '0' Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: _buildButton('0', onTap: () { _triggerHaptic(); onKeyPress('0'); }),
                ),
              ),

              // Backspace Button
              Expanded(
                child: GestureDetector(
                  onTap: () { _triggerHaptic(); onBackspace(); },
                  onLongPress: () { _triggerHaptic(); onClear(); }, // Long press se pura clear (AC)
                  child: Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(Icons.backspace_outlined, color: cyanColor, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: key == keys.last ? 0 : 10.0),
            child: _buildButton(key, onTap: () {
              _triggerHaptic();
              onKeyPress(key);
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}