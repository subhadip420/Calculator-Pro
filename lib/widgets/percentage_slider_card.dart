import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';

class PercentageSliderCard extends StatefulWidget {
  final String title;
  final double currentValue;
  final ValueChanged<double> onChanged;

  const PercentageSliderCard({super.key, required this.title, required this.currentValue, required this.onChanged});

  @override
  State<PercentageSliderCard> createState() => _PercentageSliderCardState();
}

class _PercentageSliderCardState extends State<PercentageSliderCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _updateControllerText(widget.currentValue);

    _controller.addListener(() {
      String text = _controller.text;
      double? val = double.tryParse(text);
      if (val != null && val >= 0 && val <= 100) {
        if (val != widget.currentValue) {
          widget.onChanged(val);
        }
      }
    });
  }

  void _updateControllerText(double value) {
    String newText = value == value.toInt() ? value.toInt().toString() : value.toStringAsFixed(1);
    _controller = TextEditingController(text: newText);
  }

  @override
  void didUpdateWidget(PercentageSliderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue) {
      String newText = widget.currentValue == widget.currentValue.toInt()
          ? widget.currentValue.toInt().toString()
          : widget.currentValue.toStringAsFixed(1);

      if (_controller.text != newText && double.tryParse(_controller.text) != widget.currentValue) {
        _controller.text = newText;
        _controller.selection = TextSelection.collapsed(offset: newText.length);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 0, right: 0),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title & Input Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            // Yahan apne hisaab se padding (left/right) adjust kar lena
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 120,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.bgColor(context).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          cursorColor: AppColors.cyanColor(context),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      Container(
                        width: 44,
                        decoration: BoxDecoration(
                          color: AppColors.cyanColor(context).withOpacity(0.1), // Purple box
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(11),
                            bottomRight: Radius.circular(11),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '%',
                          style: TextStyle(
                            color: AppColors.cyanColor(context).withOpacity(0.9), // Light purple text
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // Slider with Custom Ticks & Labels
          SizedBox(
            height: 46, // Space for slider + ticks + text
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Tick Marks & Text Layer
                Positioned(
                  top: 18, // Align tick marks just under the slider track
                  left: 20, // Match slider's default internal padding
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(11, (index) {
                      int val = index * 10;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 2,
                            height: 6,
                            color: AppColors.textColor(context).withOpacity(0.5), // Vertical tick line
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$val%',
                            style: TextStyle(
                              color: AppColors.textColor(context),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                // Actual Slider Layer
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.cyanColor(context),
                    // Purple active track
                    inactiveTrackColor:  AppColors.textColor(context).withOpacity(0.1),
                    // Grey inactive track
                    trackHeight: 2.0,
                    thumbShape: _CircleThumbShape(
                      thumbRadius: 10,
                      borderColor: AppColors.cyanColor(context),
                      thumbColor: AppColors.textGrey(context),
                    ),
                    // Custom thumb
                    overlayColor: AppColors.cyanColor(context).withOpacity(0.2),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  ),
                  child: Slider(
                    value: widget.currentValue.clamp(0, 100),
                    min: 0,
                    max: 100,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      widget.onChanged(val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- CUSTOM THUMB SHAPE (White fill with Dynamic Border) ---
class _CircleThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final Color borderColor, thumbColor; // NAYA: Color variable add kiya

  const _CircleThumbShape({
    this.thumbRadius = 10.0,
    required this.borderColor,
    required this.thumbColor, // NAYA: Constructor mein required kar diya
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(thumbRadius);

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    // White inside
    final Paint fillPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;

    // Dynamic border (Pehle fix purple tha, ab dynamic hai)
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);
  }
}