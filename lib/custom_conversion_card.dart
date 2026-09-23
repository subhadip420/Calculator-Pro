import 'package:flutter/material.dart';

// --- REUSABLE CONVERSION CARD WIDGET ---
// NAYA FIX: Isko StatefulWidget banaya gaya hai taaki TextEditingController aur Focus handle ho sake
class ConversionCard extends StatefulWidget {
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
  State<ConversionCard> createState() => _ConversionCardState();
}

class _ConversionCardState extends State<ConversionCard> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.value);
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

    // Agar bahar se value change hui hai (Type karne par), toh Controller update karo
    if (oldWidget.value != widget.value) {
      _textController.text = widget.value;
      // Value update hone ke baad cursor ko end mein set karo
      _textController.selection = TextSelection.collapsed(offset: widget.value.length);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
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
    double dynamicFontSize = widget.value.length > 11 ? 26.0 : 34.0;

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

            // --- 2nd ROW: Native TextField (Auto handles Cursor & Copy/Paste) ---
            Container(
              height: 42,
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                readOnly: true, // Native keyboard block, custom keyboard on
                showCursor: widget.isActive, // Sirf active card me cursor dikhega
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
                  widget.onTap(); // Tap karne par parent file ko bata do ki card active ho gaya
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}