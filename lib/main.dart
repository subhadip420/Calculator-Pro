import 'dart:convert';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:calculator_pro/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

//import 'package:math_expressions/math_expressions.dart';
import 'package:math_expressions/math_expressions.dart' hide Stack;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'calculator_button.dart';
import 'action_button.dart';
import 'custom_dialog.dart';
import 'menu_options.dart';

import 'package:flutter_overlay_window/flutter_overlay_window.dart'; // NAYA IMPORT

// --- NAYA: FLOATING WINDOW KA ENTRY POINT (Background Isolate) ---
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MiniFloatingCalculator(), // Iska code hum niche banayenge
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
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
  bool _isHapticsEnabled = true; // NAYA: Haptic check karne ke liye

  bool isHistoryOpen = false; // NAYA: History panel state
  List<String> _historyList = []; // NAYA: History data store karne ke liye

  bool _isDragging = false;
  double _dragOffset = 0.0;

  String equation = '';
  String result = '';

  final TextEditingController _equationController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // --- NAYE VARIABLES: Menu aur uske Dragging ke liye ---
  bool isMenuOpen = false;
  bool _isMenuDragging = false;
  double _menuDragOffset = 0.0;
  final double maxMenuWidth = 250.0;

  // --- NAYA: Mini Mode ke variables ---
  // bool isMiniMode = false;
  // double miniOffsetDx = 50.0;
  // double miniOffsetDy = 100.0;

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // Google Test Ad Unit ID (Android ke liye)
  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111'; //todo

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
    _loadAd();
    _loadHapticsSetting();

    // NAYA FIX: Floating window se message sunne ke liye Listener
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event == 'openApp') {
        // 1. Background se app ko wapas screen par lao (Kotlin command)
        const MethodChannel('com.sptechstudios/app').invokeMethod('openApp');

        // 2. App open hone ke baad floating window ko band kardo
        FlutterOverlayWindow.closeOverlay();
      }
    });

    // Screen open hote hi cursor show karne ke liye
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
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

  Future<void> _loadHapticsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true; // Default ON
    });
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner, // 320x50 size
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
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
    if (_isHapticsEnabled) {
      HapticFeedback.selectionClick(); // Halka sa premium vibration
    }

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
          primaryButtonBgColor: redColor,
          // App ka red theme color
          primaryButtonTextColor: bgColor,
          // Dark text for contrast
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

    // if (isMiniMode) {
    //   return _buildMiniCalculator();
    // }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HORIZONTAL SLIDER (Menu Side-by-Side Slide Hoga)
            // 1. HORIZONTAL SLIDER (Full Screen Menu Side-by-Side)
            Expanded(
              child: Builder(
                builder: (context) {
                  // NAYA: Phone ki exact width calculate kar rahe hain
                  double screenWidth = MediaQuery.of(context).size.width;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ----------------------------------------------------
                      // LEFT SIDE: MENU SCREEN (Ab Full Screen Hoga)
                      // ----------------------------------------------------
                      // ----------------------------------------------------
                      // LEFT SIDE: FULL SCREEN MENU
                      // ----------------------------------------------------
                      AnimatedPositioned(
                        duration: Duration(milliseconds: _isMenuDragging ? 0 : 350),
                        curve: Curves.easeOutCubic,
                        left: _isMenuDragging ? _menuDragOffset - screenWidth : (isMenuOpen ? 0 : -screenWidth),
                        width: screenWidth,
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          // --- NAYA: MENU PAR BHI REAL-TIME FINGER TRACKING ---
                          onHorizontalDragStart: (details) {
                            setState(() {
                              _isMenuDragging = true;
                              // Drag shuru hote hi current position pakad lega
                              _menuDragOffset = isMenuOpen ? screenWidth : 0.0;
                            });
                          },
                          onHorizontalDragUpdate: (details) {
                            setState(() {
                              _menuDragOffset += details.delta.dx;
                              // Screen se bahar na jaye isliye limits set ki hain
                              if (_menuDragOffset < 0) _menuDragOffset = 0;
                              if (_menuDragOffset > screenWidth) _menuDragOffset = screenWidth;
                            });
                          },
                          onHorizontalDragEnd: (details) {
                            setState(() {
                              _isMenuDragging = false;
                              // Speed mein swipe kiya toh direct open/close
                              if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
                                isMenuOpen = true;
                              } else if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
                                isMenuOpen = false;
                              } else {
                                // Aadhi screen swipe pe auto-snap
                                isMenuOpen = _menuDragOffset > (screenWidth / 2);
                              }
                              _menuDragOffset = isMenuOpen ? screenWidth : 0.0;
                            });
                          },
                          // ---------------------------------------------------
                          child: MenuOptions(
                            onClose: () {
                              setState(() {
                                isMenuOpen = false;
                                _menuDragOffset = 0.0;
                              });
                            },
                          ),
                        ),
                      ),

                      // ----------------------------------------------------
                      // RIGHT SIDE: MAIN CALCULATOR APP
                      // ----------------------------------------------------
                      AnimatedPositioned(
                        duration: Duration(milliseconds: _isMenuDragging ? 0 : 350),
                        curve: Curves.easeOutCubic,
                        left: _isMenuDragging ? _menuDragOffset : (isMenuOpen ? screenWidth : 0),
                        right: _isMenuDragging ? -_menuDragOffset : (isMenuOpen ? -screenWidth : 0),
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          // --- HORIZONTAL FINGER TRACKING ---
                          onHorizontalDragStart: (details) {
                            setState(() {
                              _isMenuDragging = true;
                              _menuDragOffset = isMenuOpen ? screenWidth : 0.0;
                            });
                          },
                          onHorizontalDragUpdate: (details) {
                            setState(() {
                              _menuDragOffset += details.delta.dx;
                              if (_menuDragOffset < 0) _menuDragOffset = 0;
                              if (_menuDragOffset > screenWidth) _menuDragOffset = screenWidth;
                            });
                          },
                          onHorizontalDragEnd: (details) {
                            setState(() {
                              _isMenuDragging = false;
                              if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
                                isMenuOpen = true;
                              } else if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
                                isMenuOpen = false;
                              } else {
                                isMenuOpen = _menuDragOffset > (screenWidth / 2);
                              }
                              _menuDragOffset = isMenuOpen ? screenWidth : 0.0;
                            });
                          },
                          // ---------------------------------------------
                          child: Container(
                            color: bgColor, // Background color taki piche ka menu chhip sake
                            // --- AAPKA PURANA LAYOUT BUILDER (Jisme History Vertical Slide hoti hai) ---
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(end: isScientific ? 200.0 : 300.0),
                                  builder: (context, topFlex, child) {
                                    double totalFlex = 700.0;
                                    double keypadFlex = totalFlex - topFlex;
                                    double keypadHeight = constraints.maxHeight * (keypadFlex / totalFlex);

                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // VERTICAL BACKGROUND: HISTORY PANEL
                                        AnimatedOpacity(
                                          duration: Duration(milliseconds: _isDragging ? 0 : 300),
                                          opacity: _isDragging
                                              ? (_dragOffset / keypadHeight).clamp(0.0, 1.0)
                                              : (isHistoryOpen ? 1.0 : 0.0),
                                          child: Builder(
                                            builder: (context) {
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
                                                if (datePart == todayStr)
                                                  displayDate = 'Today';
                                                else if (datePart == yesterdayStr)
                                                  displayDate = 'Yesterday';

                                                if (!groupedHistory.containsKey(displayDate))
                                                  groupedHistory[displayDate] = [];
                                                groupedHistory[displayDate]!.add(item);
                                              }

                                              return Container(
                                                height: keypadHeight,
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(10.0),
                                                child: Card(
                                                  color: surfaceColor.withOpacity(0.3),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(24),
                                                    side: BorderSide(color: Colors.white.withOpacity(0.05)),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                          left: 8.0,
                                                          right: 8.0,
                                                          top: 4.0,
                                                          bottom: 2.0,
                                                        ),
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
                                                                  onPressed: () =>
                                                                      setState(() => isHistoryOpen = false),
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
                                                              onPressed: _showClearHistoryDialog,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: _historyList.isEmpty
                                                            ? Center(
                                                                child: Text(
                                                                  'No History yet',
                                                                  style: TextStyle(color: textGrey, fontSize: 16),
                                                                ),
                                                              )
                                                            : ListView(
                                                                padding: const EdgeInsets.symmetric(
                                                                  horizontal: 16,
                                                                  vertical: 0,
                                                                ),
                                                                children: groupedHistory.entries.map((entry) {
                                                                  return Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
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
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      ...entry.value.map((item) {
                                                                        String fullDateTime = item['datetime'] ?? '';
                                                                        String timePart = fullDateTime.contains(' ')
                                                                            ? fullDateTime.split(' ')[1]
                                                                            : '';
                                                                        return Container(
                                                                          width: double.infinity,
                                                                          margin: const EdgeInsets.only(bottom: 12),
                                                                          padding: const EdgeInsets.symmetric(
                                                                            horizontal: 12,
                                                                            vertical: 5,
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            color: bgColor.withOpacity(0.5),
                                                                            borderRadius: BorderRadius.circular(16),
                                                                          ),
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                                            children: [
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
                                                                              Text(
                                                                                item['equation'] ?? '',
                                                                                style: TextStyle(
                                                                                  color: textGrey,
                                                                                  fontSize: 16,
                                                                                ),
                                                                              ),
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
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 10.0, top: 8.0),
                                                        child: Text(
                                                          'Swipe for options',
                                                          style: TextStyle(
                                                            color: textGrey.withOpacity(0.4),
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // VERTICAL FOREGROUND: CALCULATOR (Slides Down)
                                        AnimatedPositioned(
                                          duration: Duration(milliseconds: _isDragging ? 0 : 350),
                                          curve: Curves.easeOutCubic,
                                          top: _isDragging ? _dragOffset : (isHistoryOpen ? keypadHeight : 0),
                                          bottom: _isDragging ? -_dragOffset : (isHistoryOpen ? -keypadHeight : 0),
                                          left: 0,
                                          right: 0,
                                          child: Column(
                                            children: [
                                              _buildTopBar(),
                                              Expanded(
                                                flex: topFlex.toInt(),
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onVerticalDragStart: (details) {
                                                    setState(() {
                                                      _isDragging = true;
                                                      _dragOffset = isHistoryOpen ? keypadHeight : 0.0;
                                                    });
                                                  },
                                                  onVerticalDragUpdate: (details) {
                                                    setState(() {
                                                      _dragOffset += details.delta.dy;
                                                      if (_dragOffset < 0) _dragOffset = 0;
                                                      if (_dragOffset > keypadHeight) _dragOffset = keypadHeight;
                                                    });
                                                  },
                                                  onVerticalDragEnd: (details) {
                                                    setState(() {
                                                      _isDragging = false;
                                                      if (details.primaryVelocity != null &&
                                                          details.primaryVelocity! > 300)
                                                        isHistoryOpen = true;
                                                      else if (details.primaryVelocity != null &&
                                                          details.primaryVelocity! < -300)
                                                        isHistoryOpen = false;
                                                      else
                                                        isHistoryOpen = _dragOffset > (keypadHeight / 2);
                                                    });
                                                  },
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
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 20.0,
                                                          vertical: 16.0,
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
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
                                                                        tween: Tween<double>(
                                                                          end: _getDynamicFontSize(),
                                                                        ),
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
                                                                            style: TextStyle(
                                                                              color: white,
                                                                              fontSize: animatedSize,
                                                                            ),
                                                                            decoration: const InputDecoration(
                                                                              border: InputBorder.none,
                                                                              isDense: true,
                                                                              contentPadding: EdgeInsets.zero,
                                                                            ),
                                                                            onTap: () => FocusScope.of(
                                                                              context,
                                                                            ).requestFocus(_focusNode),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
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
                                                                        fontWeight: isEvaluated
                                                                            ? FontWeight.w300
                                                                            : FontWeight.normal,
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

                                              // KEYPAD AREA
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
                        ),
                      ),
                    ],
                  ); // NAYA: Stack ka return yahan close hoga
                }, // NAYA: Builder ka function yahan close hoga
              ), // Builder close
            ), // Expanded close

            _isLoaded && _bannerAd != null
                ? Container(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    alignment: Alignment.center,
                    child: AdWidget(ad: _bannerAd!),
                  )
                : const SizedBox(
                    width: double.infinity,
                    height: 50, // Jab tak ad load na ho, khali space
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
                contentColor: isMenuOpen ? cyanColor : textGrey,
                bgColor: isMenuOpen ? cyanColor.withOpacity(0.1) : surfaceColor.withOpacity(0.5),
                onTap: () {
                  if (_isHapticsEnabled) {
                    HapticFeedback.lightImpact(); // Halka sa premium vibration
                  }
                  setState(() {
                    isMenuOpen = !isMenuOpen;
                    // NAYA: Pura screen width lega
                    _menuDragOffset = isMenuOpen ? MediaQuery.of(context).size.width : 0.0;
                  });
                },
              ),
              const SizedBox(width: 8),
              // ActionButton(
              //   icon: Icons.picture_in_picture_alt,
              //   contentColor: textGrey,
              //   bgColor: surfaceColor.withOpacity(0.5),
              //   // onTap: () {
              //   //   if (_isHapticsEnabled) {
              //   //     HapticFeedback.lightImpact(); // Halka sa premium vibration
              //   //   }
              //   // },
              // ),
              ActionButton(
                icon: Icons.picture_in_picture_alt,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () async {
                  if (_isHapticsEnabled) HapticFeedback.lightImpact();

                  try {
                    bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
                    if (!isGranted) {
                      await FlutterOverlayWindow.requestPermission();
                      return;
                    }

                    if (await FlutterOverlayWindow.isActive()) {
                      await FlutterOverlayWindow.closeOverlay();
                      await Future.delayed(const Duration(milliseconds: 300));
                    }

                    // Window show karo (Fixed Pixel Size diya taaki bada na ho)
                    await FlutterOverlayWindow.showOverlay(
                      enableDrag: true,
                      overlayTitle: "Calculator Pro",
                      overlayContent: "Floating Calculator",
                      flag: OverlayFlag.defaultFlag,
                      visibility: NotificationVisibility.visibilityPublic,
                      positionGravity: PositionGravity.auto,
                      width: 550,  // NAYA FIX: Mobile ke hisab se pixel size
                      height: 850, // NAYA FIX: Mobile ke hisab se pixel size
                    );

                    Future.delayed(const Duration(milliseconds: 100), () {
                      try {
                        const MethodChannel('com.sptechstudios/app').invokeMethod('minimizeApp');
                      } catch (e) {
                        debugPrint("Minimize error: $e");
                      }
                    });

                  } catch (e) {
                    debugPrint("Overlay open error: $e");
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              ActionButton(
                // text: 'Σ',
                icon: Icons.functions_rounded,
                contentColor: isScientific ? const Color(0xFF003640) : textGrey,
                bgColor: isScientific ? cyanColor : surfaceColor.withOpacity(0.5),
                boxShadow: isScientific ? [BoxShadow(color: cyanColor.withOpacity(0.5), blurRadius: 15)] : [],
                onTap: () {
                  if (_isHapticsEnabled) {
                    HapticFeedback.lightImpact(); // Halka sa premium vibration
                  }
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
                  if (_isHapticsEnabled) {
                    HapticFeedback.lightImpact(); // Halka sa premium vibration
                  }
                  setState(() {
                    isHistoryOpen = !isHistoryOpen; // NAYA: History Toggle Logic
                  });
                },
              ),
              const SizedBox(width: 8),
              ActionButton(
                icon: Icons.settings_outlined,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {
                  if (_isHapticsEnabled) {
                    HapticFeedback.lightImpact(); // Halka sa premium vibration
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- NAYA: Floating Mini Calculator UI ---
  // Widget _buildMiniCalculator() {
  //   return Scaffold(
  //     backgroundColor: bgColor, // Pura background dark rahega
  //     body: SafeArea(
  //       child: Stack(
  //         children: [
  //           Positioned(
  //             left: miniOffsetDx,
  //             top: miniOffsetDy,
  //             child: GestureDetector(
  //               // Floating window ko screen par drag karne ka logic
  //               onPanUpdate: (details) {
  //                 setState(() {
  //                   miniOffsetDx += details.delta.dx;
  //                   miniOffsetDy += details.delta.dy;
  //                 });
  //               },
  //               child: Container(
  //                 width: 260, // Mini width
  //                 height: 420, // Mini height
  //                 decoration: BoxDecoration(
  //                   color: surfaceColor,
  //                   borderRadius: BorderRadius.circular(24),
  //                   border: Border.all(color: cyanColor.withOpacity(0.4), width: 1.5),
  //                   boxShadow: [
  //                     BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
  //                   ],
  //                 ),
  //                 child: Column(
  //                   children: [
  //                     // --- TOP BAR (Expand Button & Drag Handle) ---
  //                     Container(
  //                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //                       decoration: BoxDecoration(
  //                         color: surfaceColor,
  //                         borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
  //                       ),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           // Expand Button (Wapas full screen aane ke liye)
  //                           InkWell(
  //                             onTap: () {
  //                               if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                               setState(() => isMiniMode = false); // Wapas normal app
  //                             },
  //                             child: Container(
  //                               padding: const EdgeInsets.all(6),
  //                               decoration: BoxDecoration(
  //                                 color: bgColor,
  //                                 shape: BoxShape.circle,
  //                               ),
  //                               child: Icon(Icons.open_in_full_rounded, color: cyanColor, size: 16),
  //                             ),
  //                           ),
  //                           // Drag Indicator
  //                           Icon(Icons.drag_handle_rounded, color: textGrey.withOpacity(0.4), size: 20),
  //                           const SizedBox(width: 28), // Balance karne ke liye
  //                         ],
  //                       ),
  //                     ),
  //
  //                     // --- DISPLAY SCREEN ---
  //                     Container(
  //                       width: double.infinity,
  //                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //                       color: bgColor.withOpacity(0.5),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.end,
  //                         children: [
  //                           Text(
  //                             _equationController.text.isEmpty ? '0' : _equationController.text,
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                             style: TextStyle(color: textGrey.withOpacity(0.8), fontSize: 16),
  //                           ),
  //                           const SizedBox(height: 4),
  //                           Text(
  //                             result.isEmpty ? '0' : result,
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                             style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //
  //                     const Divider(height: 1, color: Colors.white10),
  //
  //                     // --- BASIC KEYPAD ---
  //                     Expanded(
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Column(
  //                           children: [
  //                             Expanded(child: Row(children: [
  //                               CalculatorButton(text: 'AC', textColor: orangeColor, bgColor: surfaceColor, fontSize: 16, onTap: ()=>_onKeyPress('AC')),
  //                               CalculatorButton(icon: Icons.backspace_outlined, textColor: cyanColor, bgColor: surfaceColor, onTap: ()=>_onKeyPress('BACK')),
  //                               CalculatorButton(text: '%', textColor: cyanColor, bgColor: surfaceColor, fontSize: 18, onTap: ()=>_onKeyPress('%')),
  //                               CalculatorButton(text: '÷', textColor: Colors.white, bgColor: orangeColor.withOpacity(0.2), fontSize: 22, onTap: ()=>_onKeyPress('÷')),
  //                             ])),
  //                             Expanded(child: Row(children: [
  //                               CalculatorButton(text: '7', textColor: Colors.white, bgColor: surfaceColor, fontSize: 18, onTap: ()=>_onKeyPress('7')),
  //                               CalculatorButton(text: '8', textColor: Colors.white, bgColor: surfaceColor, fontSize: 18, onTap: ()=>_onKeyPress('8')),
  //                               CalculatorButton(text: '9', textColor: Colors.white, bgColor: surfaceColor, fontSize: 18, onTap: ()=>_onKeyPress('9')),
  //                               CalculatorButton(text: '×', textColor: Colors.white, bgColor: orangeColor.withOpacity(0.2), fontSize: 22, onTap: ()=>_onKeyPress('×')),
  //                             ])),
  //                             Expanded(child: Row(children: [
  //                               CalculatorButton(text: '4', textColor: Colors.white, bgColor: surfaceColor, fontSize: 18, onTap: ()=>_onKeyPress('4')),
  //                               CalculatorButton(text: '5', textColor: Colors.white, bgColor: surfaceColor, fontSize: 18, onTap: ()=>_onKeyPress('5')),
  //                               CalculatorButton(text: '6', textColor: Colors.white, bgColor: surfaceColor, fontSize: 18, onTap: ()=>_onKeyPress('6')),
  //                               CalculatorButton(text: '−', textColor: Colors.white, bgColor: orangeColor.withOpacity(0.2), fontSize: 24, onTap: ()=>_onKeyPress('-')),
  //                             ])),
  //                             Expanded(child: Row(children: [
  //                               CalculatorButton(text: '1', textColor: Colors.white, bgColor: surfaceColor, fontSize: 18, onTap: ()=>_onKeyPress('1')),
  //                               CalculatorButton(text: '2', textColor: Colors.white, bgColor: surfaceColor, fontSize: 18, onTap: ()=>_onKeyPress('2')),
  //                               CalculatorButton(text: '3', textColor: Colors.white, bgColor: surfaceColor, fontSize: 18, onTap: ()=>_onKeyPress('3')),
  //                               CalculatorButton(text: '+', textColor: Colors.white, bgColor: orangeColor.withOpacity(0.2), fontSize: 22, onTap: ()=>_onKeyPress('+')),
  //                             ])),
  //                             Expanded(child: Row(children: [
  //                               CalculatorButton(text: '00', textColor: Colors.white, bgColor: surfaceColor, fontSize: 16, onTap: ()=>_onKeyPress('00')),
  //                               CalculatorButton(text: '0', textColor: Colors.white, bgColor: surfaceColor, fontSize: 18, onTap: ()=>_onKeyPress('0')),
  //                               CalculatorButton(text: '.', textColor: Colors.white, bgColor: surfaceColor, fontSize: 20, onTap: ()=>_onKeyPress('.')),
  //                               CalculatorButton(text: '=', textColor: Colors.white, bgColor: orangeColor, fontSize: 22, onTap: ()=>_onKeyPress('=')),
  //                             ])),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}// End CalculatorScreenState class

// --- FLOATING WINDOW UI ---
class MiniFloatingCalculator extends StatefulWidget {
  const MiniFloatingCalculator({super.key});

  @override
  State<MiniFloatingCalculator> createState() => _MiniFloatingCalculatorState();
}

class _MiniFloatingCalculatorState extends State<MiniFloatingCalculator> {
  String equation = "";
  String result = "0";

  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color orangeColor = const Color(0xFFFF9500);

  void _onPress(String text) {
    HapticFeedback.selectionClick();
    setState(() {
      if (text == 'AC') {
        equation = "";
        result = "0";
      } else if (text == 'BACK') {
        if (equation.isNotEmpty) {
          equation = equation.substring(0, equation.length - 1);
        }
      } else if (text == '=') {
        try {
          String sanitized = equation.replaceAll('×', '*').replaceAll('÷', '/');
          Parser p = Parser();
          Expression exp = p.parse(sanitized);
          double eval = exp.evaluate(EvaluationType.REAL, ContextModel());
          result = eval == eval.toInt() ? eval.toInt().toString() : eval.toStringAsFixed(6).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
        } catch (e) {
          result = "Error";
        }
      } else {
        equation += text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,  // Native window (550px) ke hisab se auto-fit hoga
        height: double.infinity,
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cyanColor.withOpacity(0.5), width: 1.5),
          // boxShadow: [
          //   BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
          // ],
        ),
        child: Column(
          children: [
            // --- TOP BAR (Expand Button, Title & Close Button) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. EXPAND BUTTON (Full App Open Karega)
                  // 1. EXPAND BUTTON (Full App Open Karega)
                  InkWell(
                    onTap: () async {
                      HapticFeedback.selectionClick();

                      try {
                        // NAYA FIX: Android Native Intent se soye hue App ko force wake up karna
                        final AndroidIntent intent = AndroidIntent(
                          action: 'action_main',
                          package: 'com.sptechstudios.calculator_pro',
                          componentName: 'com.sptechstudios.calculator_pro.MainActivity',
                          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK], // Background se kholne ki permission
                        );
                        await intent.launch();
                      } catch (e) {
                        debugPrint("Error waking up app: $e");
                      }

                      // App screen par aate hi floating window band kardo
                      FlutterOverlayWindow.closeOverlay();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                      child: Icon(Icons.open_in_full_rounded, color: cyanColor, size: 12),
                    ),
                  ),

                  // 2. TITLE
                  const Text('Calc Pro', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),

                  // 3. CLOSE 'X' BUTTON (Sirf Window Band Karega)
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      FlutterOverlayWindow.closeOverlay();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 12),
                    ),
                  ),
                ],
              ),
            ),

            // --- DISPLAY ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: bgColor.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(equation.isEmpty ? ' ' : equation, maxLines: 1, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(result, maxLines: 1, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // --- KEYPAD ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    _buildRow(['AC', 'BACK', '%', '÷']),
                    _buildRow(['7', '8', '9', '×']),
                    _buildRow(['4', '5', '6', '-']),
                    _buildRow(['1', '2', '3', '+']),
                    _buildRow(['00', '0', '.', '=']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((text) {
          Color txtColor = Colors.white;
          Color bgCol = surfaceColor;

          if (text == 'AC') {
            txtColor = orangeColor;
          } else if (text == 'BACK' || text == '%') {
            txtColor = cyanColor;
          } else if (['÷', '×', '-', '+', '='].contains(text)) {
            bgCol = orangeColor.withOpacity(0.2);
            if (text == '=') {
              bgCol = orangeColor;
              txtColor = Colors.white;
            }
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: InkWell(
                onTap: () => _onPress(text),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(color: bgCol, borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: text == 'BACK'
                        ? Icon(Icons.backspace_outlined, color: txtColor, size: 16)
                        : Text(text, style: TextStyle(color: txtColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}