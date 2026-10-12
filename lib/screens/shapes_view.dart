import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';

// --- CUSTOM PAINTERS FOR SHAPES (Bina image asset ke draw karne ke liye) ---
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RightTrianglePainter extends CustomPainter {
  final Color color;

  RightTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrapezoidPainter extends CustomPainter {
  final Color color;

  TrapezoidPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    Path path = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.8, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RhombusPainter extends CustomPainter {
  final Color color;

  RhombusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PentagonPainter extends CustomPainter {
  final Color color;

  PentagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height * 0.4)
      ..lineTo(size.width * 0.8, size.height)
      ..lineTo(size.width * 0.2, size.height)
      ..lineTo(0, size.height * 0.4)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HexagonPainter extends CustomPainter {
  final Color color;

  HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    Path path = Path()
      ..moveTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.75, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width * 0.75, size.height)
      ..lineTo(size.width * 0.25, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CircleArcPainter extends CustomPainter {
  final Color color;

  CircleArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..arcToPoint(const Offset(0, 0), radius: Radius.circular(size.width), clockwise: false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EllipsePainter extends CustomPainter {
  final Color color;

  EllipsePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawOval(Rect.fromLTWH(0, size.height * 0.25, size.width, size.height * 0.5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data Model for Shapes
class ShapeItem {
  final String name;
  final Widget iconBuilder;

  ShapeItem(this.name, this.iconBuilder);
}

class ShapesView extends StatefulWidget {
  final VoidCallback onBack;

  const ShapesView({super.key, required this.onBack});

  @override
  State<ShapesView> createState() => _ShapesViewState();
}

class _ShapesViewState extends State<ShapesView> {
  bool _isHapticsEnabled = true;
  int _selectedShapeIndex = 0; // Default selection: Triangle

  late List<ShapeItem> _shapeList;

  final TextEditingController _triACtrl = TextEditingController(text: '');
  final TextEditingController _triBCtrl = TextEditingController(text: '');
  final TextEditingController _triCCtrl = TextEditingController(text: '');

  // --- Right Triangle Input State ---
  String _rtType1 = 'Side A'; // Default selection 1
  String _rtType2 = 'Side B'; // Default selection 2
  final TextEditingController _rtVal1Ctrl = TextEditingController(text: '');
  final TextEditingController _rtVal2Ctrl = TextEditingController(text: '');

  String _sqType = 'Side'; // Default selection
  final TextEditingController _sqValCtrl = TextEditingController(text: '');

  // --- Rectangle Input State ---
  final TextEditingController _rectLenCtrl = TextEditingController(text: '');
  final TextEditingController _rectWidCtrl = TextEditingController(text: '');

  // --- Trapezoid Input State ---
  final TextEditingController _trapHeightCtrl = TextEditingController(text: '');
  final TextEditingController _trapTopCtrl = TextEditingController(text: '');
  final TextEditingController _trapBaseCtrl = TextEditingController(text: '');

  final TextEditingController _rhomLenCtrl = TextEditingController(text: '');
  final TextEditingController _rhomWidCtrl = TextEditingController(text: '');

  @override
  void dispose() {
    // NAYA: Controllers ko dispose zaroor karein memory leak rokne ke liye
    _triACtrl.dispose();
    _triBCtrl.dispose();
    _triCCtrl.dispose();
    // NAYA: Right Triangle wale controllers dispose karein
    _rtVal1Ctrl.dispose();
    _rtVal2Ctrl.dispose();
    // NAYA: Square controller dispose karein
    _sqValCtrl.dispose();
    // NAYA: Rectangle controllers dispose karein
    _rectLenCtrl.dispose();
    _rectWidCtrl.dispose();
    // NAYA: Trapezoid controllers dispose karein
    _trapHeightCtrl.dispose();
    _trapTopCtrl.dispose();
    _trapBaseCtrl.dispose();
    // NAYA: Rhombus controllers dispose karein
    _rhomLenCtrl.dispose();
    _rhomWidCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Context is available here for colors
    _initializeShapeList();
  }

  void _initializeShapeList() {
    Color iconColor = AppColors.cyanColor(context); // Using your theme color for shape outlines
    double s = 32.0; // Standard icon size

    _shapeList = [
      ShapeItem(
        'Triangle',
        CustomPaint(
          size: Size(s, s),
          painter: TrianglePainter(color: iconColor),
        ),
      ),
      //[cite: 2]
      ShapeItem(
        'Right triangle',
        CustomPaint(
          size: Size(s, s),
          painter: RightTrianglePainter(color: iconColor),
        ),
      ),
      //[cite: 2]
      ShapeItem(
        'Square',
        Container(
          width: s,
          height: s,
          decoration: BoxDecoration(border: Border.all(color: iconColor, width: 2.5)),
        ),
      ),
      //[cite: 2]
      ShapeItem(
        'Rectangle',
        Container(
          width: s + 10,
          height: s - 10,
          decoration: BoxDecoration(border: Border.all(color: iconColor, width: 2.5)),
        ),
      ),
      //[cite: 2]
      ShapeItem(
        'Trapezoid',
        CustomPaint(
          size: Size(s, s),
          painter: TrapezoidPainter(color: iconColor),
        ),
      ),
      //[cite: 2]
      ShapeItem(
        'Rhombus',
        CustomPaint(
          size: Size(s, s),
          painter: RhombusPainter(color: iconColor),
        ),
      ),
      //[cite: 2]
      ShapeItem(
        'Pentagon',
        CustomPaint(
          size: Size(s, s),
          painter: PentagonPainter(color: iconColor),
        ),
      ),
      //[cite: 2]
      ShapeItem(
        'Hexagon',
        CustomPaint(
          size: Size(s, s),
          painter: HexagonPainter(color: iconColor),
        ),
      ),
      //[cite: 2]
      ShapeItem(
        'Circle',
        Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: iconColor, width: 2.5),
          ),
        ),
      ),
      //[cite: 2]
      ShapeItem(
        'Circle arc',
        CustomPaint(
          size: Size(s, s),
          painter: CircleArcPainter(color: iconColor),
        ),
      ),
      //[cite: 2]
      ShapeItem(
        'Ellipse',
        CustomPaint(
          size: Size(s + 10, s),
          painter: EllipsePainter(color: iconColor),
        ),
      ),
      //[cite: 2]
    ];
  }

  String _getShapeHintMessage(String shapeName) {
    switch (shapeName) {
      case 'Triangle':
        return 'Solve a triangle knowing its sides.';
      case 'Right triangle':
        return 'Solve a rectangle knowing its two dimensions.';
      case 'Square':
        return 'Solve a square knowing its one dimension.';
      case 'Rectangle':
        return 'Solve a rectangle knowing its two dimensions.';
      case 'Circle':
        return 'Solve a circle knowing its radius.';
      case 'Trapezoid':
        return 'Solve a trapezoid knowing its bases and height.';
      case 'Rhombus':
        return 'Solve a rhombus knowing its diagonals.';
      default:
        // Agar koi case match nahi hota, toh ye default message dikhega
        return 'Solve a ${shapeName.toLowerCase()} knowing its parameters';
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
      });
    }
  }

  // --- SHOW BOTTOM SHEET GRID ---
  void _showShapeSelectorGrid() {
    if (_isHapticsEnabled) HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Background transparent rakha taki custom container dikhe
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75, // 75% of screen height
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.textGrey(context).withOpacity(0.3))),
          ),
          child: Column(
            children: [
              // Sheet Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.textGrey(context).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Text(
                'Select Shape',
                style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),

              // Grid View
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 columns as per screenshot
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.85, // Adjust for icon + 2 lines of text
                  ),
                  itemCount: _shapeList.length,
                  itemBuilder: (context, index) {
                    bool isSelected = index == _selectedShapeIndex;
                    ShapeItem item = _shapeList[index];

                    return GestureDetector(
                      onTap: () {
                        if (_isHapticsEnabled) HapticFeedback.selectionClick();
                        setState(() {
                          _selectedShapeIndex = index;
                        });
                        Navigator.pop(context); // Close sheet on selection
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.cyanColor(context).withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.cyanColor(context).withOpacity(0.5) : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 45,
                              child: Center(child: item.iconBuilder), // The Custom Painted Icon
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textColor(context),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Shapes', // Subtitle text as per screenshot[cite: 2]
                              style: TextStyle(color: AppColors.textGrey(context), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ShapeItem currentShape = _shapeList[_selectedShapeIndex];

    // NAYA: Triangle Logic
    double a = double.tryParse(_triACtrl.text) ?? 0;
    double b = double.tryParse(_triBCtrl.text) ?? 0;
    double c = double.tryParse(_triCCtrl.text) ?? 0;

    // Check if triangle is valid (Sum of two sides must be > third side)
    bool isValidTriangle = (a + b > c) && (a + c > b) && (b + c > a) && a > 0 && b > 0 && c > 0;

    double area = 0, perimeter = 0, hA = 0, hB = 0, hC = 0, angAB = 0, angBC = 0, angAC = 0;

    if (isValidTriangle && currentShape.name == 'Triangle') {
      perimeter = a + b + c;
      double s = perimeter / 2; // Semi-perimeter
      area = sqrt(s * (s - a) * (s - b) * (s - c)); // Heron's Formula

      hA = (2 * area) / a;
      hB = (2 * area) / b;
      hC = (2 * area) / c;

      // Law of Cosines for angles (Convert radian to degree)
      angAB = acos((a * a + b * b - c * c) / (2 * a * b)) * (180 / pi); // Angle between A and B (Angle C)
      angBC = acos((b * b + c * c - a * a) / (2 * b * c)) * (180 / pi); // Angle between B and C (Angle A)
      angAC = acos((a * a + c * c - b * b) / (2 * a * c)) * (180 / pi); // Angle between A and C (Angle B)
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          CustomTopBar(
            toolId: 'shapes',
            title: 'Shapes',
            iconPath: 'assets/images/percentage-discount-symbol.png',
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
                  // --- TITLE ---
                  Text(
                    'Select Shape',
                    style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // --- SELECTOR CARD ---
                  GestureDetector(
                    onTap: _showShapeSelectorGrid,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.textGrey(context).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          // Left side: Shape Image/Icon
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: currentShape.iconBuilder,
                          ),
                          const SizedBox(width: 16),

                          // Middle: Shape Name
                          Expanded(
                            child: Text(
                              currentShape.name,
                              style: TextStyle(
                                color: AppColors.textColor(context),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Right Side: Divider + Dropdown Icon
                          Container(height: 30, width: 1, color: AppColors.textGrey(context).withOpacity(0.4)),
                          const SizedBox(width: 12),
                          Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey(context), size: 28),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ==========================================
                  /// YAHAN SE TRIANGLE KA CODE ADD KAREIN
                  /// ==========================================
                  if (currentShape.name == 'Triangle') ...[
                    Text(
                      'Enter Dimensions',
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // Row(
                    //   children: [
                    //     _buildInputField('Side A', _triACtrl),
                    //     _buildInputField('Side B', _triBCtrl),
                    //     _buildInputField('Side C', _triCCtrl),
                    //   ],
                    // ),

                    // Column(
                    //   children: [
                    //     _buildTriInputRow('Side A', _triACtrl),
                    //     _buildTriInputRow('Side B', _triBCtrl),
                    //     _buildTriInputRow('Side C', _triCCtrl),
                    //   ],
                    // ),

                    // FIX: Naye dynamic function ke sath Triangle ke inputs call kiye
                    Column(
                      children: [
                        _buildFixedInputRow(
                          title: 'Side A',
                          ctrl: _triACtrl,
                          icon: CustomPaint(painter: TriInputPainter(highlightType: 'Side A', baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent)),
                        ),
                        _buildFixedInputRow(
                          title: 'Side B',
                          ctrl: _triBCtrl,
                          icon: CustomPaint(painter: TriInputPainter(highlightType: 'Side B', baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent)),
                        ),
                        _buildFixedInputRow(
                          title: 'Side C',
                          ctrl: _triCCtrl,
                          icon: CustomPaint(painter: TriInputPainter(highlightType: 'Side C', baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // --- NAYA: DYNAMIC INFO BANNER ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            // FIX: Ternary condition hata kar naya helper function laga diya
                            _getShapeHintMessage(currentShape.name),
                            style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- RESULTS SECTION ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cyanColor(context).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.3), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Calculation Result',
                              style: TextStyle(
                                color: AppColors.cyanColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                          const SizedBox(height: 12),

                          if (!isValidTriangle)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Invalid Triangle!\nSum of any two sides must be greater than the third side.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.redAccent.withOpacity(0.9), fontSize: 14),
                                ),
                              ),
                            )
                          else ...[
                            _buildResultRow('Area', area.toStringAsFixed(2), isHighlighted: true),
                            _buildResultRow('Perimeter', perimeter.toStringAsFixed(2)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                            ),
                            _buildResultRow('Angle: AB', '${angAB.toStringAsFixed(2)}°'),
                            _buildResultRow('Angle: BC', '${angBC.toStringAsFixed(2)}°'),
                            _buildResultRow('Angle: AC', '${angAC.toStringAsFixed(2)}°'),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                            ),
                            _buildResultRow('Height: A', hA.toStringAsFixed(2)),
                            _buildResultRow('Height: B', hB.toStringAsFixed(2)),
                            _buildResultRow('Height: C', hC.toStringAsFixed(2)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ]
                  /// ==========================================
                  /// YAHAN SE RIGHT TRIANGLE KA CODE ADD KAREIN
                  /// ==========================================
                  else if (currentShape.name == 'Right triangle') ...[
                    // Calculation Logic for Right Triangle
                    Builder(
                      builder: (context) {
                        double v1 = double.tryParse(_rtVal1Ctrl.text) ?? 0;
                        double v2 = double.tryParse(_rtVal2Ctrl.text) ?? 0;

                        double rtArea = 0, rtPerimeter = 0, rtA = 0, rtB = 0, rtC = 0, rtAngA = 0, rtAngB = 0;
                        bool isValid = false;
                        String errorMsg = '';

                        if (v1 > 0 && v2 > 0) {
                          if (_rtType1 == _rtType2) {
                            errorMsg = 'Please select two different dimensions.';
                          } else if ((_rtType1.contains('Angle') && _rtType2.contains('Angle'))) {
                            errorMsg = 'Cannot solve a triangle with only angles.';
                          } else {
                            double? a, b, c, angA, angB;

                            // FIX: Andar function hatakar direct assign kiya
                            if (_rtType1 == 'Side A') a = v1;
                            else if (_rtType1 == 'Side B') b = v1;
                            else if (_rtType1 == 'Hypotenuse') c = v1;
                            else if (_rtType1 == 'Angle A') angA = v1;
                            else if (_rtType1 == 'Angle B') angB = v1;

                            if (_rtType2 == 'Side A') a = v2;
                            else if (_rtType2 == 'Side B') b = v2;
                            else if (_rtType2 == 'Hypotenuse') c = v2;
                            else if (_rtType2 == 'Angle A') angA = v2;
                            else if (_rtType2 == 'Angle B') angB = v2;

                            try {
                              // Dart khud samajh gaya ki yahan value null nahi hai (Flow Analysis)
                              if (a != null && b != null) {
                                c = sqrt(a * a + b * b);
                                angA = atan(a / b) * 180 / pi;
                                angB = 90 - angA;
                              } else if (a != null && c != null) {
                                if (c <= a) throw Exception('Hypotenuse must be > Side A.');
                                b = sqrt(c * c - a * a);
                                angA = asin(a / c) * 180 / pi;
                                angB = 90 - angA;
                              } else if (b != null && c != null) {
                                if (c <= b) throw Exception('Hypotenuse must be > Side B.');
                                a = sqrt(c * c - b * b);
                                angA = acos(b / c) * 180 / pi;
                                angB = 90 - angA;
                              } else if (a != null && angA != null) {
                                if (angA >= 90) throw Exception('Angle must be < 90.');
                                b = a / tan(angA * pi / 180);
                                c = a / sin(angA * pi / 180);
                                angB = 90 - angA;
                              } else if (a != null && angB != null) {
                                if (angB >= 90) throw Exception('Angle must be < 90.');
                                b = a * tan(angB * pi / 180);
                                c = a / cos(angB * pi / 180);
                                angA = 90 - angB;
                              } else if (b != null && angA != null) {
                                if (angA >= 90) throw Exception('Angle must be < 90.');
                                a = b * tan(angA * pi / 180);
                                c = b / cos(angA * pi / 180);
                                angB = 90 - angA;
                              } else if (b != null && angB != null) {
                                if (angB >= 90) throw Exception('Angle must be < 90.');
                                a = b / tan(angB * pi / 180);
                                c = b / sin(angB * pi / 180);
                                angA = 90 - angB;
                              } else if (c != null && angA != null) {
                                if (angA >= 90) throw Exception('Angle must be < 90.');
                                a = c * sin(angA * pi / 180);
                                b = c * cos(angA * pi / 180);
                                angB = 90 - angA;
                              } else if (c != null && angB != null) {
                                if (angB >= 90) throw Exception('Angle must be < 90.');
                                a = c * cos(angB * pi / 180);
                                b = c * sin(angB * pi / 180);
                                angA = 90 - angB;
                              }

                              if (a != null && b != null && c != null && angA != null && angB != null && a > 0 && b > 0 && c > 0) {
                                rtA = a;
                                rtB = b;
                                rtC = c;
                                rtAngA = angA;
                                rtAngB = angB;
                                rtArea = 0.5 * a * b;
                                rtPerimeter = a + b + c;
                                isValid = true;
                              }
                            } catch (e) {
                              errorMsg = e.toString().replaceAll('Exception: ', '');
                            }
                          }
                        } else {
                          errorMsg = 'Enter values to calculate.';
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Input',
                              style: TextStyle(
                                color: AppColors.textColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildRtInputRow(1),
                            const SizedBox(height: 12),
                            _buildRtInputRow(2),
                            const SizedBox(height: 16),

                            // Dynamic Hint Banner
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  color: AppColors.textGrey(context),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _getShapeHintMessage(currentShape.name),
                                    style: TextStyle(
                                      color: AppColors.textColor(context).withOpacity(0.9),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Result Container
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cyanColor(context).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.3), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      'Calculation Result',
                                      style: TextStyle(
                                        color: AppColors.cyanColor(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                  const SizedBox(height: 12),

                                  if (!isValid)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          errorMsg,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.redAccent.withOpacity(0.9), fontSize: 14),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    _buildResultRow('Area', rtArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Perimeter', rtPerimeter.toStringAsFixed(2)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),
                                    _buildResultRow('Side A', rtA.toStringAsFixed(2)),
                                    _buildResultRow('Side B', rtB.toStringAsFixed(2)),
                                    _buildResultRow('Hypotenuse', rtC.toStringAsFixed(2)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),
                                    _buildResultRow('Angle A', '${rtAngA.toStringAsFixed(2)}°'),
                                    _buildResultRow('Angle B', '${rtAngB.toStringAsFixed(2)}°'),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),
                  ]
                  /// ==========================================
                  /// YAHAN SE SQUARE KA CODE ADD KAREIN
                  /// ==========================================
                  else if (currentShape.name == 'Square') ...[
                    Builder(
                      builder: (context) {
                        double val = double.tryParse(_sqValCtrl.text) ?? 0;
                        double sqSide = 0, sqArea = 0, sqPerimeter = 0, sqDiagonal = 0;
                        bool isValid = false;
                        String errorMsg = '';

                        if (val > 0) {
                          if (_sqType == 'Side') {
                            sqSide = val;
                            sqArea = val * val;
                            sqPerimeter = 4 * val;
                          } else if (_sqType == 'Area') {
                            sqArea = val;
                            sqSide = sqrt(val);
                            sqPerimeter = 4 * sqSide;
                          } else if (_sqType == 'Perimeter') {
                            sqPerimeter = val;
                            sqSide = val / 4;
                            sqArea = sqSide * sqSide;
                          }
                          sqDiagonal = sqSide * sqrt(2);
                          isValid = true;
                        } else {
                          errorMsg = 'Enter a value greater than 0.';
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Input', style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),

                            // Sirf 1 input field hogi Square ke liye
                            _buildSqInputRow(),
                            const SizedBox(height: 16),

                            // Dynamic Hint Banner
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                const SizedBox(width: 12),
                                Expanded(child: Text(_getShapeHintMessage(currentShape.name), style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15))),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Result Container
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: AppColors.cyanColor(context).withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.3), width: 1.5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(child: Text('Calculation Result', style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold))),
                                  const SizedBox(height: 12),
                                  Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                  const SizedBox(height: 12),

                                  if (!isValid)
                                    Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(errorMsg, textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent.withOpacity(0.9), fontSize: 14))))
                                  else ...[
                                    _buildResultRow('Area', sqArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Perimeter', sqPerimeter.toStringAsFixed(2)),
                                    Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1)),
                                    _buildResultRow('Side', sqSide.toStringAsFixed(2)),
                                    _buildResultRow('Diagonal', sqDiagonal.toStringAsFixed(2)),
                                  ]
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),
                  ]
                  /// ==========================================
                  /// YAHAN SE RECTANGLE KA CODE ADD KAREIN
                  /// ==========================================
                  else if (currentShape.name == 'Rectangle') ...[
                    Builder(
                      builder: (context) {
                        double l = double.tryParse(_rectLenCtrl.text) ?? 0;
                        double w = double.tryParse(_rectWidCtrl.text) ?? 0;

                        double rectArea = 0, rectPerimeter = 0, rectDiagonal = 0;
                        bool isValid = false;
                        String errorMsg = '';

                        if (l > 0 && w > 0) {
                          rectArea = l * w;
                          rectPerimeter = 2 * (l + w);
                          rectDiagonal = sqrt(l * l + w * w);
                          isValid = true;
                        } else {
                          errorMsg = 'Enter length and width greater than 0.';
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Input', style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),

                            // FIXED INPUT ROWS (Dropdown ki jagah fixed boxes)
                            _buildFixedInputRow(
                              title: 'Length',
                              ctrl: _rectLenCtrl,
                              icon: CustomPaint(painter: RectInputPainter(highlightType: 'Length', baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent)),
                            ),
                            _buildFixedInputRow(
                              title: 'Width',
                              ctrl: _rectWidCtrl,
                              icon: CustomPaint(painter: RectInputPainter(highlightType: 'Width', baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent)),
                            ),
                            const SizedBox(height: 4),

                            // Dynamic Hint Banner
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                const SizedBox(width: 12),
                                Expanded(child: Text(_getShapeHintMessage(currentShape.name), style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15))),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Result Container
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: AppColors.cyanColor(context).withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.3), width: 1.5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(child: Text('Calculation Result', style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold))),
                                  const SizedBox(height: 12),
                                  Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                  const SizedBox(height: 12),

                                  if (!isValid)
                                    Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(errorMsg, textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent.withOpacity(0.9), fontSize: 14))))
                                  else ...[
                                    _buildResultRow('Area', rectArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Perimeter', rectPerimeter.toStringAsFixed(2)),
                                    Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1)),
                                    _buildResultRow('Length', l.toStringAsFixed(2)),
                                    _buildResultRow('Width', w.toStringAsFixed(2)),
                                    _buildResultRow('Diagonal', rectDiagonal.toStringAsFixed(2)),
                                  ]
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),
                        // ==========================================
                        // YAHAN SE TRAPEZOID KA CODE ADD KAREIN
                        // ==========================================
                      ] else if (currentShape.name == 'Trapezoid') ...[
                        Builder(
                          builder: (context) {
                            double h = double.tryParse(_trapHeightCtrl.text) ?? 0;
                            double top = double.tryParse(_trapTopCtrl.text) ?? 0;
                            double base = double.tryParse(_trapBaseCtrl.text) ?? 0;

                            double trapArea = 0, trapMedian = 0, trapIsoLeg = 0;
                            bool isValid = false;
                            String errorMsg = '';

                            if (h > 0 && top > 0 && base > 0) {
                              trapArea = ((top + base) / 2) * h;
                              trapMedian = (top + base) / 2;

                              // Agar Isosceles Trapezoid maane toh Leg ki lambai
                              double baseDiff = (base - top).abs() / 2;
                              trapIsoLeg = sqrt((h * h) + (baseDiff * baseDiff));

                              isValid = true;
                            } else {
                              errorMsg = 'Enter height, top, and base greater than 0.';
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Input', style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),

                                // FIXED INPUT ROWS for Trapezoid
                                _buildFixedInputRow(
                                  title: 'Height',
                                  ctrl: _trapHeightCtrl,
                                  icon: CustomPaint(painter: TrapInputPainter(highlightType: 'Height', baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent)),
                                ),
                                _buildFixedInputRow(
                                  title: 'Top',
                                  ctrl: _trapTopCtrl,
                                  icon: CustomPaint(painter: TrapInputPainter(highlightType: 'Top', baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent)),
                                ),
                                _buildFixedInputRow(
                                  title: 'Base',
                                  ctrl: _trapBaseCtrl,
                                  icon: CustomPaint(painter: TrapInputPainter(highlightType: 'Base', baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent)),
                                ),
                                const SizedBox(height: 4),

                                // Dynamic Hint Banner
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(_getShapeHintMessage(currentShape.name), style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15))),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Result Container
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: AppColors.cyanColor(context).withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.3), width: 1.5)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(child: Text('Calculation Result', style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold))),
                                      const SizedBox(height: 12),
                                      Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                      const SizedBox(height: 12),

                                      if (!isValid)
                                        Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(errorMsg, textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent.withOpacity(0.9), fontSize: 14))))
                                      else ...[
                                        _buildResultRow('Area', trapArea.toStringAsFixed(2), isHighlighted: true),
                                        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1)),
                                        _buildResultRow('Median (Midline)', trapMedian.toStringAsFixed(2)),
                                        _buildResultRow('Leg (If Isosceles)', trapIsoLeg.toStringAsFixed(2)),
                                      ]
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            );
                          },
                        ),
                        // ==========================================
                        // YAHAN SE RHOMBUS KA CODE ADD KAREIN
                        // ==========================================
                      ] else if (currentShape.name == 'Rhombus') ...[
                        Builder(
                          builder: (context) {
                            double d1 = double.tryParse(_rhomLenCtrl.text) ?? 0; // Length (Horizontal Diagonal)
                            double d2 = double.tryParse(_rhomWidCtrl.text) ?? 0; // Width (Vertical Diagonal)

                            double rhomArea = 0, rhomSide = 0, rhomPerimeter = 0;
                            bool isValid = false;
                            String errorMsg = '';

                            if (d1 > 0 && d2 > 0) {
                              rhomArea = (d1 * d2) / 2; // Area = (d1 * d2) / 2
                              // Side = Pythagoras theorem on half-diagonals
                              rhomSide = sqrt((d1 / 2) * (d1 / 2) + (d2 / 2) * (d2 / 2));
                              rhomPerimeter = 4 * rhomSide;

                              isValid = true;
                            } else {
                              errorMsg = 'Enter length and width greater than 0.';
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Input', style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),

                                // FIXED INPUT ROWS for Rhombus
                                _buildFixedInputRow(
                                  title: 'Length',
                                  ctrl: _rhomLenCtrl,
                                  icon: CustomPaint(painter: RhomInputPainter(highlightType: 'Length', baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent)),
                                ),
                                _buildFixedInputRow(
                                  title: 'Width',
                                  ctrl: _rhomWidCtrl,
                                  icon: CustomPaint(painter: RhomInputPainter(highlightType: 'Width', baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent)),
                                ),
                                const SizedBox(height: 4),

                                // Dynamic Hint Banner
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(_getShapeHintMessage(currentShape.name), style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15))),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Result Container
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: AppColors.cyanColor(context).withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.3), width: 1.5)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(child: Text('Calculation Result', style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold))),
                                      const SizedBox(height: 12),
                                      Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                      const SizedBox(height: 12),

                                      if (!isValid)
                                        Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(errorMsg, textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent.withOpacity(0.9), fontSize: 14))))
                                      else ...[
                                        _buildResultRow('Area', rhomArea.toStringAsFixed(2), isHighlighted: true),
                                        _buildResultRow('Perimeter', rhomPerimeter.toStringAsFixed(2)),
                                        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1)),
                                        _buildResultRow('Side (Edge)', rhomSide.toStringAsFixed(2)),
                                      ]
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            );
                          },
                        ),
                      ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  /// end main build

  // NAYA: Input Field Helper (Title upar, hint 0)
  // Widget _buildInputField(String title, TextEditingController controller) {
  //   return Expanded(
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 4),
  //       child: Column(
  //         children: [
  //           // Upar Title (Side A, Side B, etc.)
  //           Text(
  //             title,
  //             style: TextStyle(color: AppColors.textGrey(context), fontSize: 13, fontWeight: FontWeight.w500),
  //           ),
  //           const SizedBox(height: 6),
  //           // Niche Input Box
  //           Container(
  //             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  //             decoration: BoxDecoration(
  //               color: AppColors.bgColor(context).withOpacity(0.5),
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: AppColors.cyanColor(context).withOpacity(0.2)),
  //             ),
  //             child: TextField(
  //               controller: controller,
  //               keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //               textAlign: TextAlign.center,
  //               style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
  //               cursorColor: AppColors.cyanColor(context),
  //               decoration: InputDecoration(
  //                 border: InputBorder.none,
  //                 isDense: true,
  //                 contentPadding: EdgeInsets.zero,
  //                 hintText: '--',
  //                 // Hint hamesha 0 dikhega
  //                 hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.5)),
  //               ),
  //               onChanged: (_) => setState(() {}),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // NAYA: Normal Triangle Input Row Builder (Bina dropdown ke, fixed title ke sath)
  // Widget _buildTriInputRow(String title, TextEditingController ctrl) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 12),
  //     child: Row(
  //       children: [
  //         // Icon aur Title Box
  //         Expanded(
  //           flex: 5,
  //           child: Container(
  //             height: 60,
  //             padding: const EdgeInsets.symmetric(horizontal: 16),
  //             decoration: BoxDecoration(
  //               color: AppColors.surfaceColor(context).withOpacity(0.3),
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
  //             ),
  //             child: Row(
  //               children: [
  //                 SizedBox(
  //                   width: 24, height: 24,
  //                   child: CustomPaint(
  //                     painter: TriInputPainter(highlightType: title, baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 16),
  //                 Text(title, style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
  //               ],
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         // TextField Box
  //         Expanded(
  //           flex: 4,
  //           child: Container(
  //             height: 60,
  //             alignment: Alignment.center,
  //             decoration: BoxDecoration(
  //               color: AppColors.surfaceColor(context).withOpacity(0.3),
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
  //             ),
  //             child: TextField(
  //               controller: ctrl,
  //               keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //               textAlign: TextAlign.center,
  //               style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
  //               cursorColor: Colors.orangeAccent,
  //               decoration: InputDecoration(border: InputBorder.none, hintText: '--', hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.5))),
  //               onChanged: (_) => setState((){}),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // NAYA & MASTER: Dynamic Fixed Input Row Builder (Bina dropdown ke)
  Widget _buildFixedInputRow({
    required String title,
    required TextEditingController ctrl,
    required Widget icon, // NAYA: Koi bhi widget (icon/painter) pass kar sakte hain
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Icon aur Title Box
          Expanded(
            flex: 5,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24, height: 24,
                    child: icon, // Dynamic icon yahan render hoga
                  ),
                  const SizedBox(width: 16),
                  Text(title, style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // TextField Box
          Expanded(
            flex: 4,
            child: Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
              ),
              child: TextField(
                controller: ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                cursorColor: Colors.orangeAccent,
                decoration: InputDecoration(border: InputBorder.none, hintText: '--', hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.5))),
                onChanged: (_) => setState((){}),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NAYA: Result Row Helper
  Widget _buildResultRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? AppColors.cyanColor(context) : AppColors.textGrey(context),
              fontSize: 15,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlighted ? AppColors.cyanColor(context) : AppColors.textColor(context),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // NAYA: Right Triangle Input Row Builder[cite: 4]
  Widget _buildRtInputRow(int index) {
    String type = index == 1 ? _rtType1 : _rtType2;
    TextEditingController ctrl = index == 1 ? _rtVal1Ctrl : _rtVal2Ctrl;

    List<String> parts = type.split(' ');
    String mainTitle = parts[0];
    String subTitle = parts.length > 1 ? parts[1] : '';

    return Row(
      children: [
        // Dropdown Selector Button
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: () => _showRtSelectorSheet(index),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(
                      painter: RtInputPainter(
                        highlightType: type,
                        baseColor: AppColors.textGrey(context).withOpacity(0.5),
                        highlightColor: Colors.orangeAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mainTitle,
                          style: TextStyle(
                            color: AppColors.textColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subTitle.isNotEmpty)
                          Text(subTitle, style: TextStyle(color: AppColors.textGrey(context), fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey(context), size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // TextField
        Expanded(
          flex: 4,
          child: Container(
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
            ),
            child: TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              cursorColor: Colors.orangeAccent,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '--',
                hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.5)),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ],
    );
  }

  // NAYA & MASTER: Dynamic Bottom Sheet for ALL Shapes
  void _showDynamicInputSelectorSheet({
    required List<String> options,
    required String currentSelection,
    required double heightFraction,
    required Widget Function(String) iconBuilder,
    required ValueChanged<String> onSelected,
  }) {
    if (_isHapticsEnabled) HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * heightFraction,
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(sheetContext),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColor(context), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Input',
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),

              // List Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    String opt = options[i];
                    bool isSelected = opt == currentSelection;

                    // Logic to split title and subtitle (e.g. "Side A" -> Title: "Side", Subtitle: "A")
                    List<String> parts = opt.split(' ');
                    String mTitle = parts[0];
                    String sTitle = parts.length > 1 ? parts.sublist(1).join(' ') : '';

                    return GestureDetector(
                      onTap: () {
                        if (_isHapticsEnabled) HapticFeedback.selectionClick();
                        onSelected(opt); // Callback to update state
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.textGrey(context).withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Custom Painter Icon (har shape ka apna hoga)
                            SizedBox(width: 24, height: 24, child: iconBuilder(opt)),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mTitle,
                                  style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                if (sTitle.isNotEmpty)
                                  Text(sTitle, style: TextStyle(color: AppColors.textGrey(context), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // NAYA: Bottom Sheet for Selection[cite: 5]
  // void _showRtSelectorSheet(int inputIndex) {
  //   if (_isHapticsEnabled) HapticFeedback.lightImpact();
  //
  //   List<String> options = ['Side A', 'Side B', 'Hypotenuse', 'Angle A', 'Angle B'];
  //   String currentSelection = inputIndex == 1 ? _rtType1 : _rtType2;
  //
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (BuildContext sheetContext) {
  //       return Container(
  //         height: MediaQuery.of(context).size.height * 0.65,
  //         decoration: BoxDecoration(
  //           color: AppColors.surfaceColor(context),
  //           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Header
  //             Padding(
  //               padding: const EdgeInsets.all(20),
  //               child: Row(
  //                 children: [
  //                   GestureDetector(
  //                     onTap: () => Navigator.pop(sheetContext),
  //                     child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColor(context), size: 20),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Text(
  //                     'Input',
  //                     style: TextStyle(color: AppColors.textColor(context), fontSize: 20, fontWeight: FontWeight.bold),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
  //             // List Items
  //             Expanded(
  //               child: ListView.builder(
  //                 padding: const EdgeInsets.symmetric(vertical: 10),
  //                 physics: const BouncingScrollPhysics(),
  //                 itemCount: options.length,
  //                 itemBuilder: (context, i) {
  //                   String opt = options[i];
  //                   bool isSelected = opt == currentSelection;
  //                   List<String> parts = opt.split(' ');
  //                   String mTitle = parts[0];
  //                   String sTitle = parts.length > 1 ? parts[1] : '';
  //
  //                   return GestureDetector(
  //                     onTap: () {
  //                       if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                       setState(() {
  //                         if (inputIndex == 1)
  //                           _rtType1 = opt;
  //                         else
  //                           _rtType2 = opt;
  //                       });
  //                       Navigator.pop(sheetContext);
  //                     },
  //                     child: Container(
  //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //                       padding: const EdgeInsets.all(16),
  //                       decoration: BoxDecoration(
  //                         color: isSelected ? AppColors.textGrey(context).withOpacity(0.15) : Colors.transparent,
  //                         borderRadius: BorderRadius.circular(16),
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           SizedBox(
  //                             width: 24,
  //                             height: 24,
  //                             child: CustomPaint(
  //                               painter: RtInputPainter(
  //                                 highlightType: opt,
  //                                 baseColor: AppColors.textGrey(context).withOpacity(0.5),
  //                                 highlightColor: Colors.orangeAccent,
  //                               ),
  //                             ),
  //                           ),
  //                           const SizedBox(width: 16),
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 mTitle,
  //                                 style: TextStyle(
  //                                   color: AppColors.textColor(context),
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.bold,
  //                                 ),
  //                               ),
  //                               if (sTitle.isNotEmpty)
  //                                 Text(sTitle, style: TextStyle(color: AppColors.textGrey(context), fontSize: 12)),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // NAYA: Right Triangle ka wrapper
  void _showRtSelectorSheet(int inputIndex) {
    List<String> options = ['Side A', 'Side B', 'Hypotenuse', 'Angle A', 'Angle B'];
    String currentSelection = inputIndex == 1 ? _rtType1 : _rtType2;

    _showDynamicInputSelectorSheet(
      options: options,
      currentSelection: currentSelection,
      heightFraction: 0.65, // Right triangle mein options zyada hain, isliye bada sheet
      iconBuilder: (opt) => CustomPaint(
        painter: RtInputPainter(highlightType: opt, baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent),
      ),
      onSelected: (selectedVal) {
        setState(() {
          if (inputIndex == 1) _rtType1 = selectedVal; else _rtType2 = selectedVal;
        });
      },
    );
  }

  // NAYA: Square ka wrapper
  void _showSqSelectorSheet() {
    _showDynamicInputSelectorSheet(
      options: ['Side', 'Area', 'Perimeter'],
      currentSelection: _sqType,
      heightFraction: 0.5, // Square mein kam options hain, isliye chhota sheet
      iconBuilder: (opt) => CustomPaint(
        painter: SqInputPainter(highlightType: opt, baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent),
      ),
      onSelected: (selectedVal) {
        setState(() => _sqType = selectedVal);
      },
    );
  }

  // NAYA: Square Input Row Builder
  Widget _buildSqInputRow() {
    return Row(
      children: [
        // Dropdown Selector Button
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: () => _showSqSelectorSheet(),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24, height: 24,
                    child: CustomPaint(
                      painter: SqInputPainter(highlightType: _sqType, baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(_sqType, style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold))),
                  Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey(context), size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // TextField
        Expanded(
          flex: 4,
          child: Container(
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
            ),
            child: TextField(
              controller: _sqValCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              cursorColor: Colors.orangeAccent,
              decoration: InputDecoration(border: InputBorder.none, hintText: '--', hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.5))),
              onChanged: (_) => setState((){}),
            ),
          ),
        ),
      ],
    );
  }

  // NAYA: Bottom Sheet for Square Selection
  // void _showSqSelectorSheet() {
  //   if (_isHapticsEnabled) HapticFeedback.lightImpact();
  //
  //   List<String> options = ['Side', 'Area', 'Perimeter']; // Same as image[cite: 5]
  //
  //   showModalBottomSheet(
  //       context: context,
  //       backgroundColor: Colors.transparent,
  //       isScrollControlled: true,
  //       builder: (BuildContext sheetContext) {
  //         return Container(
  //           height: MediaQuery.of(context).size.height * 0.5, // Thoda chhota sheet kyunki 3 hi options hain
  //           decoration: BoxDecoration(color: AppColors.surfaceColor(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.all(20),
  //                 child: Row(
  //                   children: [
  //                     GestureDetector(onTap: () => Navigator.pop(sheetContext), child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColor(context), size: 20)),
  //                     const SizedBox(width: 12),
  //                     Text('Input', style: TextStyle(color: AppColors.textColor(context), fontSize: 20, fontWeight: FontWeight.bold)),
  //                   ],
  //                 ),
  //               ),
  //               Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
  //               Expanded(
  //                 child: ListView.builder(
  //                   padding: const EdgeInsets.symmetric(vertical: 10),
  //                   physics: const BouncingScrollPhysics(),
  //                   itemCount: options.length,
  //                   itemBuilder: (context, i) {
  //                     String opt = options[i];
  //                     bool isSelected = opt == _sqType;
  //
  //                     return GestureDetector(
  //                       onTap: () {
  //                         if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                         setState(() => _sqType = opt);
  //                         Navigator.pop(sheetContext);
  //                       },
  //                       child: Container(
  //                         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //                         padding: const EdgeInsets.all(16),
  //                         decoration: BoxDecoration(color: isSelected ? AppColors.textGrey(context).withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(16)),
  //                         child: Row(
  //                           children: [
  //                             SizedBox(width: 24, height: 24, child: CustomPaint(painter: SqInputPainter(highlightType: opt, baseColor: AppColors.textGrey(context).withOpacity(0.5), highlightColor: Colors.orangeAccent))),
  //                             const SizedBox(width: 16),
  //                             Text(opt, style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       }
  //   );
  // }

}

// NAYA: Normal Triangle ke specifically selected side ko highlight karne ke liye Painter
class TriInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  TriInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()..color = baseColor..style = PaintingStyle.stroke..strokeWidth = 2.0;
    Paint hlPaint = Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 3.0;

    Offset pTop = Offset(size.width / 2, 0);
    Offset pBottomLeft = Offset(0, size.height);
    Offset pBottomRight = Offset(size.width, size.height);

    // Base Triangle Draw karein
    Path path = Path()..moveTo(pTop.dx, pTop.dy)..lineTo(pBottomLeft.dx, pBottomLeft.dy)..lineTo(pBottomRight.dx, pBottomRight.dy)..close();
    canvas.drawPath(path, basePaint);

    // Selected Part Highlight Karein
    if (highlightType == 'Side A') {
      canvas.drawLine(pTop, pBottomLeft, hlPaint); // Left side
    } else if (highlightType == 'Side B') {
      canvas.drawLine(pBottomLeft, pBottomRight, hlPaint); // Bottom side
    } else if (highlightType == 'Side C') {
      canvas.drawLine(pBottomRight, pTop, hlPaint); // Right side
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// NAYA: Right Triangle ke specifically selected part ko highlight karne ke liye Painter
class RtInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  RtInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    Paint hlPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    Offset pTop = const Offset(0, 0); // Angle A
    Offset pBottomLeft = Offset(0, size.height); // 90 degree
    Offset pBottomRight = Offset(size.width, size.height); // Angle B

    // Base Triangle Draw karein
    Path path = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pBottomLeft.dx, pBottomLeft.dy)
      ..lineTo(pBottomRight.dx, pBottomRight.dy)
      ..close();
    canvas.drawPath(path, basePaint);

    // Selected Part Highlight Karein
    if (highlightType == 'Side A') {
      canvas.drawLine(pTop, pBottomLeft, hlPaint);
    } else if (highlightType == 'Side B') {
      canvas.drawLine(pBottomLeft, pBottomRight, hlPaint);
    } else if (highlightType == 'Hypotenuse') {
      canvas.drawLine(pTop, pBottomRight, hlPaint);
    } else if (highlightType == 'Angle A') {
      Paint fillHl = Paint()
        ..color = highlightColor
        ..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: pTop, radius: 10), 0, pi / 2, true, fillHl);
    } else if (highlightType == 'Angle B') {
      Paint fillHl = Paint()
        ..color = highlightColor
        ..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: pBottomRight, radius: 10), pi, -pi / 4, true, fillHl);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// NAYA: Square ke specifically selected part ko highlight karne ke liye Painter
class SqInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  SqInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()..color = baseColor..style = PaintingStyle.stroke..strokeWidth = 2.0;
    Paint hlPaint = Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 3.0;
    Paint fillPaint = Paint()..color = highlightColor.withOpacity(0.6)..style = PaintingStyle.fill;

    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (highlightType == 'Area') {
      canvas.drawRect(rect, fillPaint); // Area select hone par fill hoga[cite: 5]
    } else if (highlightType == 'Perimeter') {
      canvas.drawRect(rect, Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 2.5); // Perimeter mein pura border highlight hoga[cite: 5]
    } else {
      // Side: Sirf bottom ki line highlight hogi[cite: 5]
      canvas.drawRect(rect, basePaint);
      canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), hlPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// NAYA: Rectangle ke specifically selected side ko highlight karne ke liye Painter
class RectInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  RectInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()..color = baseColor..style = PaintingStyle.stroke..strokeWidth = 2.0;
    Paint hlPaint = Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 3.0;

    // Rectangle draw karne ke liye thoda chauda (wide) box banayenge
    Rect rect = Rect.fromLTWH(0, size.height * 0.25, size.width, size.height * 0.5);

    // Base Rectangle Draw karein
    canvas.drawRect(rect, basePaint);

    // Selected Part Highlight Karein
    if (highlightType == 'Length') {
      canvas.drawLine(Offset(0, rect.bottom), Offset(size.width, rect.bottom), hlPaint); // Niche wali lambi line
    } else if (highlightType == 'Width') {
      canvas.drawLine(Offset(size.width, rect.top), Offset(size.width, rect.bottom), hlPaint); // Right side wali choti line
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// NAYA: Trapezoid ke selected part ko highlight karne ke liye Painter
class TrapInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  TrapInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()..color = baseColor..style = PaintingStyle.stroke..strokeWidth = 2.0;
    Paint hlPaint = Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 3.0;

    double w = size.width;
    double h = size.height;

    // Trapezoid ke 4 points
    Offset pTopLeft = Offset(w * 0.25, h * 0.25);
    Offset pTopRight = Offset(w * 0.75, h * 0.25);
    Offset pBottomLeft = Offset(0, h * 0.85);
    Offset pBottomRight = Offset(w, h * 0.85);

    // Base Trapezoid Draw karein
    Path path = Path()
      ..moveTo(pTopLeft.dx, pTopLeft.dy)
      ..lineTo(pTopRight.dx, pTopRight.dy)
      ..lineTo(pBottomRight.dx, pBottomRight.dy)
      ..lineTo(pBottomLeft.dx, pBottomLeft.dy)
      ..close();
    canvas.drawPath(path, basePaint);

    // Selected Part Highlight Karein
    if (highlightType == 'Top') {
      canvas.drawLine(pTopLeft, pTopRight, hlPaint); // Upar ki line
    } else if (highlightType == 'Base') {
      canvas.drawLine(pBottomLeft, pBottomRight, hlPaint); // Niche ki line
    } else if (highlightType == 'Height') {
      // Beech mein vertical height draw karein
      canvas.drawLine(Offset(w / 2, h * 0.25), Offset(w / 2, h * 0.85), hlPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// NAYA: Rhombus ke diagonals (Length/Width) ko highlight karne ke liye Painter
class RhomInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  RhomInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()..color = baseColor..style = PaintingStyle.stroke..strokeWidth = 2.0;
    Paint hlPaint = Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 3.0;

    double w = size.width;
    double h = size.height;

    // Rhombus ke 4 points (Diamond shape)
    Offset pTop = Offset(w / 2, 0);
    Offset pBottom = Offset(w / 2, h);
    Offset pLeft = Offset(0, h / 2);
    Offset pRight = Offset(w, h / 2);

    // Base Rhombus Draw karein
    Path path = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(pBottom.dx, pBottom.dy)
      ..lineTo(pLeft.dx, pLeft.dy)
      ..close();
    canvas.drawPath(path, basePaint);

    // Selected Part Highlight Karein
    if (highlightType == 'Length') {
      canvas.drawLine(pLeft, pRight, hlPaint); // Horizontal Diagonal
    } else if (highlightType == 'Width') {
      canvas.drawLine(pTop, pBottom, hlPaint); // Vertical Diagonal
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}