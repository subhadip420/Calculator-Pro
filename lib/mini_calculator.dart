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
  // FIX 2: Text control, Scroll aur Cursor ke liye controllers add kiye
  final TextEditingController _equationController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String result = "0";
  bool isEvaluated = false;

  @override
  void dispose() {
    _equationController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Colors (Main app se match karne ke liye)

  // Colors (Main app se match karne ke liye)
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color orangeColor = const Color(0xFFFF9500);

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
    HapticFeedback.lightImpact();

    setState(() {
      bool isOperator = ['+', '-', '×', '÷', '%'].contains(text);

      if (text == 'AC') {
        _equationController.clear();
        result = "0";
        isEvaluated = false; // Reset state
      } else if (text == 'BACK') {
        if (_equationController.text.isNotEmpty && !isEvaluated) { // Agar evaluate ho chuka hai toh back kaam nai karega
          _equationController.text = _equationController.text.substring(0, _equationController.text.length - 1);
        }
      } else if (text == '=') {
        if (_equationController.text.isNotEmpty && !isEvaluated) {
          isEvaluated = true; // State change

          // Agar final result nikal aaya hai toh usko History me save kar lo
          if (result != "0" && result != "Expression error") {
            _saveToHistory(_equationController.text, result);
          }
        }
      } else {
        // NAYA LOGIC: Agar pehle se Evaluated tha (Answer bada dikh raha tha)
        if (isEvaluated) {
          if (isOperator) {
            // Operator dabaya to answer ke aage lagega
            _equationController.text = result + text;
          } else {
            // Naya number dabaya to purana clear ho jayega
            _equationController.text = text;
          }
          isEvaluated = false; // Wapas normal typing mode me aao
        } else {
          _equationController.text += text;
        }
      }

      // Real-time calculation sirf typing ke time (Equal dabane ke time nai)
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
      // FIX 2: Yahan se Align() hata diya gaya hai!
      // Ab ye seedha Container se shuru hoga, jisse bahar 1% bhi extra space nahi gherega.
      child: Container(
        width: 230,  // Exact UI Width
        height: 380, // Exact UI Height
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: cyanColor.withOpacity(0.5), width: 1.5),
          // boxShadow: [
          //   // NAYA: Shadow add ki hai taaki window background se alag dikhe
          //   BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)
          // ],
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
                  // EXPAND BUTTON
                  InkWell(
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      try {
                        final AndroidIntent intent = AndroidIntent(
                          action: 'action_main',
                          package: 'com.sptechstudios.calculator_pro',
                          componentName: 'com.sptechstudios.calculator_pro.MainActivity',
                          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                        );
                        await intent.launch();
                      } catch (e) {
                        debugPrint("Error waking up app: $e");
                      }
                      FlutterOverlayWindow.closeOverlay();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                      child: Icon(Icons.open_in_full_rounded, color: cyanColor, size: 12),
                    ),
                  ),

                  const Icon(Icons.drag_handle_rounded, color: Colors.white38, size: 20),

                  // CLOSE BUTTON
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

            // --- 2. DISPLAY & KEYPAD AREA ---
            Expanded(
              child: Column(
                children: [
                  // FIX 1 & 2: DISPLAY AREA (Height badhai flex: 3 aur Scrollable+Cursor banaya)
                  Expanded(
                    flex: 2,
                child: Listener(
                  // FIX: Display touch karte hi window drag OFF (Taaki text scroll ho sake)
                  onPointerDown: (_) {
                    FlutterOverlayWindow.resizeOverlay(215, 335, false).catchError((e){});
                  },
                  // FIX: Ungli hatate hi window drag wapas ON
                  onPointerUp: (_) {
                    FlutterOverlayWindow.resizeOverlay(215, 335, true).catchError((e){});
                  },
                  // FIX: Agar drag karte hue ungli display se bahar chali jaye toh bhi wapas ON
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
                                showCursor: !isEvaluated, // NAYA: Evaluated hone pe cursor hide ho jayega
                                cursorColor: cyanColor,
                                cursorWidth: 2,
                                textAlign: TextAlign.right,
                                // NAYA: Jab evaluate ho jaye to chota aur halka ho jaye
                                style: TextStyle(
                                    color: isEvaluated ? Colors.white38 : Colors.white54,
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
                            // NAYA: Jab evaluate ho jaye to bada aur bright ho jaye
                            style: TextStyle(
                                color: isEvaluated ? cyanColor : Colors.white,
                                fontSize: isEvaluated ? 28 : 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          // const SizedBox(height: 2),
                          // Text(
                          //   result,
                          //   maxLines: 1,
                          //   style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          // ),
                        ],
                      ),
                    ),
                ),
                  ),

                  // FIX 1: KEYPAD AREA (Height adjust ki flex: 5 aur padding kam ki)
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0), // Padding bilkul kam kardi
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
              child: InkWell(
                onTap: () => _onPress(text),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  decoration: BoxDecoration(color: bgCol, borderRadius: BorderRadius.circular(18)),
                  child: Center(
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