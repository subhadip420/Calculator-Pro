import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';

class CustomRulerSliderCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String symbol;
  final double currentValue;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final bool isHapticsEnabled;

  const CustomRulerSliderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.symbol,
    required this.currentValue,
    required this.min,
    required this.max,
    required this.onChanged,
    this.isHapticsEnabled = true,
  });

  @override
  State<CustomRulerSliderCard> createState() => _CustomRulerSliderCardState();
}

class _CustomRulerSliderCardState extends State<CustomRulerSliderCard> {
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.currentValue.toInt().toString());
  }

  @override
  void didUpdateWidget(CustomRulerSliderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Agar external slider ya logic se value change ho, toh textfield update ho
    if (oldWidget.currentValue != widget.currentValue) {
      String formattedVal = widget.currentValue.toInt().toString();
      if (_amountController.text != formattedVal) {
        _amountController.value = TextEditingValue(
          text: formattedVal,
          selection: TextSelection.collapsed(offset: formattedVal.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 14, bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Heading/Subtitle aur Input Box
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title, // Dynamic Title
                      style: TextStyle(
                        color: AppColors.textColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle, // Dynamic Subtitle
                      style: TextStyle(
                        color: AppColors.textGrey(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Input Box with Symbol
              Container(
                width: 140,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.bgColor(context).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color:  AppColors.cyanColor(context).withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        cursorColor: AppColors.cyanColor(context),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (val) {
                          double? newVal = double.tryParse(val.replaceAll(',', ''));
                          if (newVal != null && newVal >= widget.min && newVal <= widget.max) {
                            widget.onChanged(newVal);
                          }
                        },
                      ),
                    ),

                    // Dynamic Symbol Box
                    Container(
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColors.cyanColor(context).withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(11),
                          bottomRight: Radius.circular(11),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.symbol, // Dynamic Symbol (₹, $, etc.)
                        style: TextStyle(
                          color: AppColors.cyanColor(context).withOpacity(0.9),
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

          const SizedBox(height: 7),

          // --- INNER SCROLLABLE RULER ---
          _InnerRulerSlider(
            currentValue: widget.currentValue,
            min: widget.min,
            max: widget.max,
            onChanged: widget.onChanged,
            isHapticsEnabled: widget.isHapticsEnabled,
          ),
        ],
      ),
    );
  }
}

// --- PRIVATE WIDGET: ACTUAL SCROLLABLE SCALE ---
class _InnerRulerSlider extends StatefulWidget {
  final double currentValue;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final bool isHapticsEnabled;

  const _InnerRulerSlider({
    required this.currentValue,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.isHapticsEnabled,
  });

  @override
  State<_InnerRulerSlider> createState() => _InnerRulerSliderState();
}

class _InnerRulerSliderState extends State<_InnerRulerSlider> {
  late ScrollController _scrollController;
  final double _tickSpacing = 7.0;
  final int _valuePerTick = 1000;
  bool _isUserScrolling = false;
  late double _lastHapticValue;

  @override
  void initState() {
    super.initState();
    _lastHapticValue = widget.currentValue;
    double initialOffset = (widget.currentValue - widget.min) / _valuePerTick * _tickSpacing;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void didUpdateWidget(_InnerRulerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    double flexibleHeight = MediaQuery.of(context).size.height * 0.08;

    if (flexibleHeight < 55) {
      flexibleHeight = 55;
    } else if (flexibleHeight > 85) {
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
              NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                    _isUserScrolling = true;
                  } else if (scrollNotification is ScrollUpdateNotification) {
                    double offset = _scrollController.offset;
                    double exactValue = (offset / _tickSpacing) * _valuePerTick + widget.min;
                    double roundedValue = (exactValue / _valuePerTick).round() * _valuePerTick.toDouble();
                    roundedValue = roundedValue.clamp(widget.min, widget.max);

                    if (roundedValue != _lastHapticValue) {
                      if (widget.isHapticsEnabled) {
                        HapticFeedback.selectionClick(); // Sirf tab chalega jab setting ON hogi
                      }
                      _lastHapticValue = roundedValue;
                    }

                    widget.onChanged(roundedValue);
                  } else if (scrollNotification is ScrollEndNotification) {
                    _isUserScrolling = false;
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
                  padding: EdgeInsets.only(
                      left: halfWidth - (_tickSpacing / 2),
                      right: halfWidth - (_tickSpacing / 2)
                  ),
                  itemCount: totalTicks + 1,
                  itemBuilder: (context, index) {
                    bool isMajor = index % 10 == 0;
                    double value = widget.min + (index * _valuePerTick);

                    return SizedBox(
                      width: _tickSpacing,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                                  style: TextStyle(
                                    color: AppColors.textColor(context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 20),

                          const SizedBox(height: 16),

                          Container(
                            width: 2,
                            height: isMajor ? 24 : 12,
                            color: isMajor ? AppColors.textColor(context).withOpacity(0.5) : AppColors.textColor(context).withOpacity(0.2),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.cyanColor(context),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.cyanColor(context),
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