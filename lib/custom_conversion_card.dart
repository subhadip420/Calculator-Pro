import 'package:flutter/material.dart';

// --- REUSABLE BLINKING CURSOR WIDGET ---
class BlinkingCursor extends StatefulWidget {
  final Color cursorColor;

  const BlinkingCursor({super.key, required this.cursorColor});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 500ms mein cursor blink karega
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2.5,
        height: 32,
        decoration: BoxDecoration(
          color: widget.cursorColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// --- REUSABLE CONVERSION CARD WIDGET ---
class ConversionCard extends StatelessWidget {
  final bool isActive;
  final String unitName;
  final String unitSymbol;
  final String value;
  final VoidCallback onTap;
  final VoidCallback onUnitTap;

  const ConversionCard({
    super.key,
    required this.isActive,
    required this.unitName,
    required this.unitSymbol,
    required this.value,
    required this.onTap,
    required this.onUnitTap,
  });

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final Color surfaceColor = const Color(0xFF1E2638);
    final Color cyanColor = const Color(0xFF4CD7F6);
    final Color textGrey = const Color(0xFFDBC2AD);

    // Dynamic text size logic
    double dynamicFontSize = value.length > 11 ? 26.0 : 34.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isActive ? surfaceColor.withOpacity(0.6) : surfaceColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? cyanColor : Colors.white.withOpacity(0.05),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1st ROW: Unit Name (Symbol) > ---
            GestureDetector(
              onTap: onUnitTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$unitName ($unitSymbol)',
                    style: TextStyle(
                      color: isActive ? textGrey : textGrey.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isActive ? cyanColor : textGrey.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // --- 2nd ROW: Dynamic Typed Value + Blinking Cursor ---
            Container(
              height: 42,
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: isActive ? cyanColor : Colors.white,
                        fontSize: dynamicFontSize,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 4),
                      BlinkingCursor(cursorColor: cyanColor),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}