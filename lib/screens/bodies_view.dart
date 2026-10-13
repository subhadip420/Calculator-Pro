import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../custom_top_bar.dart';
import '../widgets/shape_selector_sheet.dart';

// 3D shapes ke liye item model
class BodyShapeItem {
  final String name;
  final Widget iconBuilder;
  BodyShapeItem({required this.name, required this.iconBuilder});
}

class BodiesView extends StatefulWidget {
  final VoidCallback onBack;

  const BodiesView({super.key, required this.onBack});

  @override
  State<BodiesView> createState() => _BodiesViewState();
}

class _BodiesViewState extends State<BodiesView> {
  bool _isHapticsEnabled = true;
  int _selectedShapeIndex = 0;
  List<BodyShapeItem> _shapeList = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Yahan saare 11 3D shapes load honge
    if (_shapeList.isEmpty) {
      Color iconColor = AppColors.cyanColor(context);

      _shapeList = [
        BodyShapeItem(name: 'Cube', iconBuilder: CustomPaint(painter: CubePainter(color: iconColor))),
        BodyShapeItem(name: 'Prism', iconBuilder: CustomPaint(painter: PrismPainter(color: iconColor))),
        BodyShapeItem(name: 'Pyramid', iconBuilder: CustomPaint(painter: PyramidPainter(color: iconColor))),
        BodyShapeItem(name: 'Pyramid frustum', iconBuilder: CustomPaint(painter: PyrFrustumPainter(color: iconColor))),
        BodyShapeItem(name: 'Cone', iconBuilder: CustomPaint(painter: ConePainter(color: iconColor))),
        BodyShapeItem(name: 'Cone frustum', iconBuilder: CustomPaint(painter: ConeFrustumPainter(color: iconColor))),
        BodyShapeItem(name: 'Cylinder', iconBuilder: CustomPaint(painter: CylinderPainter(color: iconColor))),
        BodyShapeItem(name: 'Sphere', iconBuilder: CustomPaint(painter: SpherePainter(color: iconColor))),
        BodyShapeItem(name: 'Sphere cap', iconBuilder: CustomPaint(painter: SphereCapPainter(color: iconColor))),
        BodyShapeItem(name: 'Sphere segment', iconBuilder: CustomPaint(painter: SphereSegPainter(color: iconColor))),
        BodyShapeItem(name: 'Ellipsoid', iconBuilder: CustomPaint(painter: EllipsoidPainter(color: iconColor))),
      ];
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

  @override
  Widget build(BuildContext context) {
    if (_shapeList.isEmpty) return const SizedBox();

    var currentShape = _shapeList[_selectedShapeIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          CustomTopBar(
            toolId: 'bodies',
            title: 'Bodies',
            iconPath: 'assets/images/percentage-discount-symbol.png',
            onBack: widget.onBack,
            isHapticsEnabled: _isHapticsEnabled,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // --- SELECTOR CARD ---
                  GestureDetector(
                    onTap: () {
                      // NAYA: Ab yeh directly aapki external 'shape_selector_sheet.dart' file wale function ko call karega
                      showShapeSelectorGrid(
                        context: context,
                        shapeList: _shapeList,
                        selectedShapeIndex: _selectedShapeIndex,
                        isHapticsEnabled: _isHapticsEnabled,
                        onShapeSelected: (int newIndex) {
                          setState(() {
                            _selectedShapeIndex = newIndex;
                          });
                        }, title: 'Select Bodies',
                      );
                    },
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
                          // FIX: Container ko SizedBox banaya aur alignment hata diya
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: currentShape.iconBuilder,
                          ),
                          const SizedBox(width: 16),
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
                          Container(height: 30, width: 1, color: AppColors.textGrey(context).withOpacity(0.4)),
                          const SizedBox(width: 12),
                          Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey(context), size: 28),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.construction_rounded, size: 48, color: AppColors.textGrey(context).withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          '${currentShape.name} Inputs & Results\nComing Soon...',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textGrey(context), fontSize: 16),
                        ),
                      ],
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

// ==========================================
// 3D SHAPE PAINTERS
// ==========================================

class CubePainter extends CustomPainter {
  final Color color;
  CubePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    double w = size.width, h = size.height, off = w * 0.3;
    canvas.drawRect(Rect.fromLTWH(off, 0, w - off, h - off), p); // Back
    canvas.drawRect(Rect.fromLTWH(0, off, w - off, h - off), p); // Front
    canvas.drawLine(Offset(0, off), Offset(off, 0), p);
    canvas.drawLine(Offset(w - off, off), Offset(w, 0), p);
    canvas.drawLine(Offset(0, h), Offset(off, h - off), p);
    canvas.drawLine(Offset(w - off, h), Offset(w, h - off), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class PrismPainter extends CustomPainter {
  final Color color;
  PrismPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    double w = size.width, h = size.height, offX = w * 0.3, offY = h * 0.3;
    canvas.drawRect(Rect.fromLTWH(offX, 0, w - offX, h - offY), p);
    canvas.drawRect(Rect.fromLTWH(0, offY, w - offX, h - offY), p);
    canvas.drawLine(Offset(0, offY), Offset(offX, 0), p);
    canvas.drawLine(Offset(w - offX, offY), Offset(w, 0), p);
    canvas.drawLine(Offset(0, h), Offset(offX, h - offY), p);
    canvas.drawLine(Offset(w - offX, h), Offset(w, h - offY), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class PyramidPainter extends CustomPainter {
  final Color color;
  PyramidPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    double w = size.width, h = size.height;
    Offset apex = Offset(w / 2, 0);
    Offset bL = Offset(0, h * 0.8), bR = Offset(w * 0.7, h), bBack = Offset(w, h * 0.6);
    canvas.drawLine(bL, bR, p); canvas.drawLine(bR, bBack, p); canvas.drawLine(bBack, bL, p);
    canvas.drawLine(apex, bL, p); canvas.drawLine(apex, bR, p); canvas.drawLine(apex, bBack, p);
    canvas.drawLine(apex, Offset((bL.dx + bBack.dx)/2, (bL.dy + bBack.dy)/2), Paint()..color=color.withOpacity(0.3)..style=PaintingStyle.stroke);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class PyrFrustumPainter extends CustomPainter {
  final Color color;
  PyrFrustumPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    double w = size.width, h = size.height;
    Path path = Path()
      ..moveTo(w*0.3, h*0.2)
      ..lineTo(w*0.7, h*0.2)
      ..lineTo(w, h)
      ..lineTo(0, h*0.8)
      ..close();
    canvas.drawPath(path, p);
    canvas.drawLine(Offset(0, h*0.8), Offset(w*0.3, h*0.2), p);
    canvas.drawLine(Offset(w, h), Offset(w*0.7, h*0.2), p);
    canvas.drawLine(Offset(0, h*0.8), Offset(w*0.6, h*0.7), p);
    canvas.drawLine(Offset(w, h), Offset(w*0.6, h*0.7), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class ConePainter extends CustomPainter {
  final Color color;
  ConePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    double w = size.width, h = size.height;
    Rect base = Rect.fromLTWH(0, h * 0.75, w, h * 0.25);
    canvas.drawOval(base, p);
    canvas.drawLine(Offset(w / 2, 0), Offset(0, h * 0.875), p);
    canvas.drawLine(Offset(w / 2, 0), Offset(w, h * 0.875), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class ConeFrustumPainter extends CustomPainter {
  final Color color;
  ConeFrustumPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    double w = size.width, h = size.height;
    canvas.drawOval(Rect.fromLTWH(w*0.2, 0, w*0.6, h*0.2), p);
    canvas.drawOval(Rect.fromLTWH(0, h*0.8, w, h*0.2), p);
    canvas.drawLine(Offset(w*0.2, h*0.1), Offset(0, h*0.9), p);
    canvas.drawLine(Offset(w*0.8, h*0.1), Offset(w, h*0.9), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class CylinderPainter extends CustomPainter {
  final Color color;
  CylinderPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    double w = size.width, h = size.height;
    canvas.drawOval(Rect.fromLTWH(0, 0, w, h*0.2), p);
    canvas.drawArc(Rect.fromLTWH(0, h*0.8, w, h*0.2), 0, 3.14159, false, p);
    canvas.drawLine(Offset(0, h*0.1), Offset(0, h*0.9), p);
    canvas.drawLine(Offset(w, h*0.1), Offset(w, h*0.9), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class SpherePainter extends CustomPainter {
  final Color color;
  SpherePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    Offset c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width / 2, p);
    canvas.drawOval(Rect.fromCenter(center: c, width: size.width, height: size.height * 0.3), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class SphereCapPainter extends CustomPainter {
  final Color color;
  SphereCapPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    double w = size.width, h = size.height;
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h*1.5), 3.14159, 3.14159, false, p);
    canvas.drawOval(Rect.fromLTWH(0, h*0.6, w, h*0.3), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class SphereSegPainter extends CustomPainter {
  final Color color;
  SphereSegPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    double w = size.width, h = size.height;
    canvas.drawOval(Rect.fromLTWH(w*0.1, 0, w*0.8, h*0.25), p);
    canvas.drawOval(Rect.fromLTWH(0, h*0.75, w, h*0.25), p);
    canvas.drawArc(Rect.fromLTWH(-w*0.2, 0, w*1.4, h), 2.5, 1.2, false, p);
    canvas.drawArc(Rect.fromLTWH(-w*0.2, 0, w*1.4, h), -0.6, 1.2, false, p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class EllipsoidPainter extends CustomPainter {
  final Color color;
  EllipsoidPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    double w = size.width, h = size.height;
    canvas.drawOval(Rect.fromLTWH(0, h*0.2, w, h*0.6), p);
    canvas.drawOval(Rect.fromLTWH(0, h*0.35, w, h*0.3), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}