import 'package:flutter/material.dart';
import '../app_colors.dart';

// --- WIDGET: SCROLLABLE RULER SCALE ---
class CustomRulerSlider extends StatefulWidget {
  final double currentValue;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const CustomRulerSlider({
    super.key,
    required this.currentValue,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<CustomRulerSlider> createState() => _CustomRulerSliderState();
}

class _CustomRulerSliderState extends State<CustomRulerSlider> {
  late ScrollController _scrollController;

  // Tick spacing (gap) set to 7.0
  final double _tickSpacing = 7.0;
  final int _valuePerTick = 1000;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    double initialOffset = (widget.currentValue - widget.min) / _valuePerTick * _tickSpacing;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void didUpdateWidget(CustomRulerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Agar textbox se type karke value badli, toh scale automatically scroll hoga
    if (!_isUserScrolling && oldWidget.currentValue != widget.currentValue) {
      double newOffset = (widget.currentValue - widget.min) / _valuePerTick * _tickSpacing;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          newOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalTicks = ((widget.max - widget.min) / _valuePerTick).floor();

    // --- LOGIC: Screen ke hisaab se flexible height ---
    // Screen ki total height ka 8% hissa calculate karega
    double flexibleHeight = MediaQuery.of(context).size.height * 0.08;

    // Safety check: Height kam se kam 55 zaroor ho taaki UI na toote
    if (flexibleHeight < 55) {
      flexibleHeight = 55;
    } else if (flexibleHeight > 85) { // Max height limit
      flexibleHeight = 85;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double halfWidth = constraints.maxWidth / 2;

        return SizedBox(
          height: flexibleHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main Scrollable List (Ruler)
              NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                    _isUserScrolling = true;
                  } else if (scrollNotification is ScrollUpdateNotification) {
                    double offset = _scrollController.offset;
                    double exactValue = (offset / _tickSpacing) * _valuePerTick + widget.min;
                    double roundedValue = (exactValue / _valuePerTick).round() * _valuePerTick.toDouble();
                    roundedValue = roundedValue.clamp(widget.min, widget.max);
                    widget.onChanged(roundedValue);
                  } else if (scrollNotification is ScrollEndNotification) {
                    _isUserScrolling = false;
                    // Scroll rukne par exact line par magnet effect (snap)
                    double offset = _scrollController.offset;
                    double exactValue = (offset / _tickSpacing) * _valuePerTick + widget.min;
                    double roundedValue = (exactValue / _valuePerTick).round() * _valuePerTick.toDouble();
                    double targetOffset = (roundedValue - widget.min) / _valuePerTick * _tickSpacing;

                    Future.microtask(() {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          targetOffset,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }
                  return true;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  // _tickSpacing / 2 minus kiya taaki exact line center mein snap ho
                  padding: EdgeInsets.only(
                      left: halfWidth - (_tickSpacing / 2),
                      right: halfWidth - (_tickSpacing / 2)
                  ),
                  itemCount: totalTicks + 1,
                  itemBuilder: (context, index) {
                    bool isMajor = index % 10 == 0; // Har 10th line badi hogi
                    double value = widget.min + (index * _valuePerTick);

                    return SizedBox(
                      width: _tickSpacing,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Top Numbers
                          if (isMajor)
                            SizedBox(
                              width: 0,
                              height: 20,
                              child: OverflowBox(
                                minWidth: 0,
                                maxWidth: 100,
                                minHeight: 0,
                                maxHeight: 20,
                                child: Text(
                                  value == 0 ? '0' : '${(value / 1000).toInt()},000',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 20),

                          const SizedBox(height: 16), // Text aur line ke beech ki spacing

                          // Vertical Tick Lines
                          Container(
                            width: 2,
                            height: isMajor ? 24 : 12, // Badi line aur choti line
                            color: isMajor ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Center Indicator (Dot + Line)
              Positioned(
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.cyanColor(context), // Dynamic color
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 28, // Vertical line
                      decoration: BoxDecoration(
                        color: AppColors.cyanColor(context), // Dynamic color
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}