import 'package:flutter/material.dart';
import 'calculator_button.dart';
import 'action_button.dart'; // Naya reusable button file import kiya

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
  bool isScientific = true;

  // Theme Colors
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color orangeColor = const Color(0xFFFF9500);
  final Color redColor = const Color(0xFFFFB4AB);
  final Color textGrey = const Color(0xFFDBC2AD);
  final Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar Design using Reusable ActionButton
            _buildTopBar(),

            // 2. Edit Text Section wrapped in Card View
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('log(10.48528)', style: TextStyle(color: textGrey, fontSize: 18)),
                            const SizedBox(width: 4),
                            const Text(
                              '=',
                              style: TextStyle(color: Color(0xFFFFDCBF), fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('1.02058', style: TextStyle(fontSize: 46, fontWeight: FontWeight.w300)),
                              Container(width: 3, height: 40, margin: const EdgeInsets.only(left: 4), color: cyanColor),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 10),
                        // Align(
                        //   alignment: Alignment.centerLeft,
                        //   child: OutlinedButton.icon(
                        //     onPressed: () {},
                        //     icon: const Icon(Icons.copy, size: 14, color: Colors.white70),
                        //     label: const Text('COPY', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        //     style: OutlinedButton.styleFrom(
                        //       backgroundColor: surfaceColor.withOpacity(0.5),
                        //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        //       side: BorderSide(color: Colors.white.withOpacity(0.1)),
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Responsive Keypad Area
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  children: [
                    if (isScientific) ...[
                      Expanded(
                        child: Row(
                          children: [
                            //CalculatorButton(text: 'log10', textColor: cyanColor, bgColor: surfaceColor, onTap: () {}),
                            CalculatorButton(
                              text: 'log10',
                              textColor: cyanColor,
                              bgColor: surfaceColor,
                              fontSize: 14,
                              // Custom text size
                              onTap: () {},
                            ),
                            CalculatorButton(
                              text: 'sin',
                              textColor: white,
                              bgColor: surfaceColor,
                              fontSize: 14,
                              onTap: () {},
                            ),
                            CalculatorButton(
                              text: 'cos',
                              textColor: white,
                              bgColor: surfaceColor,
                              fontSize: 14,
                              onTap: () {},
                            ),
                            CalculatorButton(
                              text: 'tan',
                              textColor: white,
                              bgColor: surfaceColor,
                              fontSize: 14,
                              onTap: () {},
                            ),
                            CalculatorButton(
                              text: 'ln',
                              textColor: white,
                              bgColor: surfaceColor,
                              fontSize: 14,
                              onTap: () {},
                            ),
                            CalculatorButton(
                              text: 'deg',
                              textColor: cyanColor,
                              bgColor: surfaceColor,
                              fontSize: 14,
                              onTap: () {},
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
                              fontSize: 14,
                              onTap: () {},
                            ),
                            CalculatorButton(
                              text: 'x²',
                              textColor: white,
                              bgColor: surfaceColor,
                              fontSize: 14,
                              onTap: () {},
                            ),
                            CalculatorButton(
                              text: '(',
                              textColor: white,
                              bgColor: surfaceColor,
                              fontSize: 14,
                              onTap: () {},
                            ),
                            CalculatorButton(
                              text: ')',
                              textColor: white,
                              bgColor: surfaceColor,
                              fontSize: 14,
                              onTap: () {},
                            ),
                            CalculatorButton(
                              text: 'rad',
                              textColor: white,
                              bgColor: surfaceColor,
                              fontSize: 14,
                              onTap: () {},
                            ),
                            CalculatorButton(
                              text: 'Inv',
                              textColor: white,
                              bgColor: surfaceColor,
                              fontSize: 14,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                    Expanded(
                      child: Row(
                        children: [
                          if (isScientific)
                            CalculatorButton(text: 'x!', textColor: cyanColor, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(
                            text: 'AC',
                            textColor: redColor,
                            bgColor: surfaceColor.withOpacity(0.8),
                            onTap: () {},
                          ),
                          CalculatorButton(text: '%', textColor: cyanColor, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(
                            icon: Icons.backspace_outlined,
                            textColor: cyanColor,
                            bgColor: surfaceColor,
                            onTap: () {},
                          ),
                          CalculatorButton(
                            text: '÷',
                            textColor: white,
                            bgColor: orangeColor.withOpacity(0.15),
                            fontSize: 30,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          if (isScientific)
                            CalculatorButton(text: 'xʸ', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '7', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '8', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '9', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(
                            text: '×',
                            textColor: white,
                            bgColor: orangeColor.withOpacity(0.15),
                            fontSize: 30,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          if (isScientific)
                            CalculatorButton(text: '√x', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '4', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '5', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '6', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(
                            text: '−',
                            textColor: white,
                            bgColor: orangeColor.withOpacity(0.15),
                            fontSize: 30,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          if (isScientific)
                            CalculatorButton(text: 'π', textColor: cyanColor, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '1', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '2', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '3', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(
                            text: '+',
                            textColor: white,
                            bgColor: orangeColor.withOpacity(0.15),
                            fontSize: 30,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          if (isScientific)
                            CalculatorButton(text: 'e', textColor: cyanColor, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '00', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '0', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(text: '.', textColor: white, bgColor: surfaceColor, onTap: () {}),
                          CalculatorButton(
                            text: '=',
                            textColor: white,
                            bgColor: orangeColor,
                            fontSize: 30,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Test Banner Ad
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

  // Top bar ui function inside main file
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
