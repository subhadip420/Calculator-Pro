import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../widgets/custom_top_bar.dart';

class DateAddSubtractView extends StatefulWidget {
  final VoidCallback onBack;

  const DateAddSubtractView({super.key, required this.onBack});

  @override
  State<DateAddSubtractView> createState() => _DateAddSubtractViewState();
}

class _DateAddSubtractViewState extends State<DateAddSubtractView> {
  bool _isHapticsEnabled = true;

  // Initial Date State
  late int _day;
  late int _month;
  late int _year;

  // Initial Time State (Default 12:00 PM)
  int _hour = 12;
  int _minute = 0;
  bool _isAm = false; // false = PM, true = AM

  // Operation State
  String _operation = 'add'; // 'add' or 'subtract'

  // Input Controllers
  final TextEditingController _yearCtrl = TextEditingController(text: '0');
  final TextEditingController _monthCtrl = TextEditingController(text: '0');
  final TextEditingController _weekCtrl = TextEditingController(text: '0');
  final TextEditingController _dayCtrl = TextEditingController(text: '0');
  final TextEditingController _hourCtrl = TextEditingController(text: '0');
  final TextEditingController _minuteCtrl = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _day = now.day;
    _month = now.month;
    _year = now.year;
    _loadSettings();
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _weekCtrl.dispose();
    _dayCtrl.dispose();
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
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

  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      bool isLeapYear = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void _showCustomPicker({
    required String title,
    required int min,
    required int max,
    required int initialValue,
    required ValueChanged<int> onSelected,
    List<String>? customLabels,
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
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: initialValue - min),
                    itemExtent: 45,
                    onSelectedItemChanged: (index) {
                      if (_isHapticsEnabled) HapticFeedback.selectionClick();
                      tempValue = min + index;
                    },
                    children: List.generate(max - min + 1, (index) {
                      return GestureDetector(
                        onTap: () {
                          if (_isHapticsEnabled) HapticFeedback.selectionClick();
                          onSelected(min + index);
                          Navigator.pop(dialogContext);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            customLabels != null ? customLabels[index] : (min + index).toString().padLeft(2, '0'),
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
                style: TextStyle(color: AppColors.cyanColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: TextStyle(color: AppColors.textGrey(context), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bgColor(context).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.2)),
        ),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              cursorColor: AppColors.cyanColor(context),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: AppColors.textGrey(context), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // Real-time calculation logic
  DateTime _calculateResult() {
    int currentHour24 = _isAm ? (_hour == 12 ? 0 : _hour) : (_hour == 12 ? 12 : _hour + 12);

    int mult = _operation == 'add' ? 1 : -1;

    int addY = int.tryParse(_yearCtrl.text) ?? 0;
    int addM = int.tryParse(_monthCtrl.text) ?? 0;
    int addW = int.tryParse(_weekCtrl.text) ?? 0;
    int addD = int.tryParse(_dayCtrl.text) ?? 0;
    int addH = int.tryParse(_hourCtrl.text) ?? 0;
    int addMin = int.tryParse(_minuteCtrl.text) ?? 0;

    return DateTime(
      _year + (addY * mult),
      _month + (addM * mult),
      _day + (addD * mult) + ((addW * 7) * mult),
      currentHour24 + (addH * mult),
      _minute + (addMin * mult),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime resultDate = _calculateResult();

    String resMonth = _getMonthName(resultDate.month);
    String resDateStr = "$resMonth ${resultDate.day.toString().padLeft(2, '0')}, ${resultDate.year}";

    int resHour12 = resultDate.hour == 0 ? 12 : (resultDate.hour > 12 ? resultDate.hour - 12 : resultDate.hour);
    String resAmPm = resultDate.hour >= 12 ? "PM" : "AM";
    String resTimeStr = "$resHour12:${resultDate.minute.toString().padLeft(2, '0')} $resAmPm";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            CustomTopBar(
              toolId: 'date_add_subtract',
              title: 'Add & Subtract Time',
              iconPath: 'assets/images/calendar_calculator.png',
              onBack: widget.onBack,
              isHapticsEnabled: _isHapticsEnabled,
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- INITIAL DATE CARD ---
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Initial Date',
                                style: TextStyle(
                                  color: AppColors.textColor(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.cyanColor(context).withOpacity(0.8),
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildDateBox(
                                'Day',
                                _day.toString().padLeft(2, '0'),
                                onTap: () {
                                  _showCustomPicker(
                                    title: 'Select Day',
                                    min: 1,
                                    max: _getDaysInMonth(_year, _month),
                                    initialValue: _day,
                                    onSelected: (val) => setState(() => _day = val),
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
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
                                        int maxDays = _getDaysInMonth(_year, _month);
                                        if (_day > maxDays) _day = maxDays;
                                      });
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              _buildDateBox(
                                'Year',
                                _year.toString(),
                                isYear: true,
                                onTap: () {
                                  _showCustomPicker(
                                    title: 'Select Year',
                                    min: 1900,
                                    max: 2100,
                                    initialValue: _year,
                                    onSelected: (val) {
                                      setState(() {
                                        _year = val;
                                        int maxDays = _getDaysInMonth(_year, _month);
                                        if (_day > maxDays) _day = maxDays;
                                      });
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Initial Time',
                                style: TextStyle(
                                  color: AppColors.textColor(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.access_time_rounded,
                                color: AppColors.cyanColor(context).withOpacity(0.8),
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildDateBox(
                                'Hour',
                                _hour.toString().padLeft(2, '0'),
                                onTap: () {
                                  _showCustomPicker(
                                    title: 'Select Hour',
                                    min: 1,
                                    max: 12,
                                    initialValue: _hour,
                                    onSelected: (val) => setState(() => _hour = val),
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              _buildDateBox(
                                'Minute',
                                _minute.toString().padLeft(2, '0'),
                                onTap: () {
                                  _showCustomPicker(
                                    title: 'Select Minute',
                                    min: 0,
                                    max: 59,
                                    initialValue: _minute,
                                    onSelected: (val) => setState(() => _minute = val),
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              _buildDateBox(
                                'AM/PM',
                                _isAm ? 'AM' : 'PM',
                                onTap: () {
                                  _showCustomPicker(
                                    title: 'AM / PM',
                                    min: 0,
                                    max: 1,
                                    initialValue: _isAm ? 0 : 1,
                                    customLabels: ['AM', 'PM'],
                                    onSelected: (val) => setState(() => _isAm = val == 0),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- OPERATION CARD ---
                    Container(
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- OPERATION HEADER WITH REFRESH BUTTON ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Operation',
                                  style: TextStyle(
                                    color: AppColors.textColor(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                    setState(() {
                                      // Sabhi controllers ko 0 par reset kar diya
                                      _yearCtrl.text = '0';
                                      _monthCtrl.text = '0';
                                      _weekCtrl.text = '0';
                                      _dayCtrl.text = '0';
                                      _hourCtrl.text = '0';
                                      _minuteCtrl.text = '0';
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.refresh_rounded,
                                      color: AppColors.cyanColor(context).withOpacity(0.8),
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Container(
                              // Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: AppColors.bgColor(context).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                        setState(() => _operation = 'add');
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _operation == 'add'
                                                ? Icons.radio_button_checked_rounded
                                                : Icons.radio_button_off_rounded,
                                            color: _operation == 'add'
                                                ? AppColors.cyanColor(context)
                                                : AppColors.textGrey(context),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Addition',
                                            style: TextStyle(
                                              color: _operation == 'add'
                                                  ? AppColors.textColor(context)
                                                  : AppColors.textGrey(context),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (_isHapticsEnabled) HapticFeedback.lightImpact();
                                        setState(() => _operation = 'subtract');
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _operation == 'subtract'
                                                ? Icons.radio_button_checked_rounded
                                                : Icons.radio_button_off_rounded,
                                            color: _operation == 'subtract'
                                                ? AppColors.cyanColor(context)
                                                : AppColors.textGrey(context),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Subtraction',
                                            style: TextStyle(
                                              color: _operation == 'subtract'
                                                  ? AppColors.textColor(context)
                                                  : AppColors.textGrey(context),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Input Fields
                          Row(
                            children: [
                              _buildInputField('Years', _yearCtrl),
                              _buildInputField('Months', _monthCtrl),
                              _buildInputField('Weeks', _weekCtrl),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildInputField('Days', _dayCtrl),
                              _buildInputField('Hours', _hourCtrl),
                              _buildInputField('Minutes', _minuteCtrl),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- RESULT CARD ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cyanColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.5), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Calculation Result',
                            style: TextStyle(
                              color: AppColors.cyanColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            resDateStr,
                            style: TextStyle(
                              color: AppColors.textColor(context),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            resTimeStr,
                            style: TextStyle(
                              color: AppColors.textGrey(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
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
