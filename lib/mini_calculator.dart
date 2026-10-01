import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MiniFloatingCalculator extends StatefulWidget {
  const MiniFloatingCalculator({super.key});

  @override
  State<MiniFloatingCalculator> createState() => _MiniFloatingCalculatorState();
}

class _MiniFloatingCalculatorState extends State<MiniFloatingCalculator> {
  final TextEditingController _equationController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String result = "0";
  bool isEvaluated = false;

  String _currentTheme = 'dark';

  bool get isDark => _currentTheme == 'dark';

  Color get bgColor => isDark ? const Color(0xFF0E131D) : const Color(0xFFF5F6FA);

  Color get surfaceColor => isDark ? const Color(0xFF1E2638) : const Color(0xFFFFFFFF);

  Color get cyanColor => const Color(0xFF4CD7F6);

  Color get orangeColor => const Color(0xFFFF9500);

  Color get textColor => isDark ? Colors.white : Colors.black87;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is String) {
        try {
          final data = jsonDecode(event);
          if (data['type'] == 'sync_to_mini') {
            setState(() {
              String newEq = data['eq'] ?? '';
              _equationController.value = TextEditingValue(
                text: newEq,
                selection: TextSelection.collapsed(offset: newEq.length),
              );
              result = data['res'] ?? '0';
              if (result.isEmpty) result = '0';
              isEvaluated = data['eval'] ?? false;
            });
          }
        } catch (e) {
          debugPrint("Mini sync error: $e");
        }
      }
    });

    FlutterOverlayWindow.shareData('request_data');
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Ensure fresh data from main app
    setState(() {
      _currentTheme = prefs.getString('app_theme') ?? 'dark';
    });
  }

  @override
  void dispose() {
    _equationController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveSyncState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sync_eq', _equationController.text);
    await prefs.setString('sync_res', result);
    await prefs.setBool('sync_eval', isEvaluated);
    await prefs.setBool('has_sync_data', true);
  }

  Future<void> _saveToHistory(String eq, String res) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('calculator_history') ?? [];

    final now = DateTime.now();
    String formattedDate =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    Map<String, String> newEntry = {'equation': eq, 'result': res, 'datetime': formattedDate};
    history.insert(0, jsonEncode(newEntry));

    if (history.length > 50) history = history.sublist(0, 50);
    await prefs.setStringList('calculator_history', history);
  }

  String _calculateResult(String eq, {bool isFinalCall = false}) {
    if (eq.isEmpty) return '';

    if (isFinalCall) {
      eq = eq.replaceAll(RegExp(r'[\+\-×÷\^]+$'), '');
    }

    if (eq.startsWith('^') || eq.startsWith('!') || eq.startsWith('×') || eq.startsWith('÷') || eq.startsWith('%')) {
      return isFinalCall ? 'Expression error' : '';
    }

    try {
      String sanitized = eq;

      // Percentage calculation
      sanitized = sanitized.replaceAllMapped(
          RegExp(r'([0-9.]+)\%'),
              (Match m) => '(${m[1]}/100)'
      );
      sanitized = sanitized.replaceAll('%', '/100');

      sanitized = sanitized
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('√', 'sqrt(')
          .replaceAll('²', '^2');

      int openParens = sanitized.split('(').length - 1;
      int closeParens = sanitized.split(')').length - 1;
      for (int i = 0; i < (openParens - closeParens); i++) {
        sanitized += ')';
      }

      Parser p = Parser();
      Expression exp = p.parse(sanitized);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isNaN || eval.isInfinite) return 'Expression error';
      if (eval == -0.0) eval = 0.0;

      if (eval == eval.toInt()) {
        return eval.toInt().toString();
      }
      return eval.toStringAsFixed(6).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    } catch (e) {
      if (isFinalCall) return 'Expression error';
      return result;
    }
  }

  // void _onPress(String text) {
  //   setState(() {
  //     // 1. Cursor position nikalna (kahan par type ho raha hai)
  //     int cursorPos = _equationController.selection.baseOffset;
  //     if (cursorPos < 0) cursorPos = _equationController.text.length;
  //
  //     bool isOperator = ['+', '-', '×', '÷', '%'].contains(text);
  //
  //     if (text == 'AC') {
  //       _equationController.clear();
  //       result = "0";
  //       isEvaluated = false;
  //     } else if (text == 'BACK') {
  //       if (_equationController.text.isNotEmpty && cursorPos > 0) {
  //         // Cursor jahan hai, uske theek pehle wala number/operator delete karo
  //         String currentText = _equationController.text;
  //         String newText = currentText.substring(0, cursorPos - 1) + currentText.substring(cursorPos);
  //         _equationController.value = TextEditingValue(
  //           text: newText,
  //           selection: TextSelection.collapsed(offset: cursorPos - 1),
  //         );
  //         isEvaluated = false;
  //       }
  //     } else if (text == '=') {
  //       if (_equationController.text.isNotEmpty && !isEvaluated) {
  //         isEvaluated = true; // State change
  //         if (result != "0" && result != "Expression error") {
  //           _saveToHistory(_equationController.text, result);
  //         }
  //       }
  //     } else {
  //       if (isEvaluated) {
  //         if (isOperator) {
  //           if (result == 'Expression error') {
  //             _equationController.text = text;
  //             _equationController.selection = TextSelection.collapsed(offset: text.length);
  //           } else {
  //             _equationController.text = result + text;
  //             _equationController.selection = TextSelection.collapsed(offset: _equationController.text.length);
  //           }
  //         } else {
  //           _equationController.text = text;
  //           _equationController.selection = TextSelection.collapsed(offset: text.length);
  //         }
  //         isEvaluated = false;
  //       } else {
  //         // --- NAYA: MAIN APP WALA OPERATOR LOGIC ---
  //         String before = _equationController.text.substring(0, cursorPos);
  //         String after = _equationController.text.substring(cursorPos);
  //         bool replaced = false;
  //
  //         if (isOperator && before.isNotEmpty) {
  //           String lastChar = before[before.length - 1];
  //           if (['+', '-', '×', '÷', '%'].contains(lastChar)) {
  //             if (lastChar == text) {
  //               // Agar same operator 2 baar dabaya toh ignore karo
  //               return;
  //             } else {
  //               // Naya operator dabaya toh purane wale ko REPLACE kar do
  //               String newBefore = before.substring(0, before.length - 1) + text;
  //               _equationController.value = TextEditingValue(
  //                 text: newBefore + after,
  //                 selection: TextSelection.collapsed(offset: newBefore.length),
  //               );
  //               replaced = true;
  //             }
  //           }
  //         }
  //
  //         // Agar replace nahi hua toh normally text add kar do
  //         if (!replaced) {
  //           String newText = before + text + after;
  //           _equationController.value = TextEditingValue(
  //             text: newText,
  //             selection: TextSelection.collapsed(offset: before.length + text.length),
  //           );
  //         }
  //       }
  //     }
  //
  //     // Real-time calculation sirf typing ke time
  //     if (text != '=' && text != 'AC' && _equationController.text.isNotEmpty) {
  //       // Validation: Starting mein galat operator ho toh crash roke
  //       if (!(_equationController.text.startsWith('×') ||
  //           _equationController.text.startsWith('÷') ||
  //           _equationController.text.startsWith('%'))) {
  //         try {
  //           String sanitized = _equationController.text.replaceAll('×', '*').replaceAll('÷', '/');
  //           Parser p = Parser();
  //           Expression exp = p.parse(sanitized);
  //           double eval = exp.evaluate(EvaluationType.REAL, ContextModel());
  //           result = eval == eval.toInt()
  //               ? eval.toInt().toString()
  //               : eval.toStringAsFixed(6).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  //         } catch (e) {
  //           // Ignore error while typing
  //         }
  //       }
  //     } else if (_equationController.text.isEmpty) {
  //       result = "0";
  //     }
  //   });
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (_scrollController.hasClients) {
  //       _scrollController.animateTo(
  //         _scrollController.position.maxScrollExtent,
  //         duration: const Duration(milliseconds: 100),
  //         curve: Curves.easeOut,
  //       );
  //     }
  //   });
  // }

  void _onPress(String text) {
    setState(() {
      int cursorPos = _equationController.selection.baseOffset;
      if (cursorPos < 0) cursorPos = _equationController.text.length;

      bool isBasicOperator = ['+', '-', '×', '÷'].contains(text);
      String inputKey = text;

      if (text == 'AC') {
        _equationController.clear();
        result = "0";
        isEvaluated = false;
      } else if (text == 'BACK') {
        if (_equationController.text.isNotEmpty && cursorPos > 0) {
          String currentText = _equationController.text;
          String newText = currentText.substring(0, cursorPos - 1) + currentText.substring(cursorPos);
          _equationController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: cursorPos - 1),
          );
          isEvaluated = false;
        }
      } else if (text == '=') {
        if (_equationController.text.isNotEmpty) {
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
        // Double Decimal (.) Rokna
        if (text == '.') {
          String before = _equationController.text.substring(0, cursorPos);
          RegExp regex = RegExp(r'[0-9\.]+$');
          Match? match = regex.firstMatch(before);
          if (match != null && match.group(0)!.contains('.')) return;
        }

        if (isEvaluated) {
          if (isBasicOperator || text == '%') {
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
          String before = _equationController.text.substring(0, cursorPos);
          String after = _equationController.text.substring(cursorPos);

          // Operator Replacement Logic
          if (isBasicOperator && before.isNotEmpty) {
            String lastChar = before[before.length - 1];
            if (['+', '-', '×', '÷'].contains(lastChar)) {
              if (lastChar == text) {
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

      // Real-time calculation
      if (text != '=' && text != 'AC' && _equationController.text.isNotEmpty) {
        result = _calculateResult(_equationController.text);
      } else if (_equationController.text.isEmpty) {
        result = "0";
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 230,
        height: 380,
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: cyanColor.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          children: [
            // --- 1. TOP BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      // 1. Live Data Bhejo
                      Map<String, dynamic> data = {
                        'type': 'sync_to_main',
                        'eq': _equationController.text,
                        'res': result,
                        'eval': isEvaluated,
                      };
                      FlutterOverlayWindow.shareData(jsonEncode(data));
                      await _saveSyncState();

                      try {
                        final AndroidIntent intent = AndroidIntent(
                          action: 'action_main',
                          package: 'com.sptechstudios.calculator_pro',
                          componentName: 'com.sptechstudios.calculator_pro.MainActivity',
                          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                        );
                        intent.launch();
                      } catch (e) {
                        debugPrint("Error waking up app: $e");
                      }

                      Future.delayed(const Duration(milliseconds: 100), () {
                        FlutterOverlayWindow.closeOverlay();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                      child: Icon(Icons.open_in_full_rounded, color: cyanColor, size: 12),
                    ),
                  ),

                  Icon(Icons.drag_handle_rounded, color: isDark ? Colors.white38 : Colors.black38, size: 20),

                  // CLOSE BUTTON
                  GestureDetector(
                    onTap: () async {
                      // 1. Live Data Bhejo
                      Map<String, dynamic> data = {
                        'type': 'sync_to_main',
                        'eq': _equationController.text,
                        'res': result,
                        'eval': isEvaluated,
                      };
                      FlutterOverlayWindow.shareData(jsonEncode(data));
                      await _saveSyncState();

                      Future.delayed(const Duration(milliseconds: 100), () {
                        FlutterOverlayWindow.closeOverlay();
                      });
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

            // --- 2. DISPLAY & KEYPAD AREA ---
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Listener(
                      onPointerDown: (_) {
                        FlutterOverlayWindow.resizeOverlay(215, 335, false).catchError((e) {});
                      },
                      onPointerUp: (_) {
                        FlutterOverlayWindow.resizeOverlay(215, 335, true).catchError((e) {});
                      },
                      onPointerCancel: (_) {
                        FlutterOverlayWindow.resizeOverlay(215, 335, true).catchError((e) {});
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        color: bgColor.withOpacity(0.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: TextField(
                                  controller: _equationController,
                                  focusNode: _focusNode,
                                  scrollController: _scrollController,
                                  readOnly: true,
                                  showCursor: !isEvaluated,
                                  cursorColor: cyanColor,
                                  cursorWidth: 2,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    //color: isEvaluated ? Colors.white60 : Colors.white,
                                    color: isEvaluated ? textColor.withOpacity(0.6) : textColor,
                                    fontSize: isEvaluated ? 14 : 18,
                                    fontWeight: isEvaluated ? FontWeight.normal : FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              result,
                              maxLines: 1,
                              style: TextStyle(
                                //color: isEvaluated ? Colors.white : Colors.white60,
                                color: isEvaluated ? textColor : textColor.withOpacity(0.6),
                                fontSize: isEvaluated ? 28 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        children: [
                          _buildRow(['AC', '%', 'BACK', '÷']),
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
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((text) {
          Color txtColor = textColor;
          Color bgCol = surfaceColor;

          if (text == 'AC') {
            txtColor = orangeColor;
          } else if (text == 'BACK' || text == '%') {
            txtColor = cyanColor;
          } else if (['÷', '×', '-', '+', '='].contains(text)) {
            bgCol = orangeColor.withOpacity(0.5);
            if (text == '=') {
              bgCol = orangeColor;
              //bgCol = orangeColor.withOpacity(isDark ? 0.15 : 0.20);
              txtColor = textColor;
            }
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              // FIX: Yahan Material ko bahar kiya taaki animation proper dikhe,
              // theek waise hi jaise main calculator mein kiya tha.
              child: Material(
                color: bgCol,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias, // Ripple border ke bahar leak hone se rokne ke liye
                child: InkWell(
                  onTap: () => _onPress(text),
                  borderRadius: BorderRadius.circular(18),
                  splashColor: txtColor.withOpacity(0.2),
                  // Dark mode ke liye premium splash
                  //highlightColor: Colors.white.withOpacity(0.1),
                  highlightColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                  child: Container(
                    alignment: Alignment.center, // Center mein laane ke liye
                    // Yahan se decoration hata diya taaki ripple hide na ho
                    child: text == 'BACK'
                        ? Icon(Icons.backspace_outlined, color: txtColor, size: 18)
                        : Text(
                            text,
                            style: TextStyle(color: txtColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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
