import 'package:flutter/material.dart';

// --- REUSABLE CONVERSION CARD WIDGET ---
class ConversionCard extends StatefulWidget {
  final bool isActive;
  final String unitName;
  final String unitSymbol;
  final TextEditingController controller; // NAYA FIX: String value ki jagah Controller aayega
  final VoidCallback onTap;
  final VoidCallback onUnitTap;

  const ConversionCard({
    super.key,
    required this.isActive,
    required this.unitName,
    required this.unitSymbol,
    required this.controller,
    required this.onTap,
    required this.onUnitTap,
  });

  @override
  State<ConversionCard> createState() => _ConversionCardState();
}

class _ConversionCardState extends State<ConversionCard> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Agar shuru mein active hai, toh focus de do
    if (widget.isActive) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(ConversionCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Active/Inactive state change hone par Focus change karo
    if (widget.isActive && !oldWidget.isActive) {
      _focusNode.requestFocus();
    } else if (!widget.isActive && oldWidget.isActive) {
      _focusNode.unfocus();
    }
    // NAYA FIX: Yahan se cursor ko force-last karne wala code hata diya gaya hai.
    // Ab cursor exactly wahi rahega jahan aap tap karenge!
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final Color surfaceColor = const Color(0xFF1E2638);
    final Color cyanColor = const Color(0xFF4CD7F6);
    final Color textGrey = const Color(0xFFDBC2AD);

    // Dynamic text size logic
    double dynamicFontSize = widget.controller.text.length > 11 ? 26.0 : 34.0;

    return GestureDetector(
      onTap: () {
        widget.onTap();
        _focusNode.requestFocus();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: widget.isActive ? surfaceColor.withOpacity(0.6) : surfaceColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isActive ? cyanColor : Colors.white.withOpacity(0.05),
            width: widget.isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1st ROW: Unit Name (Symbol) > ---
            GestureDetector(
              onTap: widget.onUnitTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.unitName} (${widget.unitSymbol})',
                    style: TextStyle(
                      color: widget.isActive ? textGrey : textGrey.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: widget.isActive ? cyanColor : textGrey.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // --- 2nd ROW: Native TextField ---
            Container(
              height: 42,
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: widget.controller, // NAYA FIX: Direct parent wala controller use ho raha hai
                focusNode: _focusNode,
                readOnly: true,
                showCursor: widget.isActive,
                cursorColor: cyanColor,
                cursorWidth: 2.5,
                maxLines: 1,
                scrollPhysics: const BouncingScrollPhysics(),
                style: TextStyle(
                  color: widget.isActive ? cyanColor : Colors.white,
                  fontSize: dynamicFontSize,
                  fontWeight: FontWeight.w300,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onTap: () {
                  widget.onTap();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}