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

  // --- Circle Arc Input State ---
  final TextEditingController _arcRadiusCtrl = TextEditingController(text: '');
  final TextEditingController _arcAngleCtrl = TextEditingController(text: '');

  // --- Ellipse Input State ---
  final TextEditingController _ellipRadACtrl = TextEditingController(text: '');
  final TextEditingController _ellipRadBCtrl = TextEditingController(text: '');

  String _pentType = 'Side'; // Default selection
  final TextEditingController _pentValCtrl = TextEditingController(text: '');

  // --- Hexagon Input State ---
  String _hexType = 'Side'; // Default selection
  final TextEditingController _hexValCtrl = TextEditingController(text: '');

  // --- Circle Input State ---
  String _circleType = 'Radius'; // Default selection
  final TextEditingController _circleValCtrl = TextEditingController(text: '');

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
    // NAYA: Circle Arc controllers dispose karein
    _arcRadiusCtrl.dispose();
    _arcAngleCtrl.dispose();
    // NAYA: Ellipse controllers dispose karein
    _ellipRadACtrl.dispose();
    _ellipRadBCtrl.dispose();
    // NAYA: Pentagon controller dispose karein
    _pentValCtrl.dispose();
    // NAYA: Hexagon controller dispose karein
    _hexValCtrl.dispose();
    // NAYA: Circle controller dispose karein
    _circleValCtrl.dispose();
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
        return 'Solve a ${shapeName.toLowerCase()} knowing its parameters.';
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
  // void _showShapeSelectorGrid() {
  //   if (_isHapticsEnabled) HapticFeedback.lightImpact();
  //
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent, // Background transparent rakha taki custom container dikhe
  //     isScrollControlled: true,
  //     builder: (BuildContext context) {
  //       return Container(
  //         height: MediaQuery.of(context).size.height * 0.75, // 75% of screen height
  //         decoration: BoxDecoration(
  //           color: AppColors.surfaceColor(context),
  //           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
  //           border: Border(top: BorderSide(color: AppColors.textGrey(context).withOpacity(0.3))),
  //         ),
  //         child: Column(
  //           children: [
  //             // Sheet Handle
  //             Container(
  //               width: 40,
  //               height: 4,
  //               margin: const EdgeInsets.only(top: 10, bottom: 10),
  //               decoration: BoxDecoration(
  //                 color: AppColors.textGrey(context).withOpacity(0.5),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //
  //             // Header
  //             Text(
  //               'Select Shape',
  //               style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 10),
  //             Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
  //
  //             // Grid View
  //             Expanded(
  //               child: GridView.builder(
  //                 padding: const EdgeInsets.all(10),
  //                 physics: const BouncingScrollPhysics(),
  //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //                   crossAxisCount: 3, // 3 columns as per screenshot
  //                   crossAxisSpacing: 5,
  //                   mainAxisSpacing: 5,
  //                   childAspectRatio: 0.85, // Adjust for icon + 2 lines of text
  //                 ),
  //                 itemCount: _shapeList.length,
  //                 itemBuilder: (context, index) {
  //                   bool isSelected = index == _selectedShapeIndex;
  //                   ShapeItem item = _shapeList[index];
  //
  //                   return GestureDetector(
  //                     onTap: () {
  //                       if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                       setState(() {
  //                         _selectedShapeIndex = index;
  //                       });
  //                       Navigator.pop(context); // Close sheet on selection
  //                     },
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         color: isSelected ? AppColors.cyanColor(context).withOpacity(0.1) : Colors.transparent,
  //                         borderRadius: BorderRadius.circular(16),
  //                         border: Border.all(
  //                           color: isSelected ? AppColors.cyanColor(context).withOpacity(0.5) : Colors.transparent,
  //                         ),
  //                       ),
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           SizedBox(
  //                             height: 45,
  //                             child: Center(child: item.iconBuilder), // The Custom Painted Icon
  //                           ),
  //                           const SizedBox(height: 10),
  //                           Text(
  //                             item.name,
  //                             textAlign: TextAlign.center,
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                             style: TextStyle(
  //                               color: AppColors.textColor(context),
  //                               fontSize: 13,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 2),
  //                           Text(
  //                             'Shapes', // Subtitle text as per screenshot[cite: 2]
  //                             style: TextStyle(color: AppColors.textGrey(context), fontSize: 11),
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

  void _showShapeSelectorGrid() {
    if (_isHapticsEnabled) HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          // SafeArea add kiya taaki bottom edge se touch na ho
          child: Container(
            // FIX: Fixed height yahan se hata di gayi hai
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: AppColors.textGrey(context).withOpacity(0.3))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // FIX: Jitna content utni jagah lega
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
                // FIX: Expanded hata diya aur GridView me shrinkWrap: true laga diya
                GridView.builder(
                  shrinkWrap: true,
                  // FIX: Apni height khud grid ke hisaab se adjust karega
                  padding: const EdgeInsets.all(5),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 1,
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
                        Navigator.pop(context);
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
                            SizedBox(height: 45, child: Center(child: item.iconBuilder)),
                            const SizedBox(height: 5),
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
                            Text('Shapes', style: TextStyle(color: AppColors.textGrey(context), fontSize: 11)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10), // Bottom mein thodi extra space
              ],
            ),
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
                    Column(
                      children: [
                        _buildFixedInputRow(
                          title: 'Side A',
                          ctrl: _triACtrl,
                          icon: CustomPaint(
                            painter: TriInputPainter(
                              highlightType: 'Side A',
                              baseColor: AppColors.textGrey(context).withOpacity(0.5),
                              highlightColor: AppColors.orangeColor(context),
                            ),
                          ),
                        ),
                        _buildFixedInputRow(
                          title: 'Side B',
                          ctrl: _triBCtrl,
                          icon: CustomPaint(
                            painter: TriInputPainter(
                              highlightType: 'Side B',
                              baseColor: AppColors.textGrey(context).withOpacity(0.5),
                              highlightColor: AppColors.orangeColor(context),
                            ),
                          ),
                        ),
                        _buildFixedInputRow(
                          title: 'Side C',
                          ctrl: _triCCtrl,
                          icon: CustomPaint(
                            painter: TriInputPainter(
                              highlightType: 'Side C',
                              baseColor: AppColors.textGrey(context).withOpacity(0.5),
                              highlightColor: AppColors.orangeColor(context),
                            ),
                          ),
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
                                  style: TextStyle(color: AppColors.redColor(context).withOpacity(0.9), fontSize: 14),
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
                            if (_rtType1 == 'Side A') {
                              a = v1;
                            } else if (_rtType1 == 'Side B') {
                              b = v1;
                            } else if (_rtType1 == 'Hypotenuse') {
                              c = v1;
                            } else if (_rtType1 == 'Angle A') {
                              angA = v1;
                            } else if (_rtType1 == 'Angle B') {
                              angB = v1;
                            }

                            if (_rtType2 == 'Side A') {
                              a = v2;
                            } else if (_rtType2 == 'Side B') {
                              b = v2;
                            } else if (_rtType2 == 'Hypotenuse') {
                              c = v2;
                            } else if (_rtType2 == 'Angle A') {
                              angA = v2;
                            } else if (_rtType2 == 'Angle B') {
                              angB = v2;
                            }

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

                              if (a != null &&
                                  b != null &&
                                  c != null &&
                                  angA != null &&
                                  angB != null &&
                                  a > 0 &&
                                  b > 0 &&
                                  c > 0) {
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
                                          style: TextStyle(
                                            color: AppColors.redColor(context).withOpacity(0.9),
                                            fontSize: 14,
                                          ),
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
                            Text(
                              'Input',
                              style: TextStyle(
                                color: AppColors.textColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Sirf 1 input field hogi Square ke liye
                            _buildSqInputRow(),
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
                                          style: TextStyle(
                                            color: AppColors.redColor(context).withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    _buildResultRow('Area', sqArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Perimeter', sqPerimeter.toStringAsFixed(2)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),
                                    _buildResultRow('Side', sqSide.toStringAsFixed(2)),
                                    _buildResultRow('Diagonal', sqDiagonal.toStringAsFixed(2)),
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
                            Text(
                              'Input',
                              style: TextStyle(
                                color: AppColors.textColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // FIXED INPUT ROWS (Dropdown ki jagah fixed boxes)
                            _buildFixedInputRow(
                              title: 'Length',
                              ctrl: _rectLenCtrl,
                              icon: CustomPaint(
                                painter: RectInputPainter(
                                  highlightType: 'Length',
                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                  highlightColor: AppColors.orangeColor(context),
                                ),
                              ),
                            ),
                            _buildFixedInputRow(
                              title: 'Width',
                              ctrl: _rectWidCtrl,
                              icon: CustomPaint(
                                painter: RectInputPainter(
                                  highlightType: 'Width',
                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                  highlightColor: AppColors.orangeColor(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

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
                                          style: TextStyle(
                                            color: AppColors.redColor(context).withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    _buildResultRow('Area', rectArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Perimeter', rectPerimeter.toStringAsFixed(2)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),
                                    _buildResultRow('Length', l.toStringAsFixed(2)),
                                    _buildResultRow('Width', w.toStringAsFixed(2)),
                                    _buildResultRow('Diagonal', rectDiagonal.toStringAsFixed(2)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),

                    /// ==========================================
                    /// YAHAN SE TRAPEZOID KA CODE ADD KAREIN
                    /// ==========================================
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
                            Text(
                              'Input',
                              style: TextStyle(
                                color: AppColors.textColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // FIXED INPUT ROWS for Trapezoid
                            _buildFixedInputRow(
                              title: 'Height',
                              ctrl: _trapHeightCtrl,
                              icon: CustomPaint(
                                painter: TrapInputPainter(
                                  highlightType: 'Height',
                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                  highlightColor: AppColors.orangeColor(context),
                                ),
                              ),
                            ),
                            _buildFixedInputRow(
                              title: 'Top',
                              ctrl: _trapTopCtrl,
                              icon: CustomPaint(
                                painter: TrapInputPainter(
                                  highlightType: 'Top',
                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                  highlightColor: AppColors.orangeColor(context),
                                ),
                              ),
                            ),
                            _buildFixedInputRow(
                              title: 'Base',
                              ctrl: _trapBaseCtrl,
                              icon: CustomPaint(
                                painter: TrapInputPainter(
                                  highlightType: 'Base',
                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                  highlightColor: AppColors.orangeColor(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

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
                                          style: TextStyle(
                                            color: AppColors.redColor(context).withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    _buildResultRow('Area', trapArea.toStringAsFixed(2), isHighlighted: true),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),
                                    _buildResultRow('Median (Midline)', trapMedian.toStringAsFixed(2)),
                                    _buildResultRow('Leg (If Isosceles)', trapIsoLeg.toStringAsFixed(2)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),

                    /// ==========================================
                    /// YAHAN SE RHOMBUS KA CODE ADD KAREIN
                    /// ==========================================
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
                            Text(
                              'Input',
                              style: TextStyle(
                                color: AppColors.textColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // FIXED INPUT ROWS for Rhombus
                            _buildFixedInputRow(
                              title: 'Length',
                              ctrl: _rhomLenCtrl,
                              icon: CustomPaint(
                                painter: RhomInputPainter(
                                  highlightType: 'Length',
                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                  highlightColor: AppColors.orangeColor(context),
                                ),
                              ),
                            ),
                            _buildFixedInputRow(
                              title: 'Width',
                              ctrl: _rhomWidCtrl,
                              icon: CustomPaint(
                                painter: RhomInputPainter(
                                  highlightType: 'Width',
                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                  highlightColor: AppColors.orangeColor(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

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
                                          style: TextStyle(
                                            color: AppColors.redColor(context).withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    _buildResultRow('Area', rhomArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Perimeter', rhomPerimeter.toStringAsFixed(2)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),
                                    _buildResultRow('Side (Edge)', rhomSide.toStringAsFixed(2)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),

                    /// ==========================================
                    /// YAHAN SE CIRCLE ARC KA CODE ADD KAREIN
                    /// ==========================================
                  ] else if (currentShape.name == 'Circle arc') ...[
                    Builder(
                      builder: (context) {
                        double radius = double.tryParse(_arcRadiusCtrl.text) ?? 0;
                        double angle = double.tryParse(_arcAngleCtrl.text) ?? 0;

                        double arcLength = 0, sectorArea = 0, chordLength = 0, perimeter = 0;
                        bool isValid = false;
                        String errorMsg = '';

                        if (radius > 0 && angle > 0) {
                          if (angle <= 360) {
                            // Calculations
                            arcLength = 2 * pi * radius * (angle / 360);
                            sectorArea = pi * radius * radius * (angle / 360);
                            chordLength = 2 * radius * sin((angle / 2) * (pi / 180));
                            perimeter = arcLength + (2 * radius);

                            isValid = true;
                          } else {
                            errorMsg = 'Angle must be between 1 and 360 degrees.';
                          }
                        } else {
                          errorMsg = 'Enter radius and angle greater than 0.';
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

                            // FIXED INPUT ROWS for Circle Arc
                            _buildFixedInputRow(
                              title: 'Radius',
                              ctrl: _arcRadiusCtrl,
                              icon: CustomPaint(
                                painter: ArcInputPainter(
                                  highlightType: 'Radius',
                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                  highlightColor: AppColors.orangeColor(context),
                                ),
                              ),
                            ),
                            _buildFixedInputRow(
                              title: 'Angle',
                              ctrl: _arcAngleCtrl,
                              icon: CustomPaint(
                                painter: ArcInputPainter(
                                  highlightType: 'Angle',
                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                  highlightColor: AppColors.orangeColor(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

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
                                          style: TextStyle(
                                            color: AppColors.redColor(context).withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    _buildResultRow('Sector Area', sectorArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Arc Length', arcLength.toStringAsFixed(2)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),
                                    _buildResultRow('Chord Length', chordLength.toStringAsFixed(2)),
                                    _buildResultRow('Sector Perimeter', perimeter.toStringAsFixed(2)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),

                    /// ==========================================
                    /// YAHAN SE ELLIPSE KA CODE ADD KAREIN
                    /// ==========================================
                  ] else if (currentShape.name == 'Ellipse') ...[
                    Builder(
                      builder: (context) {
                        double a = double.tryParse(_ellipRadACtrl.text) ?? 0; // Radius A
                        double b = double.tryParse(_ellipRadBCtrl.text) ?? 0; // Radius B

                        double ellipArea = 0, ellipPerimeter = 0;
                        bool isValid = false;
                        String errorMsg = '';

                        if (a > 0 && b > 0) {
                          // Area = pi * a * b
                          ellipArea = pi * a * b;

                          // Perimeter (Ramanujan's approximation formula for high accuracy)
                          ellipPerimeter = pi * (3 * (a + b) - sqrt((3 * a + b) * (a + 3 * b)));

                          isValid = true;
                        } else {
                          errorMsg = 'Enter both radii greater than 0.';
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

                            // FIXED INPUT ROWS for Ellipse
                            _buildFixedInputRow(
                              title: 'Radius A',
                              ctrl: _ellipRadACtrl,
                              icon: CustomPaint(
                                painter: EllipInputPainter(
                                  highlightType: 'Radius A',
                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                  highlightColor: AppColors.orangeColor(context),
                                ),
                              ),
                            ),
                            _buildFixedInputRow(
                              title: 'Radius B',
                              ctrl: _ellipRadBCtrl,
                              icon: CustomPaint(
                                painter: EllipInputPainter(
                                  highlightType: 'Radius B',
                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                  highlightColor: AppColors.orangeColor(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

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
                                          style: TextStyle(
                                            color: AppColors.redColor(context).withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    _buildResultRow('Area', ellipArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Perimeter (Approx)', ellipPerimeter.toStringAsFixed(2)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),
                                    _buildResultRow('Radius A', a.toStringAsFixed(2)),
                                    _buildResultRow('Radius B', b.toStringAsFixed(2)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),

                    /// ==========================================
                    /// YAHAN SE PENTAGON KA CODE ADD KAREIN
                    /// ==========================================
                  ] else if (currentShape.name == 'Pentagon') ...[
                    Builder(
                      builder: (context) {
                        double val = double.tryParse(_pentValCtrl.text) ?? 0;

                        double pentSide = 0, pentArea = 0, pentPerimeter = 0, pentDiagonal = 0;
                        bool isValid = false;
                        String errorMsg = '';

                        // Pentagon mathematical constant for area
                        double areaMultiplier = 0.25 * sqrt(5 * (5 + 2 * sqrt(5))); // Approx 1.7204774

                        if (val > 0) {
                          if (_pentType == 'Side') {
                            pentSide = val;
                            pentPerimeter = 5 * pentSide;
                            pentArea = areaMultiplier * pentSide * pentSide;
                          } else if (_pentType == 'Area') {
                            pentArea = val;
                            pentSide = sqrt(pentArea / areaMultiplier);
                            pentPerimeter = 5 * pentSide;
                          } else if (_pentType == 'Perimeter') {
                            pentPerimeter = val;
                            pentSide = pentPerimeter / 5;
                            pentArea = areaMultiplier * pentSide * pentSide;
                          }

                          // Diagonal formula: d = s * (1 + sqrt(5)) / 2
                          pentDiagonal = pentSide * ((1 + sqrt(5)) / 2);

                          isValid = true;
                        } else {
                          errorMsg = 'Enter a value greater than 0.';
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

                            // DROPDOWN INPUT ROW for Pentagon
                            _buildPentInputRow(),
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
                                          style: TextStyle(
                                            color: AppColors.redColor(context).withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    _buildResultRow('Area', pentArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Perimeter', pentPerimeter.toStringAsFixed(2)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),
                                    _buildResultRow('Side (Edge)', pentSide.toStringAsFixed(2)),
                                    _buildResultRow('Diagonal', pentDiagonal.toStringAsFixed(2)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),

                    /// ==========================================
                    /// YAHAN SE HEXAGON KA CODE ADD KAREIN
                    /// ==========================================
                  ] else if (currentShape.name == 'Hexagon') ...[
                    Builder(
                      builder: (context) {
                        double val = double.tryParse(_hexValCtrl.text) ?? 0;

                        double hexSide = 0, hexArea = 0, hexPerimeter = 0, hexLongDiag = 0, hexShortDiag = 0;
                        bool isValid = false;
                        String errorMsg = '';

                        // Hexagon area formula constant: (3 * sqrt(3)) / 2
                        double areaMultiplier = 1.5 * sqrt(3);

                        if (val > 0) {
                          if (_hexType == 'Side') {
                            hexSide = val;
                            hexPerimeter = 6 * hexSide;
                            hexArea = areaMultiplier * hexSide * hexSide;
                          } else if (_hexType == 'Area') {
                            hexArea = val;
                            hexSide = sqrt(hexArea / areaMultiplier);
                            hexPerimeter = 6 * hexSide;
                          } else if (_hexType == 'Perimeter') {
                            hexPerimeter = val;
                            hexSide = hexPerimeter / 6;
                            hexArea = areaMultiplier * hexSide * hexSide;
                          }

                          // Diagonals
                          hexLongDiag = 2 * hexSide; // Point to opposite point
                          hexShortDiag = hexSide * sqrt(3); // Flat side to flat side

                          isValid = true;
                        } else {
                          errorMsg = 'Enter a value greater than 0.';
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

                            // DROPDOWN INPUT ROW for Hexagon
                            _buildHexInputRow(),
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
                                          style: TextStyle(
                                            color: AppColors.redColor(context).withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    _buildResultRow('Area', hexArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Perimeter', hexPerimeter.toStringAsFixed(2)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),
                                    _buildResultRow('Side (Edge)', hexSide.toStringAsFixed(2)),
                                    _buildResultRow('Long Diagonal', hexLongDiag.toStringAsFixed(2)),
                                    _buildResultRow('Short Diagonal', hexShortDiag.toStringAsFixed(2)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),

                    /// ==========================================
                    /// YAHAN SE CIRCLE KA CODE ADD KAREIN
                    /// ==========================================
                  ] else if (currentShape.name == 'Circle') ...[
                    Builder(
                      builder: (context) {
                        double val = double.tryParse(_circleValCtrl.text) ?? 0;

                        double circRadius = 0, circDiameter = 0, circArea = 0, circCircumference = 0;
                        bool isValid = false;
                        String errorMsg = '';

                        if (val > 0) {
                          if (_circleType == 'Radius') {
                            circRadius = val;
                          } else if (_circleType == 'Diameter') {
                            circRadius = val / 2;
                          } else if (_circleType == 'Area') {
                            circRadius = sqrt(val / pi);
                          } else if (_circleType == 'Circumference') {
                            circRadius = val / (2 * pi);
                          }

                          // Calculate all based on derived radius
                          circDiameter = 2 * circRadius;
                          circArea = pi * circRadius * circRadius;
                          circCircumference = 2 * pi * circRadius;

                          isValid = true;
                        } else {
                          errorMsg = 'Enter a value greater than 0.';
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

                            // DROPDOWN INPUT ROW for Circle
                            _buildCircInputRow(),
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
                                          style: TextStyle(
                                            color: AppColors.redColor(context).withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    _buildResultRow('Area', circArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Circumference', circCircumference.toStringAsFixed(2)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),
                                    _buildResultRow('Radius', circRadius.toStringAsFixed(2)),
                                    _buildResultRow('Diameter', circDiameter.toStringAsFixed(2)),
                                  ],
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
                    width: 24,
                    height: 24,
                    child: icon, // Dynamic icon yahan render hoga
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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
                cursorColor: AppColors.orangeColor(context),
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
      ),
    );
  }

  // NAYA: Result row ke liye dynamic icon generator
  Widget _getResultIcon(String shapeName, String label, bool isHighlighted) {
    // Highlighted row (jaise Area) ke liye Cyan color, baaki ke liye thoda halka Grey/Cyan
    Color hlColor = isHighlighted ? AppColors.cyanColor(context) : AppColors.textGrey(context).withOpacity(0.8);
    Color baseColor = AppColors.textGrey(context).withOpacity(0.2);

    CustomPainter? painter;
    switch (shapeName) {
      case 'Triangle': painter = TriInputPainter(highlightType: label, baseColor: baseColor, highlightColor: hlColor); break;
      case 'Right triangle': painter = RtInputPainter(highlightType: label, baseColor: baseColor, highlightColor: hlColor); break;
      case 'Square': painter = SqInputPainter(highlightType: label, baseColor: baseColor, highlightColor: hlColor); break;
      case 'Rectangle': painter = RectInputPainter(highlightType: label, baseColor: baseColor, highlightColor: hlColor); break;
      case 'Trapezoid': painter = TrapInputPainter(highlightType: label, baseColor: baseColor, highlightColor: hlColor); break;
      case 'Rhombus': painter = RhomInputPainter(highlightType: label, baseColor: baseColor, highlightColor: hlColor); break;
      case 'Circle arc': painter = ArcInputPainter(highlightType: label, baseColor: baseColor, highlightColor: hlColor); break;
      case 'Ellipse': painter = EllipInputPainter(highlightType: label, baseColor: baseColor, highlightColor: hlColor); break;
      case 'Pentagon': painter = PentInputPainter(highlightType: label, baseColor: baseColor, highlightColor: hlColor); break;
      case 'Hexagon': painter = HexInputPainter(highlightType: label, baseColor: baseColor, highlightColor: hlColor); break;
      case 'Circle': painter = CircInputPainter(highlightType: label, baseColor: baseColor, highlightColor: hlColor); break;
    }

    if (painter == null) return const SizedBox.shrink();

    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: painter),
    );
  }

  // NAYA: Result Row Helper
  // Widget _buildResultRow(String label, String value, {bool isHighlighted = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: TextStyle(
  //             color: isHighlighted ? AppColors.cyanColor(context) : AppColors.textGrey(context),
  //             fontSize: 15,
  //             fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
  //           ),
  //         ),
  //         Text(
  //           value,
  //           style: TextStyle(
  //             color: isHighlighted ? AppColors.cyanColor(context) : AppColors.textColor(context),
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // NAYA: Result Row Helper (Dynamic Icon ke sath)
  // NAYA: Result Row Helper (Fixed currentShape Error)
  Widget _buildResultRow(String label, String value, {bool isHighlighted = false}) {
    // FIX: currentShape.name ki jagah _shapeList[_selectedShapeIndex].name use kiya
    String currentShapeName = _shapeList[_selectedShapeIndex].name;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Yahan dynamic shape icon aayega
              _getResultIcon(currentShapeName, label, isHighlighted),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isHighlighted ? AppColors.cyanColor(context) : AppColors.textGrey(context),
                  fontSize: 15,
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
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
          flex: 6,
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
                        highlightColor: AppColors.orangeColor(context),
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
          flex: 3,
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
              cursorColor: AppColors.orangeColor(context),
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
                    const SizedBox(width: 15),
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
                                  style: TextStyle(
                                    color: AppColors.textColor(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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

  void _showRtSelectorSheet(int inputIndex) {
    List<String> options = ['Side A', 'Side B', 'Hypotenuse', 'Angle A', 'Angle B'];
    String currentSelection = inputIndex == 1 ? _rtType1 : _rtType2;

    _showDynamicInputSelectorSheet(
      options: options,
      currentSelection: currentSelection,
      heightFraction: 0.65,
      // Right triangle mein options zyada hain, isliye bada sheet
      iconBuilder: (opt) => CustomPaint(
        painter: RtInputPainter(
          highlightType: opt,
          baseColor: AppColors.textGrey(context).withOpacity(0.5),
          highlightColor: AppColors.orangeColor(context),
        ),
      ),
      onSelected: (selectedVal) {
        setState(() {
          if (inputIndex == 1) {
            _rtType1 = selectedVal;
          } else {
            _rtType2 = selectedVal;
          }
        });
      },
    );
  }

  // NAYA: Square ka wrapper
  void _showSqSelectorSheet() {
    _showDynamicInputSelectorSheet(
      options: ['Side', 'Area', 'Perimeter'],
      currentSelection: _sqType,
      heightFraction: 0.5,
      // Square mein kam options hain, isliye chhota sheet
      iconBuilder: (opt) => CustomPaint(
        painter: SqInputPainter(
          highlightType: opt,
          baseColor: AppColors.textGrey(context).withOpacity(0.5),
          highlightColor: AppColors.orangeColor(context),
        ),
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
                    width: 24,
                    height: 24,
                    child: CustomPaint(
                      painter: SqInputPainter(
                        highlightType: _sqType,
                        baseColor: AppColors.textGrey(context).withOpacity(0.5),
                        highlightColor: AppColors.orangeColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _sqType,
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
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
              controller: _sqValCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              cursorColor: AppColors.orangeColor(context),
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

  // NAYA: Pentagon ka bottom sheet wrapper[cite: 5]
  void _showPentSelectorSheet() {
    _showDynamicInputSelectorSheet(
      options: ['Side', 'Area', 'Perimeter'],
      currentSelection: _pentType,
      heightFraction: 0.5,
      iconBuilder: (opt) => CustomPaint(
        painter: PentInputPainter(
          highlightType: opt,
          baseColor: AppColors.textGrey(context).withOpacity(0.5),
          highlightColor: AppColors.orangeColor(context),
        ),
      ),
      onSelected: (selectedVal) {
        setState(() => _pentType = selectedVal);
      },
    );
  }

  // NAYA: Pentagon Input Row Builder (Square ki tarah same style)
  Widget _buildPentInputRow() {
    return Row(
      children: [
        // Dropdown Selector Button
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: () => _showPentSelectorSheet(),
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
                      painter: PentInputPainter(
                        highlightType: _pentType,
                        baseColor: AppColors.textGrey(context).withOpacity(0.5),
                        highlightColor: AppColors.orangeColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _pentType,
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey(context), size: 20),
                ],
              ),
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
              controller: _pentValCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              cursorColor: AppColors.orangeColor(context),
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

  // NAYA: Hexagon ka bottom sheet wrapper
  void _showHexSelectorSheet() {
    _showDynamicInputSelectorSheet(
      options: ['Side', 'Area', 'Perimeter'],
      currentSelection: _hexType,
      heightFraction: 0.5,
      iconBuilder: (opt) => CustomPaint(
        painter: HexInputPainter(
          highlightType: opt,
          baseColor: AppColors.textGrey(context).withOpacity(0.5),
          highlightColor: AppColors.orangeColor(context),
        ),
      ),
      onSelected: (selectedVal) {
        setState(() => _hexType = selectedVal);
      },
    );
  }

  // NAYA: Hexagon Input Row Builder
  Widget _buildHexInputRow() {
    return Row(
      children: [
        // Dropdown Selector Button
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: () => _showHexSelectorSheet(),
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
                      painter: HexInputPainter(
                        highlightType: _hexType,
                        baseColor: AppColors.textGrey(context).withOpacity(0.5),
                        highlightColor: AppColors.orangeColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _hexType,
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey(context), size: 20),
                ],
              ),
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
              controller: _hexValCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              cursorColor: AppColors.orangeColor(context),
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

  // NAYA: Circle ka bottom sheet wrapper[cite: 7]
  void _showCircSelectorSheet() {
    _showDynamicInputSelectorSheet(
      options: ['Radius', 'Diameter', 'Area', 'Circumference'],
      // Screenshot wale 4 options[cite: 7]
      currentSelection: _circleType,
      heightFraction: 0.55,
      // 4 options ke liye thoda sa bada sheet
      iconBuilder: (opt) => CustomPaint(
        painter: CircInputPainter(
          highlightType: opt,
          baseColor: AppColors.textGrey(context).withOpacity(0.5),
          highlightColor: AppColors.orangeColor(context),
        ),
      ),
      onSelected: (selectedVal) {
        setState(() => _circleType = selectedVal);
      },
    );
  }

  // NAYA: Circle Input Row Builder
  Widget _buildCircInputRow() {
    return Row(
      children: [
        // Dropdown Selector Button
        Expanded(
          flex: 4,
          child: GestureDetector(
            onTap: () => _showCircSelectorSheet(),
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
                      painter: CircInputPainter(
                        highlightType: _circleType,
                        baseColor: AppColors.textGrey(context).withOpacity(0.5),
                        highlightColor: AppColors.orangeColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      _circleType,
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey(context), size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // TextField Box
        Expanded(
          flex: 2,
          child: Container(
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
            ),
            child: TextField(
              controller: _circleValCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              cursorColor: AppColors.orangeColor(context),
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
}

/// main class

// NAYA: Normal Triangle ke specifically selected side ko highlight karne ke liye Painter
class TriInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  TriInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

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

    Offset pTop = Offset(size.width / 2, 0);
    Offset pBottomLeft = Offset(0, size.height);
    Offset pBottomRight = Offset(size.width, size.height);

    // Base Triangle Draw karein
    Path path = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pBottomLeft.dx, pBottomLeft.dy)
      ..lineTo(pBottomRight.dx, pBottomRight.dy)
      ..close();
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
      // } else if (highlightType == 'Angle A') {
      //   Paint fillHl = Paint()
      //     ..color = highlightColor
      //     ..style = PaintingStyle.fill;
      //   canvas.drawArc(Rect.fromCircle(center: pTop, radius: 10), 0, pi / 2, true, fillHl);
      // } else if (highlightType == 'Angle B') {
      //   Paint fillHl = Paint()
      //     ..color = highlightColor
      //     ..style = PaintingStyle.fill;
      //   canvas.drawArc(Rect.fromCircle(center: pBottomRight, radius: 10), pi, -pi / 4, true, fillHl);
      // }
    } else if (highlightType == 'Angle A') {
      Paint fillHl = Paint()
        ..color = highlightColor
        ..style = PaintingStyle.fill;

      // Angle A (Top): Hypotenuse se shuru karke vertical line (90 degree) tak sweep karega
      double startAngle = atan2(size.height, size.width);
      double sweepAngle = (pi / 2) - startAngle;

      canvas.drawArc(Rect.fromCircle(center: pTop, radius: 8), startAngle, sweepAngle, true, fillHl);
    } else if (highlightType == 'Angle B') {
      Paint fillHl = Paint()
        ..color = highlightColor
        ..style = PaintingStyle.fill;

      // FIX: startAngle pi (180 degree, Left) rahega.
      // Par sweepAngle positive hoga taaki arc triangle ke andar (upar) draw ho.
      double startAngle = pi;
      double sweepAngle = atan2(size.height, size.width);

      canvas.drawArc(Rect.fromCircle(center: pBottomRight, radius: 8), startAngle, sweepAngle, true, fillHl);
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
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    Paint hlPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (highlightType == 'Area') {
      canvas.drawRect(rect, fillPaint); // Area select hone par fill hoga[cite: 5]
    } else if (highlightType == 'Perimeter') {
      canvas.drawRect(
        rect,
        Paint()
          ..color = highlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      ); // Perimeter mein pura border highlight hoga[cite: 5]
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
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    Paint hlPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Rectangle draw karne ke liye thoda chauda (wide) box banayenge
    Rect rect = Rect.fromLTWH(0, size.height * 0.25, size.width, size.height * 0.5);

    // Base Rectangle Draw karein
    canvas.drawRect(rect, basePaint);

    // Selected Part Highlight Karein
    if (highlightType == 'Length') {
      canvas.drawLine(Offset(0, rect.bottom), Offset(size.width, rect.bottom), hlPaint); // Niche wali lambi line
    } else if (highlightType == 'Width') {
      canvas.drawLine(
        Offset(size.width, rect.top),
        Offset(size.width, rect.bottom),
        hlPaint,
      ); // Right side wali choti line
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
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    Paint hlPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

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
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    Paint hlPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

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

// NAYA: Circle Arc ke radius aur angle ko highlight karne ke liye Painter
// class ArcInputPainter extends CustomPainter {
//   final String highlightType;
//   final Color baseColor;
//   final Color highlightColor;
//
//   ArcInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint basePaint = Paint()
//       ..color = baseColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;
//     Paint hlPaint = Paint()
//       ..color = highlightColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0;
//
//     double w = size.width;
//     double h = size.height;
//
//     Offset center = Offset(0, h); // Bottom-left as center
//     Rect rect = Rect.fromCircle(center: center, radius: w);
//
//     // Base Arc Sector Draw karein (Quarter circle jaisa)
//     Path path = Path()
//       ..moveTo(center.dx, center.dy)
//       ..lineTo(center.dx, 0)
//       ..arcToPoint(Offset(w, h), radius: Radius.circular(w), clockwise: true)
//       ..close();
//     canvas.drawPath(path, basePaint);
//
//     // Selected Part Highlight Karein
//     if (highlightType == 'Radius') {
//       canvas.drawLine(center, Offset(w, h), hlPaint); // Bottom radius line
//     } else if (highlightType == 'Angle') {
//       // Chota arc draw karein angle dikhane ke liye
//       Paint fillHl = Paint()
//         ..color = highlightColor
//         ..style = PaintingStyle.fill;
//       canvas.drawArc(Rect.fromCircle(center: center, radius: 10), -pi / 2, pi / 2, true, fillHl);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class ArcInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  ArcInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

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

    // NAYA: Area fill karne ke liye paint
    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;

    Offset center = Offset(0, h); // Bottom-left as center

    // Base Arc Sector Draw karein (Quarter circle jaisa)
    Path path = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx, 0)
      ..arcToPoint(Offset(w, h), radius: Radius.circular(w), clockwise: true)
      ..close();

    // Selected Part Highlight Karein
    if (highlightType == 'Sector Area') {
      canvas.drawPath(path, fillPaint); // Area mein fill hoga
    } else if (highlightType == 'Sector Perimeter') {
      canvas.drawPath(path, hlPaint); // Perimeter mein pura border
    } else {
      // Baaki sabke liye pehle base shape draw hoga
      canvas.drawPath(path, basePaint);

      if (highlightType == 'Radius') {
        canvas.drawLine(center, Offset(w, h), hlPaint); // Bottom radius line
      } else if (highlightType == 'Angle') {
        Paint fillHl = Paint()
          ..color = highlightColor
          ..style = PaintingStyle.fill;
        canvas.drawArc(Rect.fromCircle(center: center, radius: 10), -pi / 2, pi / 2, true, fillHl);
      } else if (highlightType == 'Arc Length') {
        canvas.drawArc(Rect.fromCircle(center: center, radius: w), -pi / 2, pi / 2, false, hlPaint); // Sirf curve highlight hoga
      } else if (highlightType == 'Chord Length') {
        canvas.drawLine(Offset(0, 0), Offset(w, h), hlPaint); // Top-left se bottom-right straight line
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// NAYA: Ellipse ke Radius A (Horizontal) aur Radius B (Vertical) ko highlight karne ke liye Painter
// class EllipInputPainter extends CustomPainter {
//   final String highlightType;
//   final Color baseColor;
//   final Color highlightColor;
//
//   EllipInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint basePaint = Paint()
//       ..color = baseColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;
//     Paint hlPaint = Paint()
//       ..color = highlightColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0;
//
//     double w = size.width;
//     double h = size.height;
//
//     Rect rect = Rect.fromLTWH(0, h * 0.2, w, h * 0.6);
//     Offset center = Offset(w / 2, h / 2);
//
//     // Base Ellipse Draw karein
//     canvas.drawOval(rect, basePaint);
//
//     // Selected Part Highlight Karein
//     if (highlightType == 'Radius A') {
//       canvas.drawLine(center, Offset(w, h / 2), hlPaint); // Horizontal Radius
//     } else if (highlightType == 'Radius B') {
//       canvas.drawLine(center, Offset(w / 2, h * 0.2), hlPaint); // Vertical Radius
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class EllipInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  EllipInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()..color = baseColor..style = PaintingStyle.stroke..strokeWidth = 2.0;
    Paint hlPaint = Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 3.0;
    Paint fillPaint = Paint()..color = highlightColor.withOpacity(0.6)..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;

    Rect rect = Rect.fromLTWH(0, h * 0.2, w, h * 0.6);
    Offset center = Offset(w / 2, h / 2);

    // Selected Part Highlight Karein (Pehle Area/Perimeter check karenge)
    if (highlightType == 'Area') {
      canvas.drawOval(rect, fillPaint); // Area ke liye andar fill karega
    } else if (highlightType.contains('Perimeter')) {
      canvas.drawOval(rect, hlPaint); // Perimeter ke liye pura border highlight
    } else {
      // Agar Radius A ya B hai, toh base oval draw karke sirf line banayenge
      canvas.drawOval(rect, basePaint);
      if (highlightType == 'Radius A') {
        canvas.drawLine(center, Offset(w, h / 2), hlPaint); // Horizontal Radius
      } else if (highlightType == 'Radius B') {
        canvas.drawLine(center, Offset(w / 2, h * 0.2), hlPaint); // Vertical Radius
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// NAYA: Pentagon ke selected part ko highlight karne ke liye Painter
// class PentInputPainter extends CustomPainter {
//   final String highlightType;
//   final Color baseColor;
//   final Color highlightColor;
//
//   PentInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint basePaint = Paint()
//       ..color = baseColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;
//     Paint hlPaint = Paint()
//       ..color = highlightColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0;
//     Paint fillPaint = Paint()
//       ..color = highlightColor.withOpacity(0.6)
//       ..style = PaintingStyle.fill;
//
//     double w = size.width;
//     double h = size.height;
//
//     // Pentagon ke 5 points mathematically set kiye gaye hain
//     Offset p1 = Offset(w / 2, 0); // Top
//     Offset p2 = Offset(w, h * 0.38); // Top Right
//     Offset p3 = Offset(w * 0.81, h); // Bottom Right
//     Offset p4 = Offset(w * 0.19, h); // Bottom Left
//     Offset p5 = Offset(0, h * 0.38); // Top Left
//
//     // Base Pentagon Draw karein
//     Path path = Path()
//       ..moveTo(p1.dx, p1.dy)
//       ..lineTo(p2.dx, p2.dy)
//       ..lineTo(p3.dx, p3.dy)
//       ..lineTo(p4.dx, p4.dy)
//       ..lineTo(p5.dx, p5.dy)
//       ..close();
//
//     // Selected Part Highlight Karein
//     if (highlightType == 'Area') {
//       canvas.drawPath(path, fillPaint); // Area select hone par fill hoga[cite: 5]
//     } else if (highlightType == 'Perimeter') {
//       canvas.drawPath(
//         path,
//         Paint()
//           ..color = highlightColor
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 2.5,
//       ); // Pura border[cite: 5]
//     } else {
//       // Side: Sirf bottom ki line highlight hogi[cite: 5]
//       canvas.drawPath(path, basePaint);
//       canvas.drawLine(p4, p3, hlPaint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class PentInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  PentInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

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
    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;

    // Pentagon ke 5 points mathematically set kiye gaye hain
    Offset p1 = Offset(w / 2, 0); // Top
    Offset p2 = Offset(w, h * 0.38); // Top Right
    Offset p3 = Offset(w * 0.81, h); // Bottom Right
    Offset p4 = Offset(w * 0.19, h); // Bottom Left
    Offset p5 = Offset(0, h * 0.38); // Top Left

    // Base Pentagon Draw karein
    Path path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..lineTo(p5.dx, p5.dy)
      ..close();

    // Selected Part Highlight Karein
    if (highlightType == 'Area') {
      canvas.drawPath(path, fillPaint); // Area select hone par fill hoga
    } else if (highlightType == 'Perimeter') {
      canvas.drawPath(
        path,
        Paint()
          ..color = highlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      ); // Pura border
    } else {
      // Baaki sabke liye pehle base shape draw hoga
      canvas.drawPath(path, basePaint);

      if (highlightType == 'Side' || highlightType == 'Side (Edge)') {
        canvas.drawLine(p4, p3, hlPaint); // Bottom line highlight
      } else if (highlightType == 'Diagonal') {
        canvas.drawLine(p1, p3, hlPaint); // Top se Bottom-Right diagonal highlight
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// NAYA: Hexagon ke selected part ko highlight karne ke liye Painter
// class HexInputPainter extends CustomPainter {
//   final String highlightType;
//   final Color baseColor;
//   final Color highlightColor;
//
//   HexInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint basePaint = Paint()
//       ..color = baseColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;
//     Paint hlPaint = Paint()
//       ..color = highlightColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0;
//     Paint fillPaint = Paint()
//       ..color = highlightColor.withOpacity(0.6)
//       ..style = PaintingStyle.fill;
//
//     double w = size.width;
//     double h = size.height;
//
//     // Hexagon ke 6 points
//     Offset p1 = Offset(w / 2, 0); // Top
//     Offset p2 = Offset(w, h * 0.25); // Top Right
//     Offset p3 = Offset(w, h * 0.75); // Bottom Right
//     Offset p4 = Offset(w / 2, h); // Bottom
//     Offset p5 = Offset(0, h * 0.75); // Bottom Left
//     Offset p6 = Offset(0, h * 0.25); // Top Left
//
//     // Base Hexagon Draw karein
//     Path path = Path()
//       ..moveTo(p1.dx, p1.dy)
//       ..lineTo(p2.dx, p2.dy)
//       ..lineTo(p3.dx, p3.dy)
//       ..lineTo(p4.dx, p4.dy)
//       ..lineTo(p5.dx, p5.dy)
//       ..lineTo(p6.dx, p6.dy)
//       ..close();
//
//     // Selected Part Highlight Karein
//     if (highlightType == 'Area') {
//       canvas.drawPath(path, fillPaint); // Area select hone par fill hoga[cite: 6]
//     } else if (highlightType == 'Perimeter') {
//       canvas.drawPath(
//         path,
//         Paint()
//           ..color = highlightColor
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 2.5,
//       ); // Pura border highlight hoga[cite: 6]
//     } else {
//       // Side: Sirf bottom-right ki line highlight hogi image ki tarah[cite: 6]
//       canvas.drawPath(path, basePaint);
//       canvas.drawLine(p3, p4, hlPaint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class HexInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  HexInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

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
    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;

    // Hexagon ke 6 points
    Offset p1 = Offset(w / 2, 0); // Top
    Offset p2 = Offset(w, h * 0.25); // Top Right
    Offset p3 = Offset(w, h * 0.75); // Bottom Right
    Offset p4 = Offset(w / 2, h); // Bottom
    Offset p5 = Offset(0, h * 0.75); // Bottom Left
    Offset p6 = Offset(0, h * 0.25); // Top Left

    // Base Hexagon Draw karein
    Path path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..lineTo(p5.dx, p5.dy)
      ..lineTo(p6.dx, p6.dy)
      ..close();

    // Selected Part Highlight Karein
    if (highlightType == 'Area') {
      canvas.drawPath(path, fillPaint); // Area ke liye andar fill hoga[cite: 3]
    } else if (highlightType == 'Perimeter') {
      canvas.drawPath(
        path,
        Paint()
          ..color = highlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      ); // Perimeter ke liye pura border highlight hoga[cite: 3]
    } else {
      // Baaki sabke liye pehle base shape draw hoga
      canvas.drawPath(path, basePaint);

      if (highlightType == 'Side' || highlightType == 'Side (Edge)') {
        canvas.drawLine(p3, p4, hlPaint); // Bottom-right ki line highlight hogi[cite: 3]
      } else if (highlightType == 'Long Diagonal') {
        canvas.drawLine(p1, p4, hlPaint); // Top se Bottom tak straight vertical line
      } else if (highlightType == 'Short Diagonal') {
        canvas.drawLine(p6, p2, hlPaint); // Top-Left se Top-Right tak horizontal line
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// NAYA: Circle ke selected part ko highlight karne ke liye Painter
class CircInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  CircInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

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
    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;
    Offset center = Offset(w / 2, h / 2);
    double radius = w / 2;

    // Base Circle Draw karein
    canvas.drawCircle(center, radius, basePaint);

    // Selected Part Highlight Karein
    if (highlightType == 'Area') {
      canvas.drawCircle(center, radius, fillPaint); // Area select hone par fill hoga[cite: 7]
    } else if (highlightType == 'Circumference') {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = highlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      ); // Pura border[cite: 7]
    } else if (highlightType == 'Radius') {
      // Radius: Center se edge tak ek line[cite: 7]
      canvas.drawLine(center, Offset(w, h / 2), hlPaint);
    } else if (highlightType == 'Diameter') {
      // Diameter: Ek edge se dusre edge tak center ke through[cite: 7]
      canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), hlPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
