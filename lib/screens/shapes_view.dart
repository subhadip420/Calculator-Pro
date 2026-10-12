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
    Paint paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5;
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
    Paint paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5;
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
    Paint paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5;
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
    Paint paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5;
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
    Paint paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5;
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
    Paint paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5;
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
    Paint paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5;
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
    Paint paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5;
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
      ShapeItem('Triangle', CustomPaint(size: Size(s, s), painter: TrianglePainter(color: iconColor))), //[cite: 2]
      ShapeItem('Right triangle', CustomPaint(size: Size(s, s), painter: RightTrianglePainter(color: iconColor))), //[cite: 2]
      ShapeItem('Square', Container(width: s, height: s, decoration: BoxDecoration(border: Border.all(color: iconColor, width: 2.5)))), //[cite: 2]
      ShapeItem('Rectangle', Container(width: s + 10, height: s - 10, decoration: BoxDecoration(border: Border.all(color: iconColor, width: 2.5)))), //[cite: 2]
      ShapeItem('Trapezoid', CustomPaint(size: Size(s, s), painter: TrapezoidPainter(color: iconColor))), //[cite: 2]
      ShapeItem('Rhombus', CustomPaint(size: Size(s, s), painter: RhombusPainter(color: iconColor))), //[cite: 2]
      ShapeItem('Pentagon', CustomPaint(size: Size(s, s), painter: PentagonPainter(color: iconColor))), //[cite: 2]
      ShapeItem('Hexagon', CustomPaint(size: Size(s, s), painter: HexagonPainter(color: iconColor))), //[cite: 2]
      ShapeItem('Circle', Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: iconColor, width: 2.5)))), //[cite: 2]
      ShapeItem('Circle arc', CustomPaint(size: Size(s, s), painter: CircleArcPainter(color: iconColor))), //[cite: 2]
      ShapeItem('Ellipse', CustomPaint(size: Size(s + 10, s), painter: EllipsePainter(color: iconColor))), //[cite: 2]
    ];
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
                style: TextStyle(
                  color: AppColors.textColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                              style: TextStyle(
                                color: AppColors.textGrey(context),
                                fontSize: 11,
                              ),
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
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // --- TITLE ---
                  Text(
                    'Select Shape',
                    style: TextStyle(
                      color: AppColors.textColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                          Container(
                            height: 30,
                            width: 1,
                            color: AppColors.textGrey(context).withOpacity(0.4),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textGrey(context),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Aage ka Result/Calculation UI yahan add karenge...
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      'Inputs for ${currentShape.name} will go here...',
                      style: TextStyle(color: AppColors.textGrey(context)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}