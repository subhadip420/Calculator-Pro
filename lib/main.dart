import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'calculator_button.dart';
import 'action_button.dart';

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

  // --- Main Evaluation Logic ---
  // String _calculateResult(String eq) {
  //   if (eq.isEmpty) return '';
  //   try {
  //     // 1. UI symbols ko standard math symbols mein convert karna
  //     String sanitized = eq.replaceAll('×', '*').replaceAll('÷', '/');
  //
  //     // 2. Numbers aur operators ko alag-alag list mein todna
  //     List<String> tokens = [];
  //     String currentNum = '';
  //
  //     for (int i = 0; i < sanitized.length; i++) {
  //       String char = sanitized[i];
  //       if (['+', '-', '*', '/', '%'].contains(char)) {
  //         // Negative numbers handle karna (e.g., shuru mein -5)
  //         if (char == '-' &&
  //             currentNum.isEmpty &&
  //             (tokens.isEmpty || ['+', '-', '*', '/', '%'].contains(tokens.last))) {
  //           currentNum += char;
  //         } else {
  //           if (currentNum.isNotEmpty) {
  //             tokens.add(currentNum);
  //             currentNum = '';
  //           }
  //           tokens.add(char);
  //         }
  //       } else {
  //         currentNum += char;
  //       }
  //     }
  //     if (currentNum.isNotEmpty) {
  //       tokens.add(currentNum);
  //     }
  //
  //     // 3. BODMAS Rule (Pehle Multiply, Divide, Modulo)
  //     for (int i = 0; i < tokens.length; i++) {
  //       if (tokens[i] == '*' || tokens[i] == '/' || tokens[i] == '%') {
  //         double a = double.parse(tokens[i - 1]);
  //         double b = double.parse(tokens[i + 1]);
  //         double res = 0;
  //
  //         if (tokens[i] == '*')
  //           res = _multiply(a, b);
  //         else if (tokens[i] == '/')
  //           res = _divide(a, b);
  //         else if (tokens[i] == '%')
  //           res = _modulo(a, b);
  //
  //         tokens[i - 1] = res.toString();
  //         tokens.removeAt(i);
  //         tokens.removeAt(i);
  //         i--;
  //       }
  //     }
  //
  //     // 4. BODMAS Rule (Fir Add, Subtract)
  //     for (int i = 0; i < tokens.length; i++) {
  //       if (tokens[i] == '+' || tokens[i] == '-') {
  //         double a = double.parse(tokens[i - 1]);
  //         double b = double.parse(tokens[i + 1]);
  //         double res = 0;
  //
  //         if (tokens[i] == '+')
  //           res = _add(a, b);
  //         else if (tokens[i] == '-')
  //           res = _subtract(a, b);
  //
  //         tokens[i - 1] = res.toString();
  //         tokens.removeAt(i);
  //         tokens.removeAt(i);
  //         i--;
  //       }
  //     }
  //
  //     // 5. Final output format (Remove decimal if it's a whole number)
  //     if (tokens.length == 1) {
  //       double finalRes = double.parse(tokens[0]);
  //       if (finalRes == finalRes.toInt()) {
  //         return finalRes.toInt().toString();
  //       }
  //       // Trim extra zeros for decimals
  //       return finalRes.toStringAsFixed(6).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  //     }
  //     return '';
  //   } catch (e) {
  //     // Agar formula abhi incomplete hai (jaise "5+"), to purana result hi dikhao
  //     return result;
  //   }
  // }
  //
  // void _onKeyPress(String key) {
  //   if (!_focusNode.hasFocus) {
  //     FocusScope.of(context).requestFocus(_focusNode);
  //   }
  //
  //   setState(() {
  //     int cursorPos = _equationController.selection.baseOffset;
  //     if (cursorPos < 0) cursorPos = _equationController.text.length;
  //
  //     bool isOperator = ['+', '-', '×', '÷', '%'].contains(key);
  //
  //     // Spaces hata diye, ab input pehle jaisa normal hoga
  //     String inputKey = key;
  //
  //     if (key == 'AC') {
  //       _equationController.clear();
  //       result = '';
  //       isEvaluated = false;
  //     } else if (key == 'BACK') {
  //       if (_equationController.text.isNotEmpty && cursorPos > 0) {
  //         String text = _equationController.text;
  //
  //         // Backspace bhi normal 1 character delete karega
  //         String newText = text.substring(0, cursorPos - 1) + text.substring(cursorPos);
  //         _equationController.value = TextEditingValue(
  //           text: newText,
  //           selection: TextSelection.collapsed(offset: cursorPos - 1),
  //         );
  //         isEvaluated = false;
  //         result = _calculateResult(_equationController.text);
  //       }
  //     } else if (key == '=') {
  //       if (_equationController.text.isNotEmpty) {
  //         String finalResult = _calculateResult(_equationController.text);
  //         if (finalResult.isNotEmpty) {
  //           result = finalResult;
  //           isEvaluated = true;
  //         }
  //       }
  //     } else {
  //       if (isEvaluated) {
  //         if (isOperator) {
  //           _equationController.text = result + inputKey;
  //           _equationController.selection = TextSelection.collapsed(offset: _equationController.text.length);
  //         } else {
  //           _equationController.text = inputKey;
  //           _equationController.selection = TextSelection.collapsed(offset: inputKey.length);
  //         }
  //         isEvaluated = false;
  //       } else {
  //         // ---- Duplicate / Replace Operator Logic (Bina space ke) ----
  //         String before = _equationController.text.substring(0, cursorPos);
  //         String after = _equationController.text.substring(cursorPos);
  //
  //         if (isOperator && before.isNotEmpty) {
  //           String lastChar = before[before.length - 1];
  //
  //           // Agar last character operator hai
  //           if (['+', '-', '×', '÷', '%'].contains(lastChar)) {
  //             if (lastChar == key) {
  //               // Same operator hai toh kuch mat karo (Ignore)
  //               return;
  //             } else {
  //               // Alag operator hai toh replace kar do
  //               String newBefore = before.substring(0, before.length - 1) + inputKey;
  //               _equationController.value = TextEditingValue(
  //                 text: newBefore + after,
  //                 selection: TextSelection.collapsed(offset: newBefore.length),
  //               );
  //               result = _calculateResult(_equationController.text);
  //               return;
  //             }
  //           }
  //         }
  //         // -------------------------------------------------------------
  //
  //         // Normal Insertion
  //         String newText = before + inputKey + after;
  //         _equationController.value = TextEditingValue(
  //           text: newText,
  //           selection: TextSelection.collapsed(offset: before.length + inputKey.length),
  //         );
  //       }
  //       result = _calculateResult(_equationController.text);
  //     }
  //   });

  //   // Auto-Scroll Logic
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (_scrollController.hasClients &&
  //         _equationController.selection.baseOffset == _equationController.text.length) {
  //       _scrollController.animateTo(
  //         _scrollController.position.maxScrollExtent,
  //         duration: const Duration(milliseconds: 100),
  //         curve: Curves.easeOut,
  //       );
  //     }
  //   });
  // }

  // --- Perfect Scientific Evaluation Logic ---
  String _calculateResult(String eq) {
    if (eq.isEmpty) return '';
    try {
      // 1. UI symbols ko math_expressions format mein map karna
      String sanitized = eq
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', '3.141592653589793')
          .replaceAll('e', '2.718281828459045')
          .replaceAll('√(', 'sqrt(')
          .replaceAll('²', '^2');

      // math_expressions natively 'ln' support karta hai.
      // log10 aur log2 ko hum ln ke through convert kar rahe hain for perfect accuracy.
      sanitized = sanitized
          .replaceAll('log10(', '(1/2.302585092994046)*ln(')
          .replaceAll('log2(', '(1/0.6931471805599453)*ln(');

      // 2. Degree vs Radian Logic
      // math_expressions by default radians use karta hai. Agar mode Degree hai,
      // toh hum sin/cos/tan ke aandar (pi/180) multiply kar dete hain.
      if (isDegreeMode) {
        sanitized = sanitized
            .replaceAll('sin(', 'sin(0.017453292519943295*')
            .replaceAll('cos(', 'cos(0.017453292519943295*')
            .replaceAll('tan(', 'tan(0.017453292519943295*');
      }

      // 3. Auto-close Brackets (Real-time preview ke liye bohot zaroori)
      // Agar user ne "sin(30" type kiya hai, to code automatic ")" add kar dega error se bachne ke liye
      int openParens = sanitized.split('(').length - 1;
      int closeParens = sanitized.split(')').length - 1;
      for (int i = 0; i < (openParens - closeParens); i++) {
        sanitized += ')';
      }

      // 4. Parser Magic (Equation ko mathematically solve karna)
      Parser p = Parser();
      Expression exp = p.parse(sanitized);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // 5. Final Output Formatting
      if (eval.isNaN || eval.isInfinite) return 'Error';

      // Decimal ke baad extra zeros hatane ke liye
      if (eval == eval.toInt()) {
        return eval.toInt().toString();
      }
      return eval.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');

    } catch (e) {
      // Agar formula incomplete hai, toh purana result hi dikhao
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
          String finalResult = _calculateResult(_equationController.text);
          if (finalResult.isNotEmpty && finalResult != 'Error') {
            result = finalResult;
            isEvaluated = true;
          }
        }
      } else {
        if (isEvaluated) {
          if (isOperator) {
            _equationController.text = result + inputKey;
            _equationController.selection = TextSelection.collapsed(offset: _equationController.text.length);
          } else {
            _equationController.text = inputKey;
            _equationController.selection = TextSelection.collapsed(offset: inputKey.length);
          }
          isEvaluated = false;
        } else {
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
      if (_scrollController.hasClients &&
          _equationController.selection.baseOffset == _equationController.text.length) {
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
      if (len <= 8) return 46.0;   // Pehle 8 numbers tak sabse BADA size
      if (len <= 13) return 36.0;  // 8 se 13 numbers ke beech thoda chota
      return 28.0;                 // 13 ke baad minimum size aur scroll shuru
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        // 1. MASTER ANIMATION: Pura layout smoothly shift hoga
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(
            // Scientific mode par flex 200, normal mode par 300
            end: isScientific ? 200.0 : 300.0,
          ),
          builder: (context, topFlex, child) {
            return Column(
              children: [
                // Top Bar
                _buildTopBar(),

                // Flexible and Dynamic Edit Text Section
                Expanded(
                  // 2. SMOOTH FLEX: 300 se 200 smoothly shift hoga
                  flex: topFlex.toInt(),
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
                                            // FIX: Comment hata kar maxLines zaroor add karein
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
                                            onTap: () {
                                              FocusScope.of(context).requestFocus(_focusNode);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    // if (isEvaluated && _equationController.text.isNotEmpty) ...[
                                    //   const SizedBox(width: 4),
                                    //   const Text(
                                    //     '=',
                                    //     style: TextStyle(color: Color(0xFFFFDCBF), fontSize: 22, fontWeight: FontWeight.bold),
                                    //   ),
                                    // ]
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
                                    end: isEvaluated ? (isScientific ? 46.0 : 64.0) : (isScientific ? 24.0 : 32.0),
                                  ),
                                  builder: (context, animatedResultSize, child) {
                                    return Text(
                                      result,
                                      style: TextStyle(
                                        fontSize: animatedResultSize,
                                        fontWeight: isEvaluated ? FontWeight.w300 : FontWeight.normal,
                                        color: isEvaluated ? Colors.white : Colors.white.withOpacity(0.8),
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

                // Responsive Keypad Area
                Expanded(
                  // 3. KEYPAD SMOOTH FLEX: 700 - topFlex (matlab 400 se 500 shift hoga)
                  flex: 700 - topFlex.toInt(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      children: [
                        if (isScientific) ...[
                          Expanded(
                            child: Row(
                              children: [
                                CalculatorButton(text: 'log10', textColor: white, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress('log10(')),
                                CalculatorButton(text: 'sin', textColor: white, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress('sin(')),
                                CalculatorButton(text: 'cos', textColor: white, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress('cos(')),
                                CalculatorButton(text: 'tan', textColor: white, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress('tan(')),
                                CalculatorButton(text: 'ln', textColor: white, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress('ln(')),
                                CalculatorButton(text: 'deg', textColor: cyanColor, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress('deg')),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                CalculatorButton(text: 'log2', textColor: white, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress('log2(')),
                                CalculatorButton(text: 'x²', textColor: white, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress('²')),
                                CalculatorButton(text: '(', textColor: white, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress('(')),
                                CalculatorButton(text: ')', textColor: white, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress(')')),
                                CalculatorButton(text: 'rad', textColor: white, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress('rad')),
                                CalculatorButton(text: 'Inv', textColor: white, bgColor: surfaceColor, fontSize: 14, onTap: () => _onKeyPress('Inv')),
                              ],
                            ),
                          ),
                        ],
                        Expanded(
                          child: Row(
                            children: [
                              if (isScientific) CalculatorButton(text: 'x!', textColor: white, bgColor: surfaceColor, onTap: () => _onKeyPress('!')),
                              CalculatorButton(text: 'AC', textColor: Colors.orangeAccent, bgColor: surfaceColor, onTap: () => _onKeyPress('AC')),
                              CalculatorButton(text: '%', textColor: cyanColor, bgColor: surfaceColor, onTap: () => _onKeyPress('%')),
                              CalculatorButton(icon: Icons.backspace_outlined, textColor: cyanColor, bgColor: surfaceColor, onTap: () => _onKeyPress('BACK')),
                              CalculatorButton(text: '÷', textColor: white, bgColor: orangeColor.withOpacity(0.15), fontSize: 30, onTap: () => _onKeyPress('÷')),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              if (isScientific) CalculatorButton(text: 'xʸ', textColor: white, bgColor: surfaceColor, onTap: () => _onKeyPress('^')),
                              CalculatorButton(text: '7', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('7')),
                              CalculatorButton(text: '8', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('8')),
                              CalculatorButton(text: '9', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('9')),
                              CalculatorButton(text: '×', textColor: white, bgColor: orangeColor.withOpacity(0.15), fontSize: 30, onTap: () => _onKeyPress('×')),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              if (isScientific) CalculatorButton(text: '√x', textColor: white, bgColor: surfaceColor, onTap: () => _onKeyPress('√(')),
                              CalculatorButton(text: '4', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('4')),
                              CalculatorButton(text: '5', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('5')),
                              CalculatorButton(text: '6', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('6')),
                              CalculatorButton(text: '−', textColor: white, bgColor: orangeColor.withOpacity(0.15), fontSize: 30, onTap: () => _onKeyPress('-')),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              if (isScientific) CalculatorButton(text: 'π', textColor: white, bgColor: surfaceColor, onTap: () => _onKeyPress('π')),
                              CalculatorButton(text: '1', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('1')),
                              CalculatorButton(text: '2', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('2')),
                              CalculatorButton(text: '3', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('3')),
                              CalculatorButton(text: '+', textColor: white, bgColor: orangeColor.withOpacity(0.15), fontSize: 30, onTap: () => _onKeyPress('+')),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              if (isScientific) CalculatorButton(text: 'e', textColor: white, bgColor: surfaceColor, onTap: () => _onKeyPress('e')),
                              CalculatorButton(text: '00', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('00')),
                              CalculatorButton(text: '0', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('0')),
                              CalculatorButton(text: '.', textColor: white, bgColor: surfaceColor, fontSize: 25, onTap: () => _onKeyPress('.')),
                              CalculatorButton(text: '=', textColor: white, bgColor: orangeColor, fontSize: 30, onTap: () => _onKeyPress('=')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Test Banner Ad
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
            );
          },
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
                icon: Icons.history,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {},
              ),
              const SizedBox(width: 8),
              ActionButton(
                text: 'Σ',
                contentColor: isScientific ? const Color(0xFF003640) : textGrey,
                bgColor: isScientific ? cyanColor : surfaceColor.withOpacity(0.5),
                boxShadow: isScientific ? [BoxShadow(color: cyanColor.withOpacity(0.5), blurRadius: 15)] : [],
                onTap: () {
                  setState(() {
                    isScientific = !isScientific;
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
