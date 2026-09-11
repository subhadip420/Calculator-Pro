import 'dart:convert';

import 'package:flutter/material.dart';

//import 'package:math_expressions/math_expressions.dart';
import 'package:math_expressions/math_expressions.dart' hide Stack;
import 'package:shared_preferences/shared_preferences.dart';
import 'calculator_button.dart';
import 'action_button.dart';
import 'custom_dialog.dart';

void main() {
  runApp(const CalculatorProApp());
}

class CalculatorProApp extends StatelessWidget {
  const CalculatorProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator Pro',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E131D),
        fontFamily: 'Inter',
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  bool isScientific = false;
  bool isEvaluated = false;
  bool isDegreeMode = true;

  bool isHistoryOpen = false; // NAYA: History panel state
  List<String> _historyList = []; // NAYA: History data store karne ke liye

  bool _isDragging = false;
  double _dragOffset = 0.0;

  String equation = '';
  String result = '';

  final TextEditingController _equationController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Theme Colors
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color orangeColor = const Color(0xFFFF9500);
  final Color redColor = const Color(0xFFFFB4AB);
  final Color textGrey = const Color(0xFFDBC2AD);
  final Color white = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // Screen open hote hi cursor show karne ke liye
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _equationController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Basic Calculation Functions ---
  double _add(double a, double b) => a + b;

  double _subtract(double a, double b) => a - b;

  double _multiply(double a, double b) => a * b;

  double _divide(double a, double b) => a / b;

  double _modulo(double a, double b) => a % b;

  // NAYA: Local storage se history nikalna
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _historyList = prefs.getStringList('calculator_history') ?? [];
    });
  }

  String _calculateResult(String eq, {bool isFinalCall = false}) {
    if (eq.isEmpty) return '';

    // 1. PRE-VALIDATION: Agar equation galat symbols se shuru hoti hai
    if (eq.startsWith('^') || eq.startsWith('!') || eq.startsWith('×') || eq.startsWith('÷') || eq.startsWith('%')) {
      return isFinalCall ? 'Expression error' : '';
    }

    try {
      String sanitized = eq;

      // 2. IMPLICIT MULTIPLICATION (Smart Auto-Multiply)
      // Rule A: Number ke theek baad Root, Function, Pi, e ya Bracket aaye (Jaise 5√9 -> 5*√9, 5sin -> 5*sin, 5( -> 5*()
      sanitized = sanitized.replaceAllMapped(
        RegExp(r'(\d)(√|sin|cos|tan|log|ln|π|e|\()'),
        (Match m) => '${m[1]}*${m[2]}',
      );

      // Rule B: Bracket close ya Factorial ke baad kuch aaye (Jaise )5 -> )*5, 5!2 -> 5!*2)
      sanitized = sanitized.replaceAllMapped(
        RegExp(r'(\)|!)(√|sin|cos|tan|log|ln|π|e|\d|\()'),
        (Match m) => '${m[1]}*${m[2]}',
      );

      // Rule C: Constants ke beech mein ya baad mein aaye (Jaise πe -> π*e, π5 -> π*5)
      sanitized = sanitized.replaceAllMapped(
        RegExp(r'(π|e)(√|sin|cos|tan|log|ln|π|e|\d|\()'),
        (Match m) => '${m[1]}*${m[2]}',
      );

      // 3. UI SYMBOLS KO MATH FORMAT ME BADALNA
      sanitized = sanitized
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', '3.141592653589793')
          .replaceAll('e', '2.718281828459045')
          .replaceAll('√', 'sqrt(') // FIX: UI mein '√' dikhega, par math engine 'sqrt(' read karega
          .replaceAll('²', '^2');

      sanitized = sanitized
          .replaceAll('log10(', '(1/2.302585092994046)*ln(')
          .replaceAll('log2(', '(1/0.6931471805599453)*ln(');

      // Degree to Radian conversion
      if (isDegreeMode) {
        sanitized = sanitized
            .replaceAll('sin(', 'sin((3.141592653589793/180)*')
            .replaceAll('cos(', 'cos((3.141592653589793/180)*')
            .replaceAll('tan(', 'tan((3.141592653589793/180)*');
      }

      // 4. AUTO-CLOSE BRACKETS
      // Ab ye background mein hidden 'sqrt(' wale brackets ko bhi perfectly close karega
      int openParens = sanitized.split('(').length - 1;
      int closeParens = sanitized.split(')').length - 1;
      for (int i = 0; i < (openParens - closeParens); i++) {
        sanitized += ')';
      }

      // 5. PARSE AND EVALUATE
      Parser p = Parser();
      Expression exp = p.parse(sanitized);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // Agar math error aaye jaise (1/0)
      if (eval.isNaN || eval.isInfinite) return 'Expression error';

      // Negative zero fix
      if (eval == -0.0) eval = 0.0;

      // Output Formatting
      if (eval == eval.toInt()) {
        return eval.toInt().toString();
      }
      return eval.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    } catch (e) {
      // 6. ERROR HANDLING
      // Agar user ne = daba diya hai aur format galat hai, toh properly error dikhao
      if (isFinalCall) {
        return 'Expression error';
      }
      // Type karte waqt error aaye (jaise 5+) toh purana result hold karo
      return result;
    }
  }

  // --- Button Press Handler Update ---
  void _onKeyPress(String key) {
    if (!_focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_focusNode);
    }

    setState(() {
      int cursorPos = _equationController.selection.baseOffset;
      if (cursorPos < 0) cursorPos = _equationController.text.length;

      // Degree aur Radian mode toggle karna (Iska output turant result me dikhega)
      if (key == 'deg') {
        isDegreeMode = true;
        result = _calculateResult(_equationController.text);
        return;
      } else if (key == 'rad') {
        isDegreeMode = false;
        result = _calculateResult(_equationController.text);
        return;
      } else if (key == 'Inv') {
        // Future feature: Jab aap Inv dabayein to UI me sin ki jagah asin dikhne lage
        return;
      }

      bool isOperator = ['+', '-', '×', '÷', '%', '^'].contains(key);
      String inputKey = key;

      if (key == 'AC') {
        _equationController.clear();
        result = '';
        isEvaluated = false;
      } else if (key == 'BACK') {
        if (_equationController.text.isNotEmpty && cursorPos > 0) {
          String text = _equationController.text;
          String newText = text.substring(0, cursorPos - 1) + text.substring(cursorPos);
          _equationController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: cursorPos - 1),
          );
          isEvaluated = false;
        }
      } else if (key == '=') {
        if (_equationController.text.isNotEmpty) {
          // NAYA LOGIC: Yahan isFinalCall ko true pass kiya hai
          String finalResult = _calculateResult(_equationController.text, isFinalCall: true);
          if (finalResult.isNotEmpty) {
            result = finalResult;
            isEvaluated = true;

            if (finalResult != 'Expression error') {
              _saveToHistory(_equationController.text, finalResult);
            }
          }
        }
      } else {
        if (isEvaluated) {
          if (isOperator) {
            // NAYA LOGIC: Agar "Expression error" aaya hai aur uske baad + dabaya toh error clear ho jayega
            if (result == 'Expression error') {
              _equationController.text = inputKey;
              _equationController.selection = TextSelection.collapsed(offset: inputKey.length);
            } else {
              _equationController.text = result + inputKey;
              _equationController.selection = TextSelection.collapsed(offset: _equationController.text.length);
            }
          } else {
            _equationController.text = inputKey;
            _equationController.selection = TextSelection.collapsed(offset: inputKey.length);
          }
          isEvaluated = false;
        } else {
          // ... (Aapka Duplicate / Replace Operator aur baaki Normal Insertion ka logic yahan bilkul same rahega) ...
          // Duplicate / Replace Operator Logic
          String before = _equationController.text.substring(0, cursorPos);
          String after = _equationController.text.substring(cursorPos);

          if (isOperator && before.isNotEmpty) {
            String lastChar = before[before.length - 1];
            if (['+', '-', '×', '÷', '%', '^'].contains(lastChar)) {
              if (lastChar == key) {
                return;
              } else {
                String newBefore = before.substring(0, before.length - 1) + inputKey;
                _equationController.value = TextEditingValue(
                  text: newBefore + after,
                  selection: TextSelection.collapsed(offset: newBefore.length),
                );
                result = _calculateResult(_equationController.text);
                return;
              }
            }
          }

          String newText = before + inputKey + after;
          _equationController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: before.length + inputKey.length),
          );
        }
      }

      // Type karte hi real-time answer calculate karna
      if (key != '=' && key != 'AC') {
        result = _calculateResult(_equationController.text);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _equationController.selection.baseOffset == _equationController.text.length) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  double _getDynamicFontSize() {
    if (isEvaluated) return isScientific ? 22.0 : 28.0;

    final len = _equationController.text.length;

    if (isScientific) {
      if (len <= 12) return 28.0;
      if (len <= 18) return 24.0;
      return 20.0;
    } else {
      if (len <= 8) return 46.0; // Pehle 8 numbers tak sabse BADA size
      if (len <= 13) return 36.0; // 8 se 13 numbers ke beech thoda chota
      return 28.0; // 13 ke baad minimum size aur scroll shuru
    }
  }

  // --- NAYA FUNCTION: History Save Karne Ke Liye ---
  Future<void> _saveToHistory(String eq, String res) async {
    final prefs = await SharedPreferences.getInstance();

    // Purani history fetch karein (Agar nahi hai to khali list banayein)
    List<String> history = prefs.getStringList('calculator_history') ?? [];

    // Date aur Time format karna (Jaise: 10-09-2026 20:23)
    final now = DateTime.now();
    String formattedDate =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Naya data JSON map mein banayein
    Map<String, String> newEntry = {'equation': eq, 'result': res, 'datetime': formattedDate};

    // Nayi entry ko list ke shuru mein dalein (Latest pehle dikhega)
    history.insert(0, jsonEncode(newEntry));

    // Optional: History ko 50 items tak limit karein taaki storage full na ho
    if (history.length > 50) {
      history = history.sublist(0, 50);
    }

    // Wapas save karein
    await prefs.setStringList('calculator_history', history);
    setState(() {
      _historyList = history;
    });
  }

  // --- NAYA FUNCTION: Clear History Dialog ---
  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Clear History',
          subtitle: 'Are you sure you want to delete all your calculation history?',
          isSingleButton: false,
          primaryButtonText: 'Delete',
          primaryButtonBgColor: redColor, // App ka red theme color
          primaryButtonTextColor: bgColor, // Dark text for contrast
          secondaryButtonText: 'Cancel',
          onPrimaryPressed: () async {
            // 1. Pehle Dialog ko close karein
            Navigator.of(context).pop();

            // 2. Phir History clear karne ka logic chalayein
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('calculator_history');
            setState(() {
              _historyList.clear();
              isHistoryOpen = false;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. MASTER STACK (History Background + Sliding Calculator)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(end: isScientific ? 200.0 : 300.0),
                    builder: (context, topFlex, child) {
                      // Flex aur Height Calculation
                      double totalFlex = 700.0;
                      double keypadFlex = totalFlex - topFlex;
                      // Keypad ki height nikal rahe hain taaki calculator utna hi niche slide ho
                      double keypadHeight = constraints.maxHeight * (keypadFlex / totalFlex);

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // ----------------------------------------------------
                          // BACKGROUND LAYER: HISTORY PANEL (Redesigned)
                          // ----------------------------------------------------
                          AnimatedOpacity(
                            duration: Duration(milliseconds: _isDragging ? 0 : 300),
                            opacity: _isDragging
                                ? (_dragOffset / keypadHeight).clamp(0.0, 1.0)
                                : (isHistoryOpen ? 1.0 : 0.0),
                            child: Builder(
                              builder: (context) {
                                // 1. DATE-WISE GROUPING LOGIC
                                Map<String, List<Map<String, dynamic>>> groupedHistory = {};
                                DateTime now = DateTime.now();
                                String todayStr =
                                    "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
                                DateTime yesterday = now.subtract(const Duration(days: 1));
                                String yesterdayStr =
                                    "${yesterday.day.toString().padLeft(2, '0')}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.year}";

                                for (String entry in _historyList) {
                                  Map<String, dynamic> item = jsonDecode(entry);
                                  String fullDateTime = item['datetime'] ?? '';
                                  List<String> parts = fullDateTime.split(' ');
                                  String datePart = parts.isNotEmpty ? parts[0] : '';

                                  String displayDate = datePart;
                                  if (datePart == todayStr) {
                                    displayDate = 'Today';
                                  } else if (datePart == yesterdayStr) {
                                    displayDate = 'Yesterday';
                                  }

                                  if (!groupedHistory.containsKey(displayDate)) {
                                    groupedHistory[displayDate] = [];
                                  }
                                  groupedHistory[displayDate]!.add(item);
                                }

                                return Container(
                                  height: keypadHeight,
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10.0), // Bahar ka margin
                                  child: Card(
                                    color: surfaceColor.withOpacity(0.3),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      side: BorderSide(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    child: Column(
                                      children: [
                                        // 2. TOP BAR (Back, Title, Delete)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 2.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.arrow_back_ios_new,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    onPressed: () => setState(() => isHistoryOpen = false),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Text(
                                                    'History',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete_outline, color: redColor),
                                                // onPressed: () async {
                                                //   Clear History Logic
                                                //   final prefs = await SharedPreferences.getInstance();
                                                //   await prefs.remove('calculator_history');
                                                //   setState(() {
                                                //     _historyList.clear();
                                                //   });
                                                // },
                                                onPressed: _showClearHistoryDialog,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // 3. GROUPED HISTORY ITEMS
                                        Expanded(
                                          child: _historyList.isEmpty
                                              ? Center(
                                                  child: Text(
                                                    'No History yet',
                                                    style: TextStyle(color: textGrey, fontSize: 16),
                                                  ),
                                                )
                                              : ListView(
                                                  // Pura ListView left aur right se thoda padding lega
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                                  children: groupedHistory.entries.map((entry) {
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        // 1. DATE ROW (Upar left side mein Today/Date)
                                                        Padding(
                                                          padding: const EdgeInsets.only(
                                                            bottom: 4.0,
                                                            top: 2.0,
                                                            left: 4.0,
                                                          ),
                                                          child: Text(
                                                            entry.key,
                                                            style: TextStyle(
                                                              color: cyanColor,
                                                              fontSize: 14,
                                                              //fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),

                                                        // 2. ITEMS (Date ke niche full width cards)
                                                        ...entry.value.map((item) {
                                                          // Saved format "10-09-2026 20:23" me se sirf time (20:23) nikalna
                                                          String fullDateTime = item['datetime'] ?? '';
                                                          String timePart = fullDateTime.contains(' ')
                                                              ? fullDateTime.split(' ')[1]
                                                              : '';

                                                          return Container(
                                                            width: double.infinity,
                                                            // Full width card
                                                            margin: const EdgeInsets.only(bottom: 12),
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 5,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: bgColor.withOpacity(0.5), // Inner card color
                                                              borderRadius: BorderRadius.circular(16),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                              // Text right align
                                                              children: [
                                                                // Time (Left side upar)
                                                                Align(
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    timePart,
                                                                    style: TextStyle(
                                                                      color: textGrey.withOpacity(0.8),
                                                                      fontSize: 11,
                                                                    ),
                                                                  ),
                                                                ),

                                                                const SizedBox(height: 0),
                                                                // Equation (Font chhota kiya - 16)
                                                                Text(
                                                                  item['equation'] ?? '',
                                                                  style: TextStyle(color: textGrey, fontSize: 16),
                                                                ),

                                                                const SizedBox(height: 0),
                                                                // Result (Font chhota kiya - 20)
                                                                Text(
                                                                  item['result'] ?? '',
                                                                  style: const TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                        ),

                                        // 4. BOTTOM HINT TEXT
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10.0, top: 8.0),
                                          child: Text(
                                            'Swipe for options',
                                            style: TextStyle(color: textGrey.withOpacity(0.4), fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // ----------------------------------------------------
                          // FOREGROUND LAYER: CALCULATOR (Slides Down)
                          // ----------------------------------------------------
                          AnimatedPositioned(
                            // NAYA: Jab finger touch hai toh duration 0 taaki lag na ho
                            duration: Duration(milliseconds: _isDragging ? 0 : 350),
                            curve: Curves.easeOutCubic,
                            // Position directly finger(_dragOffset) ko follow karegi
                            top: _isDragging ? _dragOffset : (isHistoryOpen ? keypadHeight : 0),
                            bottom: _isDragging ? -_dragOffset : (isHistoryOpen ? -keypadHeight : 0),
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                // Top Bar
                                _buildTopBar(),

                                // Display Card With Real-time Swipe Gestures
                                Expanded(
                                  flex: topFlex.toInt(),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    // --- NAYA FINGER TRACKING LOGIC ---
                                    onVerticalDragStart: (details) {
                                      setState(() {
                                        _isDragging = true;
                                        // Drag shuru hote hi current position pakad lega
                                        _dragOffset = isHistoryOpen ? keypadHeight : 0.0;
                                      });
                                    },
                                    onVerticalDragUpdate: (details) {
                                      setState(() {
                                        _dragOffset += details.delta.dy;
                                        // Screen ke bahar slide hone se rokna
                                        if (_dragOffset < 0) _dragOffset = 0;
                                        if (_dragOffset > keypadHeight) _dragOffset = keypadHeight;
                                      });
                                    },
                                    onVerticalDragEnd: (details) {
                                      setState(() {
                                        _isDragging = false;
                                        // Agar speed mein slide kiya hai toh force open/close
                                        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
                                          isHistoryOpen = true;
                                        } else if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
                                          isHistoryOpen = false;
                                        } else {
                                          // Warna agar aadhi screen se zyada slide kiya hai toh auto-snap
                                          isHistoryOpen = _dragOffset > (keypadHeight / 2);
                                        }
                                      });
                                    },
                                    // ----------------------------------
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Card(
                                        color: surfaceColor.withOpacity(0.3),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          side: BorderSide(color: Colors.white.withOpacity(0.05)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              // 1. Input Section
                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Expanded(
                                                        child: TweenAnimationBuilder<double>(
                                                          duration: const Duration(milliseconds: 250),
                                                          curve: Curves.easeOutCubic,
                                                          tween: Tween<double>(end: _getDynamicFontSize()),
                                                          builder: (context, animatedSize, child) {
                                                            return TextField(
                                                              controller: _equationController,
                                                              focusNode: _focusNode,
                                                              scrollController: _scrollController,
                                                              readOnly: true,
                                                              showCursor: !isEvaluated,
                                                              cursorColor: cyanColor,
                                                              cursorWidth: 3,
                                                              cursorHeight: animatedSize + 4,
                                                              textAlign: TextAlign.right,
                                                              maxLines: 1,
                                                              minLines: 1,
                                                              style: TextStyle(color: white, fontSize: animatedSize),
                                                              decoration: const InputDecoration(
                                                                border: InputBorder.none,
                                                                isDense: true,
                                                                contentPadding: EdgeInsets.zero,
                                                              ),
                                                              onTap: () {
                                                                FocusScope.of(context).requestFocus(_focusNode);
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // 2. Result Section
                                              if (result.isNotEmpty)
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment: Alignment.centerRight,
                                                  child: TweenAnimationBuilder<double>(
                                                    duration: const Duration(milliseconds: 250),
                                                    curve: Curves.easeOutCubic,
                                                    tween: Tween<double>(
                                                      end: isEvaluated
                                                          ? (isScientific ? 46.0 : 64.0)
                                                          : (isScientific ? 24.0 : 32.0),
                                                    ),
                                                    builder: (context, animatedResultSize, child) {
                                                      return Text(
                                                        result,
                                                        style: TextStyle(
                                                          fontSize: animatedResultSize,
                                                          fontWeight: isEvaluated ? FontWeight.w300 : FontWeight.normal,
                                                          color: isEvaluated
                                                              ? Colors.white
                                                              : Colors.white.withOpacity(0.8),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Responsive Keypad Area (Aapka keypad waisa ka waisa hi rahega)

                                // Responsive Keypad Area
                                Expanded(
                                  flex: keypadFlex.toInt(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                    child: Column(
                                      children: [
                                        if (isScientific) ...[
                                          Expanded(
                                            child: Row(
                                              children: [
                                                CalculatorButton(
                                                  text: 'log10',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('log10('),
                                                ),
                                                CalculatorButton(
                                                  text: 'sin',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('sin('),
                                                ),
                                                CalculatorButton(
                                                  text: 'cos',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('cos('),
                                                ),
                                                CalculatorButton(
                                                  text: 'tan',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('tan('),
                                                ),
                                                CalculatorButton(
                                                  text: 'ln',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('ln('),
                                                ),
                                                CalculatorButton(
                                                  text: 'deg',
                                                  textColor: cyanColor,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('deg'),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                CalculatorButton(
                                                  text: 'log2',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('log2('),
                                                ),
                                                CalculatorButton(
                                                  text: 'x²',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('²'),
                                                ),
                                                CalculatorButton(
                                                  text: '(',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('('),
                                                ),
                                                CalculatorButton(
                                                  text: ')',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress(')'),
                                                ),
                                                CalculatorButton(
                                                  text: 'rad',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('rad'),
                                                ),
                                                CalculatorButton(
                                                  text: 'Inv',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('Inv'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        Expanded(
                                          child: Row(
                                            children: [
                                              if (isScientific)
                                                CalculatorButton(
                                                  text: 'x!',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('!'),
                                                ),
                                              CalculatorButton(
                                                text: 'AC',
                                                textColor: Colors.orangeAccent,
                                                bgColor: surfaceColor,
                                                onTap: () => _onKeyPress('AC'),
                                              ),
                                              CalculatorButton(
                                                text: '%',
                                                textColor: cyanColor,
                                                bgColor: surfaceColor,
                                                fontSize: 18,
                                                onTap: () => _onKeyPress('%'),
                                              ),
                                              CalculatorButton(
                                                icon: Icons.backspace_outlined,
                                                textColor: cyanColor,
                                                bgColor: surfaceColor,
                                                onTap: () => _onKeyPress('BACK'),
                                              ),
                                              CalculatorButton(
                                                text: '÷',
                                                textColor: white,
                                                bgColor: orangeColor.withOpacity(0.15),
                                                fontSize: 30,
                                                onTap: () => _onKeyPress('÷'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              if (isScientific)
                                                CalculatorButton(
                                                  text: 'xʸ',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('^'),
                                                ),
                                              CalculatorButton(
                                                text: '7',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('7'),
                                              ),
                                              CalculatorButton(
                                                text: '8',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('8'),
                                              ),
                                              CalculatorButton(
                                                text: '9',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('9'),
                                              ),
                                              CalculatorButton(
                                                text: '×',
                                                textColor: white,
                                                bgColor: orangeColor.withOpacity(0.15),
                                                fontSize: 30,
                                                onTap: () => _onKeyPress('×'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              if (isScientific)
                                                CalculatorButton(
                                                  text: '√x',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('√'),
                                                ),
                                              CalculatorButton(
                                                text: '4',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('4'),
                                              ),
                                              CalculatorButton(
                                                text: '5',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('5'),
                                              ),
                                              CalculatorButton(
                                                text: '6',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('6'),
                                              ),
                                              CalculatorButton(
                                                text: '−',
                                                textColor: white,
                                                bgColor: orangeColor.withOpacity(0.15),
                                                fontSize: 30,
                                                onTap: () => _onKeyPress('-'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              if (isScientific)
                                                CalculatorButton(
                                                  text: 'π',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('π'),
                                                ),
                                              CalculatorButton(
                                                text: '1',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('1'),
                                              ),
                                              CalculatorButton(
                                                text: '2',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('2'),
                                              ),
                                              CalculatorButton(
                                                text: '3',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('3'),
                                              ),
                                              CalculatorButton(
                                                text: '+',
                                                textColor: white,
                                                bgColor: orangeColor.withOpacity(0.15),
                                                fontSize: 30,
                                                onTap: () => _onKeyPress('+'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              if (isScientific)
                                                CalculatorButton(
                                                  text: 'e',
                                                  textColor: white,
                                                  bgColor: surfaceColor,
                                                  fontSize: 18,
                                                  onTap: () => _onKeyPress('e'),
                                                ),
                                              CalculatorButton(
                                                text: '00',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('00'),
                                              ),
                                              CalculatorButton(
                                                text: '0',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('0'),
                                              ),
                                              CalculatorButton(
                                                text: '.',
                                                textColor: white,
                                                bgColor: surfaceColor,
                                                fontSize: 25,
                                                onTap: () => _onKeyPress('.'),
                                              ),
                                              CalculatorButton(
                                                text: '=',
                                                textColor: white,
                                                bgColor: orangeColor,
                                                fontSize: 30,
                                                onTap: () => _onKeyPress('='),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // 2. FIXED BANNER AD (Bilkul niche fix rahega)
            Container(
              width: double.infinity,
              height: 50,
              color: Colors.white,
              alignment: Alignment.center,
              child: const Text(
                'Test Banner Ad (320x50)',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ActionButton(
                icon: Icons.menu,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {},
              ),
              const SizedBox(width: 8),
              ActionButton(
                icon: Icons.picture_in_picture_alt,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {},
              ),
            ],
          ),
          Row(
            children: [
              ActionButton(
                text: 'Σ',
                contentColor: isScientific ? const Color(0xFF003640) : textGrey,
                bgColor: isScientific ? cyanColor : surfaceColor.withOpacity(0.5),
                boxShadow: isScientific ? [BoxShadow(color: cyanColor.withOpacity(0.5), blurRadius: 15)] : [],
                onTap: () {
                  setState(() {
                    isScientific = !isScientific;
                    isHistoryOpen = false;
                  });
                },
              ),
              const SizedBox(width: 8),
              ActionButton(
                icon: Icons.history,
                // Agar open hai toh cyan color dikhega, warna grey
                contentColor: isHistoryOpen ? cyanColor : textGrey,
                bgColor: isHistoryOpen ? cyanColor.withOpacity(0.1) : surfaceColor.withOpacity(0.5),
                onTap: () {
                  setState(() {
                    isHistoryOpen = !isHistoryOpen; // NAYA: History Toggle Logic
                  });
                },
              ),
              const SizedBox(width: 8),
              ActionButton(
                icon: Icons.more_vert,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
