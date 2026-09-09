import 'package:flutter/material.dart';

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
  // Colors based on your design
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color orangeColor = const Color(0xFFFF9500);
  final Color redColor = const Color(0xFFFFB4AB);
  final Color textGrey = const Color(0xFFDBC2AD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildDisplayArea(),
            _buildScientificPanel(),
            _buildMainKeypad(),
            _buildAdBannerPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _iconButton(Icons.menu),
              const SizedBox(width: 8),
              _iconButton(Icons.picture_in_picture_alt),
            ],
          ),
          Row(
            children: [
              _iconButton(Icons.history),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: cyanColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cyanColor.withOpacity(0.5),
                      blurRadius: 15,
                    )
                  ],
                ),
                child: IconButton(
                  icon: const Text('Σ', style: TextStyle(color: Color(0xFF003640), fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              _iconButton(Icons.more_vert),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: textGrey, size: 20),
        onPressed: () {},
      ),
    );
  }

  Widget _buildDisplayArea() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('log(10.48528)', style: TextStyle(color: textGrey, fontSize: 18)),
                const SizedBox(width: 4),
                const Text('=', style: TextStyle(color: Color(0xFFFFDCBF), fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('1.02058', style: TextStyle(fontSize: 46, fontWeight: FontWeight.w300)),
                Container(
                  width: 3,
                  height: 40,
                  margin: const EdgeInsets.only(left: 4),
                  color: cyanColor, // Blinking cursor visual
                )
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.copy, size: 14, color: Colors.white70),
                label: const Text('COPY', style: TextStyle(fontSize: 12, color: Colors.white70)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: surfaceColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildScientificPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildRow(['log10', 'sin', 'cos', 'tan', 'ln', 'deg'], isSmall: true),
          const SizedBox(height: 8),
          _buildRow(['log2', 'x²', '(', ')', 'rad', 'Inv'], isSmall: true),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMainKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildRow(['x!', 'AC', '%', '⌫', '÷']),
          const SizedBox(height: 8),
          _buildRow(['xʸ', '7', '8', '9', '×']),
          const SizedBox(height: 8),
          _buildRow(['√x', '4', '5', '6', '−']),
          const SizedBox(height: 8),
          _buildRow(['π', '1', '2', '3', '+']),
          const SizedBox(height: 8),
          _buildRow(['e', '00', '0', '.', '=']),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> labels, {bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((label) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildButton(label, isSmall),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String text, bool isSmall) {
    Color btnColor = surfaceColor;
    Color textColor = Colors.white;
    FontWeight weight = FontWeight.normal;

    // Logic for button colors
    if (['÷', '×', '−', '+', '='].contains(text)) {
      btnColor = text == '=' ? orangeColor : const Color(0xFFFF9500).withOpacity(0.2);
      textColor = text == '=' ? const Color(0xFF4B2800) : orangeColor;
      weight = FontWeight.bold;
    } else if (text == 'AC') {
      textColor = redColor;
      weight = FontWeight.bold;
    } else if (['%', '⌫'].contains(text)) {
      textColor = cyanColor;
    } else if (['log10', 'deg', 'x!', 'π', 'e'].contains(text)) {
      textColor = cyanColor;
    }

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(isSmall ? 10 : 16),
      child: Container(
        height: isSmall ? 40 : 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(isSmall ? 10 : 16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: text == '⌫'
            ? Icon(Icons.backspace_outlined, color: cyanColor, size: 20)
            : Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: isSmall ? 12 : 18,
            fontWeight: weight,
          ),
        ),
      ),
    );
  }

  Widget _buildAdBannerPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF131926),
      child: Row(
        children: [
          const Icon(Icons.cloud_done, color: Color(0xFF4CD7F6)),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CloudVault Pro', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('2TB Secure Cloud Backup · 50% Off', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeColor,
              foregroundColor: Colors.black,
              minimumSize: const Size(60, 25),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () {},
            child: const Text('INSTALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}