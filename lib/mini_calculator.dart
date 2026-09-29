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

  // Colors (Main app se match karne ke liye)
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color orangeColor = const Color(0xFFFF9500);

  @override
  void initState() {
    super.initState();
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

  void _onPress(String text) {
    //HapticFeedback.lightImpact();
    //const MethodChannel('x-slayer/overlay').invokeMethod('haptic');
    setState(() {
      bool isOperator = ['+', '-', '×', '÷', '%'].contains(text);

      if (text == 'AC') {
        _equationController.clear();
        result = "0";
        isEvaluated = false; // Reset state
      } else if (text == 'BACK') {
        if (_equationController.text.isNotEmpty && !isEvaluated) {
          _equationController.text = _equationController.text.substring(0, _equationController.text.length - 1);
        }
      } else if (text == '=') {
        if (_equationController.text.isNotEmpty && !isEvaluated) {
          isEvaluated = true; // State change

          if (result != "0" && result != "Expression error") {
            _saveToHistory(_equationController.text, result);
          }
        }
      } else {
        if (isEvaluated) {
          if (isOperator) {
            _equationController.text = result + text;
          } else {

            _equationController.text = text;
          }
          isEvaluated = false;
        } else {
          _equationController.text += text;
        }
      }
      if (text != '=' && text != 'AC' && _equationController.text.isNotEmpty) {
        try {
          String sanitized = _equationController.text.replaceAll('×', '*').replaceAll('÷', '/');
          Parser p = Parser();
          Expression exp = p.parse(sanitized);
          double eval = exp.evaluate(EvaluationType.REAL, ContextModel());
          result = eval == eval.toInt()
              ? eval.toInt().toString()
              : eval.toStringAsFixed(6).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
        } catch (e) {
          // Ignore
        }
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
                      //HapticFeedback.selectionClick();
                      //const MethodChannel('x-slayer/overlay').invokeMethod('haptic');
                      // 1. Live Data Bhejo
                      Map<String, dynamic> data = {
                        'type': 'sync_to_main',
                        'eq': _equationController.text,
                        'res': result,
                        'eval': isEvaluated
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

                  const Icon(Icons.drag_handle_rounded, color: Colors.white38, size: 20),

                  // CLOSE BUTTON
                  GestureDetector(
                    onTap: () async {
                      //HapticFeedback.selectionClick();
                      //const MethodChannel('x-slayer/overlay').invokeMethod('haptic');
                      // 1. Live Data Bhejo
                      Map<String, dynamic> data = {
                        'type': 'sync_to_main',
                        'eq': _equationController.text,
                        'res': result,
                        'eval': isEvaluated
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
                    FlutterOverlayWindow.resizeOverlay(215, 335, false).catchError((e){});
                  },
                  onPointerUp: (_) {
                    FlutterOverlayWindow.resizeOverlay(215, 335, true).catchError((e){});
                  },
                  onPointerCancel: (_) {
                    FlutterOverlayWindow.resizeOverlay(215, 335, true).catchError((e){});
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
                                    color: isEvaluated ? Colors.white60 : Colors.white,
                                    fontSize: isEvaluated ? 14 : 18,
                                    fontWeight: isEvaluated ? FontWeight.normal : FontWeight.w500
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
                                color: isEvaluated ? Colors.white : Colors.white60,
                                fontSize: isEvaluated ? 28 : 20,
                                fontWeight: FontWeight.bold
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
                          _buildRow(['AC', '%','BACK', '÷']),
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
                  splashColor: txtColor.withOpacity(0.2), // Dark mode ke liye premium splash
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Container(
                    alignment: Alignment.center, // Center mein laane ke liye
                    // Yahan se decoration hata diya taaki ripple hide na ho
                    child: text == 'BACK'
                        ? Icon(Icons.backspace_outlined, color: txtColor, size: 18)
                        : Text(text, style: TextStyle(color: txtColor, fontSize: 18, fontWeight: FontWeight.bold)),
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