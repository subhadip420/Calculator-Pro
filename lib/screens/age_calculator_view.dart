import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';

class AgeCalculatorView extends StatefulWidget {
  final VoidCallback onBack;

  const AgeCalculatorView({super.key, required this.onBack});

  @override
  State<AgeCalculatorView> createState() => _AgeCalculatorViewState();
}

class _AgeCalculatorViewState extends State<AgeCalculatorView> {
  bool _isHapticsEnabled = true;
  Timer? _timer;
  // State Variables (Individual Day, Month, Year)
  late int _day;
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    // Default: Aaj ki date se 20 saal pehle
    DateTime now = DateTime.now();
    _day = now.day;
    _month = now.month;
    _year = now.year;

    _loadSettings();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Memory leak rokne ke liye
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
      });
    }
  }

  // Mahine ke hisaab se total din nikalne ka logic (Leap year ke sath)
  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      bool isLeapYear = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

// --- CUSTOM DIALOG PICKER ---
  void _showCustomPicker({
    required String title,
    required int min,
    required int max,
    required int initialValue,
    required ValueChanged<int> onSelected,
  }) {
    if (_isHapticsEnabled) HapticFeedback.lightImpact();
    int tempValue = initialValue;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            height: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.textGrey(context).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                // Header with Title & Done Button (Fallback ke liye rakha hai)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        title,
                        style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_isHapticsEnabled) HapticFeedback.selectionClick();
                        onSelected(tempValue);
                        Navigator.pop(dialogContext);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cyanColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                            "Done",
                            style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // Cupertino Spinner Picker
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: initialValue - min),
                    itemExtent: 45,
                    onSelectedItemChanged: (index) {
                      if (_isHapticsEnabled) HapticFeedback.selectionClick();
                      tempValue = min + index;
                    },
                    children: List.generate(max - min + 1, (index) {
                      // NAYA: GestureDetector lagaya taaki item par click karte hi select ho jaye
                      return GestureDetector(
                        onTap: () {
                          if (_isHapticsEnabled) HapticFeedback.selectionClick();
                          onSelected(min + index); // Tap ki hui value save hogi
                          Navigator.pop(dialogContext); // Dialog turant band ho jayega
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            (min + index).toString().padLeft(2, '0'),
                            style: TextStyle(color: AppColors.textColor(context), fontSize: 24, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- HELPER WIDGET FOR DATE BOXES ---
  Widget _buildDateBox(String label, String value, {bool isYear = false, required VoidCallback onTap}) {
    return Expanded(
      flex: isYear ? 3 : 2,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: AppColors.bgColor(context).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.cyanColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textGrey(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textGrey(context), fontSize: 15, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCountdownBox(String value, String label) {
    return Expanded(
      child: Container(
        height: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.bgColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(color: AppColors.textColor(context), fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: AppColors.textGrey(context), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime dob = DateTime(_year, _month, _day);

    // Safety check for future dates
    if (dob.isAfter(now)) {
      dob = now;
    }

    // Age Calculation
    int years = now.year - dob.year;
    int months = now.month - dob.month;
    int days = now.day - dob.day;

    if (days < 0) {
      months--;
      int daysInPrevMonth = _getDaysInMonth(now.month == 1 ? now.year - 1 : now.year, now.month == 1 ? 12 : now.month - 1);
      days += daysInPrevMonth;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    // Time Spent on Earth Calculations
    Duration diff = now.difference(dob);
    int totalMonths = (years * 12) + months;
    int totalWeeks = diff.inDays ~/ 7;
    int totalDays = diff.inDays;
    int totalHours = diff.inHours;
    int totalMinutes = diff.inMinutes;
    int totalSeconds = diff.inSeconds;

    // Next Birthday Calculation
    DateTime nextBirthday = DateTime(now.year, dob.month, dob.day);
    if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
      nextBirthday = DateTime(now.year + 1, dob.month, dob.day);
    }
    Duration nextBdayDiff = nextBirthday.difference(now);

    int nextBdayDays = nextBdayDiff.inDays;
    int nextBdayHours = nextBdayDiff.inHours % 24;
    int nextBdayMinutes = nextBdayDiff.inMinutes % 60;
    int nextBdaySeconds = nextBdayDiff.inSeconds % 60;

    String formattedDob = "${_day.toString().padLeft(2, '0')}${_getDaySuffix(_day)} ${_getMonthName(_month)} $_year";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          CustomTopBar(
            toolId: 'age',
            title: 'Age Calculator',
            iconPath: 'assets/images/percentage-discount-symbol.png',
            onBack: widget.onBack,
            isHapticsEnabled: _isHapticsEnabled,
          ),

          // --- MAIN SCROLL VIEW ---
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // --- DATE OF BIRTH CARD ---
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor(context).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Date of Birth',
                          style: TextStyle(
                            color: AppColors.textColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            // 1. DAY PICKER
                            _buildDateBox(
                                'Day',
                                _day.toString().padLeft(2, '0'),
                                onTap: () {
                                  _showCustomPicker(
                                    title: 'Select Day',
                                    min: 1,
                                    max: _getDaysInMonth(_year, _month), // Dynamic max days
                                    initialValue: _day,
                                    onSelected: (val) => setState(() => _day = val),
                                  );
                                }
                            ),
                            const SizedBox(width: 10),

                            // 2. MONTH PICKER
                            _buildDateBox(
                                'Month',
                                _month.toString().padLeft(2, '0'),
                                onTap: () {
                                  _showCustomPicker(
                                    title: 'Select Month',
                                    min: 1,
                                    max: 12,
                                    initialValue: _month,
                                    onSelected: (val) {
                                      setState(() {
                                        _month = val;
                                        // Agar month change karne se Day out of bounds ho jaye (eg. 31st Feb)
                                        int maxDays = _getDaysInMonth(_year, _month);
                                        if (_day > maxDays) _day = maxDays;
                                      });
                                    },
                                  );
                                }
                            ),
                            const SizedBox(width: 10),

                            // 3. YEAR PICKER
                            _buildDateBox(
                                'Year',
                                _year.toString(),
                                isYear: true,
                                onTap: () {
                                  _showCustomPicker(
                                    title: 'Select Year',
                                    min: 1900,
                                    max: DateTime.now().year,
                                    initialValue: _year,
                                    onSelected: (val) {
                                      setState(() {
                                        _year = val;
                                        // Leap year adjust (Agar 29 Feb tha aur non-leap year select kar liya)
                                        int maxDays = _getDaysInMonth(_year, _month);
                                        if (_day > maxDays) _day = maxDays;
                                      });
                                    },
                                  );
                                }
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- AGE RESULT CARDS ---
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor(context).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        // Your Birth date
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.bgColor(context).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text('Your Birth date', style: TextStyle(color: AppColors.textGrey(context), fontSize: 14)),
                              const SizedBox(height: 6),
                              Text(formattedDob, style: TextStyle(color: AppColors.textColor(context), fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Your Age
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.cyanColor(context).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text('Your Age', style: TextStyle(color: AppColors.textColor(context), fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text(
                                '$years Years | $months Months | $days Days',
                                style: TextStyle(color: AppColors.cyanColor(context), fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- TIME SPENT ON EARTH ---
                  Text('Time Spent on Earth', style: TextStyle(color: AppColors.cyanColor(context), fontSize: 18, fontWeight: FontWeight.bold)), //[cite: 4]
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor(context).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Month', totalMonths.toString()),
                        _buildInfoRow('Week', totalWeeks.toString()),
                        _buildInfoRow('Days', totalDays.toString()),
                        _buildInfoRow('Hours', totalHours.toString()),
                        _buildInfoRow('Minutes', totalMinutes.toString()),
                        _buildInfoRow('Seconds', totalSeconds.toString()), //[cite: 4]
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- KEEP CALM FOR NEXT BIRTHDAY ---
                  Text('Keep calm For Next Birthday', style: TextStyle(color: AppColors.cyanColor(context), fontSize: 18, fontWeight: FontWeight.bold)), //[cite: 4]
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.cyanColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.4), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        _buildCountdownBox(nextBdayDays.toString(), 'Days'),
                        _buildCountdownBox(nextBdayHours.toString(), 'Hours'),
                        _buildCountdownBox(nextBdayMinutes.toString(), 'Minutes'),
                        _buildCountdownBox(nextBdaySeconds.toString(), 'Seconds'), //[cite: 4]
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}