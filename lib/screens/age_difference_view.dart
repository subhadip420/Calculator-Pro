import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';

// Helper class for individual person's date
class PersonDate {
  int day;
  int month;
  int year;
  PersonDate(this.day, this.month, this.year);

  DateTime toDateTime() => DateTime(year, month, day);
}

class AgeDifferenceView extends StatefulWidget {
  final VoidCallback onBack;

  const AgeDifferenceView({super.key, required this.onBack});

  @override
  State<AgeDifferenceView> createState() => _AgeDifferenceViewState();
}

class _AgeDifferenceViewState extends State<AgeDifferenceView> {
  bool _isHapticsEnabled = true;
  bool _showResult = false; // Calculate button dabane par true hoga

  // Default 2 persons
  final List<PersonDate> _persons = [];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    // Default: Person 1 (25 years old), Person 2 (20 years old)
    _persons.add(PersonDate(now.day, now.month, now.year - 25));
    _persons.add(PersonDate(now.day, now.month, now.year - 20));

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
      });
    }
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      bool isLeapYear = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
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
              border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.5)),
            ),
            child: Column(
              children: [
                // Header with Title & Done Button (Fallback ke liye rakha hai)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                            color: AppColors.cyanColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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
                            style: TextStyle(
                              color: AppColors.textColor(context),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildDateBox(int personIndex, String label, String value, {bool isYear = false, required VoidCallback onTap}) {
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
              Text(value, style: TextStyle(color: AppColors.cyanColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: AppColors.textGrey(context), fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // --- AGE CALCULATION HELPER ---
  Map<String, int> _calculateExactAge(DateTime dob, DateTime toDate) {
    int years = toDate.year - dob.year;
    int months = toDate.month - dob.month;
    int days = toDate.day - dob.day;

    if (days < 0) {
      months--;
      int prevMonth = toDate.month == 1 ? 12 : toDate.month - 1;
      int prevYear = toDate.month == 1 ? toDate.year - 1 : toDate.year;
      days += _getDaysInMonth(prevYear, prevMonth);
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    return {'years': years, 'months': months, 'days': days};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          CustomTopBar(
            toolId: 'age_difference',
            title: 'Age Difference',
            iconPath: 'assets/images/age_difference.png',
            onBack: widget.onBack,
            isHapticsEnabled: _isHapticsEnabled,
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // HEADER WTIH ADD BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Compare Dates of Birth', style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
                      if (_persons.length < 5) // Max 5 persons limit
                        GestureDetector(
                          onTap: () {
                            if (_isHapticsEnabled) HapticFeedback.lightImpact();
                            setState(() {
                              DateTime now = DateTime.now();
                              _persons.add(PersonDate(now.day, now.month, now.year));
                              _showResult = false; // Hide result when new person added
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.cyanColor(context).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.add_rounded, color: AppColors.cyanColor(context), size: 16),
                                const SizedBox(width: 4),
                                Text('Add Person', style: TextStyle(color: AppColors.cyanColor(context), fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // PERSON CARDS LIST
                  ...List.generate(_persons.length, (index) {
                    PersonDate p = _persons[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Person ${index + 1}', style: TextStyle(color: AppColors.textColor(context), fontSize: 15, fontWeight: FontWeight.bold)),
                              if (index >= 2) // Pehle 2 delete nahi ho sakte
                                GestureDetector(
                                  onTap: () {
                                    if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                    setState(() {
                                      _persons.removeAt(index);
                                      _showResult = false;
                                    });
                                  },
                                  child: Icon(Icons.close_rounded, color: Colors.redAccent.withOpacity(0.8), size: 20),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildDateBox(index, 'Day', p.day.toString().padLeft(2, '0'), onTap: () {
                                _showCustomPicker(title: 'Select Day', min: 1, max: _getDaysInMonth(p.year, p.month), initialValue: p.day, onSelected: (val) {
                                  setState(() { p.day = val; _showResult = false; });
                                });
                              }),
                              const SizedBox(width: 10),
                              _buildDateBox(index, 'Month', p.month.toString().padLeft(2, '0'), onTap: () {
                                _showCustomPicker(title: 'Select Month', min: 1, max: 12, initialValue: p.month, onSelected: (val) {
                                  setState(() {
                                    p.month = val;
                                    int maxDays = _getDaysInMonth(p.year, p.month);
                                    if (p.day > maxDays) p.day = maxDays;
                                    _showResult = false;
                                  });
                                });
                              }),
                              const SizedBox(width: 10),
                              _buildDateBox(index, 'Year', p.year.toString(), isYear: true, onTap: () {
                                _showCustomPicker(title: 'Select Year', min: 1900, max: DateTime.now().year, initialValue: p.year, onSelected: (val) {
                                  setState(() {
                                    p.year = val;
                                    int maxDays = _getDaysInMonth(p.year, p.month);
                                    if (p.day > maxDays) p.day = maxDays;
                                    _showResult = false;
                                  });
                                });
                              }),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  // CALCULATE BUTTON
                  GestureDetector(
                    onTap: () {
                      if (_isHapticsEnabled) HapticFeedback.selectionClick();
                      setState(() => _showResult = true);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cyanColor(context).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.5)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Calculate Difference',
                        style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // RESULT SECTION
                  if (_showResult) ...[
                    Text('Calculation Result', style: TextStyle(color: AppColors.cyanColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.textGrey(context).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // 1. Current Ages of all persons
                          ...List.generate(_persons.length, (index) {
                            DateTime dob = _persons[index].toDateTime();
                            Map<String, int> age = _calculateExactAge(dob, DateTime.now());
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Person ${index + 1} Age:', style: TextStyle(color: AppColors.textGrey(context), fontSize: 14)),
                                  Text('${age['years']}y ${age['months']}m ${age['days']}d', style: TextStyle(color: AppColors.textColor(context), fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }),

                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1)),

                          /// 2. Comparison Logic (Compares consecutive persons: 1 vs 2, 2 vs 3, etc.)
                          ...List.generate(_persons.length - 1, (index) {
                            DateTime date1 = _persons[index].toDateTime();
                            DateTime date2 = _persons[index + 1].toDateTime();

                            bool p1Older = date1.isBefore(date2);
                            DateTime olderDate = p1Older ? date1 : date2;
                            DateTime youngerDate = p1Older ? date2 : date1;

                            String olderName = p1Older ? 'Person ${index + 1}' : 'Person ${index + 2}';
                            String youngerName = p1Older ? 'Person ${index + 2}' : 'Person ${index + 1}';

                            Map<String, int> diff = _calculateExactAge(olderDate, youngerDate);
                            int totalDaysDiff = youngerDate.difference(olderDate).inDays;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16), // Har comparison block ke beech gap
                                Text(
                                    'Difference between Person ${index + 1} & ${index + 2}:',
                                    style: TextStyle(color: AppColors.textGrey(context), fontSize: 13)
                                ),
                                const SizedBox(height: 6),

                                if (date1.isAtSameMomentAs(date2))
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                          'Both persons are of the exact same age!',
                                          style: TextStyle(color: AppColors.cyanColor(context), fontSize: 15, fontWeight: FontWeight.bold)
                                      ),
                                    ),
                                  )
                                else ...[
                                  Text(
                                    '${diff['years']} Years, ${diff['months']} Months, ${diff['days']} Days',
                                    style: TextStyle(color: AppColors.cyanColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),

                                  // Highlight Box for "Who is older"
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgColor(context).withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '$olderName is older than $youngerName',
                                          style: TextStyle(color: AppColors.orangeColor(context), fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Total gap: $totalDaysDiff Days',
                                          style: TextStyle(color: AppColors.textGrey(context), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}