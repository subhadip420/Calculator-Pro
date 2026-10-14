import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String _cubeInputType = 'Side'; // Default input type
  final TextEditingController _cubeValCtrl = TextEditingController();

  String _sphereInputType = 'Radius'; // Image ke hisaab se default options
  final TextEditingController _sphereValCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  String _getBodyHintMessage(String shapeName) {
    switch (shapeName) {
      case 'Cube':
        return 'Solve a cube knowing its edge length.';
      case 'Prism':
        return 'Solve a prism knowing its base dimensions and height.';
      case 'Pyramid':
        return 'Solve a pyramid knowing its base dimensions and height.';
      case 'Pyramid frustum':
        return 'Solve a pyramid frustum knowing its base edges and height.';
      case 'Cone':
        return 'Solve a cone knowing its base radius and height.';
      case 'Cone frustum':
        return 'Solve a cone frustum knowing its base radii and height.';
      case 'Cylinder':
        return 'Solve a cylinder knowing its base radius and height.';
      case 'Sphere':
        return 'Solve a sphere knowing its radius.';
      case 'Sphere cap':
        return 'Solve a sphere cap knowing its radius and height.';
      case 'Sphere segment':
        return 'Solve a sphere segment knowing its radii and height.';
      case 'Ellipsoid':
        return 'Solve an ellipsoid knowing its semi-axes.';
      default:
      // Agar koi future shape add hota hai, toh default message aayega
        return 'Solve a ${shapeName.toLowerCase()} knowing its parameters.';
    }
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

                  // --- TITLE ---
                  Text(
                    'Select Bodies',
                    style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

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

                  const SizedBox(height: 24),

                  /// ==========================================
                  /// YAHAN SE CUBE KA CODE ADD KAREIN
                  /// ==========================================
                  if (currentShape.name == 'Cube') ...[
                    Builder(
                      builder: (context) {
                        double val = double.tryParse(_cubeValCtrl.text) ?? 0;
                        double side = 0, volume = 0, totalArea = 0, lateralArea = 0, diagFace = 0, diagSpace = 0;
                        bool isValid = false;
                        String errorMsg = '';

                        if (val > 0) {
                          // Reverse Engineering the Side (a) based on input type
                          if (_cubeInputType == 'Side') {
                            side = val;
                          } else if (_cubeInputType == 'Total area') {
                            side = sqrt(val / 6); // Area = 6a² => a = √(Area/6)
                          } else if (_cubeInputType == 'Lateral area') {
                            side = sqrt(val / 4); // Lat Area = 4a² => a = √(Area/4)
                          } else if (_cubeInputType == 'Volume') {
                            side = pow(val, 1 / 3).toDouble(); // Volume = a³ => a = ∛Volume
                          }

                          // Jab Side mil gayi, toh baaki sab asani se nikal aayega
                          volume = pow(side, 3).toDouble();
                          totalArea = 6 * side * side;
                          lateralArea = 4 * side * side;
                          diagFace = side * sqrt(2); // Face diagonal (d)
                          diagSpace = side * sqrt(3); // Space/Main diagonal (D)

                          isValid = true;
                        } else if (_cubeValCtrl.text.isNotEmpty) {
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

                            // Cube ka dynamic input row
                            _buildCubeInputRow(),
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
                                    _getBodyHintMessage(currentShape.name), // 3D Hint Method
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

                                  if (!isValid && _cubeValCtrl.text.isNotEmpty)
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
                                  else if (isValid) ...[
                                    // Primary Results (Highlighted)
                                    _buildResultRow('Volume', volume.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Total area', totalArea.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Lateral area', lateralArea.toStringAsFixed(2), isHighlighted: true),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),

                                    // Secondary Results
                                    _buildResultRow('Side', side.toStringAsFixed(2)),
                                    _buildResultRow('Face Diagonal', diagFace.toStringAsFixed(2)),
                                    _buildResultRow('Space Diagonal', diagSpace.toStringAsFixed(2)),
                                  ] else ...[
                                    // Jab input khali ho tab placeholder text
                                    Center(
                                        child: Text(
                                          'Enter a value to see results.',
                                          style: TextStyle(color: AppColors.textGrey(context), fontSize: 14),
                                        )
                                    )
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
                  /// YAHAN SE SPHERE KA CODE ADD KAREIN
                  /// ==========================================
                  else if (currentShape.name == 'Sphere') ...[
                    Builder(
                      builder: (context) {
                        double val = double.tryParse(_sphereValCtrl.text) ?? 0;
                        double radius = 0, diameter = 0, area = 0, volume = 0;
                        bool isValid = false;
                        String errorMsg = '';

                        if (val > 0) {
                          // Reverse Engineering the Radius based on input type
                          if (_sphereInputType == 'Radius') {
                            radius = val;
                          } else if (_sphereInputType == 'Area') {
                            // Area = 4 * pi * r² => r = √(Area / (4*pi))
                            radius = sqrt(val / (4 * pi));
                          } else if (_sphereInputType == 'Volume') {
                            // Volume = (4/3) * pi * r³ => r = ∛(3*Volume / (4*pi))
                            radius = pow((3 * val) / (4 * pi), 1 / 3).toDouble();
                          }

                          // Calculate baaki saari values
                          diameter = 2 * radius;
                          area = 4 * pi * radius * radius;
                          volume = (4 / 3) * pi * pow(radius, 3);

                          isValid = true;
                        } else if (_sphereValCtrl.text.isNotEmpty) {
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

                            _buildSphereInputRow(),
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
                                    _getBodyHintMessage(currentShape.name),
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

                                  if (!isValid && _sphereValCtrl.text.isNotEmpty)
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
                                  else if (isValid) ...[
                                    // Primary Results
                                    _buildResultRow('Volume', volume.toStringAsFixed(2), isHighlighted: true),
                                    _buildResultRow('Area', area.toStringAsFixed(2), isHighlighted: true),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                    ),

                                    // Secondary Results
                                    _buildResultRow('Radius', radius.toStringAsFixed(2)),
                                    _buildResultRow('Diameter', diameter.toStringAsFixed(2)),
                                  ] else ...[
                                    Center(
                                        child: Text(
                                          'Enter a value to see results.',
                                          style: TextStyle(color: AppColors.textGrey(context), fontSize: 14),
                                        )
                                    )
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  /// end main build widget

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

  // NAYA: 3D Bodies ke liye Dynamic Bottom Sheet
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
          height: MediaQuery.of(context).size.height * heightFraction, // FIX: '*' multiply ka sign missing tha
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
                      'Select Input',
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

                    // 3D mein split ki utni zarurat nahi, kyunki names mostly 'Radius', 'Height' aise simple honge.
                    // Par agar "Radius 1", "Radius 2" hue toh yeh logic kaam aa jayega.
                    List<String> parts = opt.split(' ');
                    String mTitle = parts[0];
                    String sTitle = parts.length > 1 ? parts.sublist(1).join(' ') : '';

                    return GestureDetector(
                      onTap: () {
                        if (_isHapticsEnabled) HapticFeedback.selectionClick();
                        onSelected(opt);
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
                            // 3D icon yahan draw hoga
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
                            const Spacer(),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: AppColors.cyanColor(context), size: 20),
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

  // NAYA: 3D Bodies ke liye Result Icon Generator
  Widget _getResultIcon(String shapeName, String label, bool isHighlighted) {
    // Highlighted row (jaise Volume) ke liye Cyan color, baaki ke liye Grey
    Color iconColor = isHighlighted ? AppColors.cyanColor(context) : AppColors.textGrey(context).withOpacity(0.8);

    CustomPainter? painter;
    switch (shapeName) {
    // _getResultIcon function mein ise update karein:
      case 'Cube':
        painter = CubeInputPainter(
            highlightType: label,
            baseColor: AppColors.textGrey(context).withOpacity(0.2),
            highlightColor: iconColor
        );
        break;
      case 'Prism': painter = PrismPainter(color: iconColor); break;
      case 'Pyramid': painter = PyramidPainter(color: iconColor); break;
      case 'Pyramid frustum': painter = PyrFrustumPainter(color: iconColor); break;
      case 'Cone': painter = ConePainter(color: iconColor); break;
      case 'Cone frustum': painter = ConeFrustumPainter(color: iconColor); break;
      case 'Cylinder': painter = CylinderPainter(color: iconColor); break;
      case 'Sphere':
        painter = SphereInputPainter( // FIX: SpherePainter ki jagah SphereInputPainter lagaya
          highlightType: label,
          baseColor: AppColors.textGrey(context).withOpacity(0.2),
          highlightColor: iconColor,
        );
        break;
      case 'Sphere cap': painter = SphereCapPainter(color: iconColor); break;
      case 'Sphere segment': painter = SphereSegPainter(color: iconColor); break;
      case 'Ellipsoid': painter = EllipsoidPainter(color: iconColor); break;
    }

    if (painter == null) return const SizedBox.shrink();

    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: painter),
    );
  }

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

  // NAYA: Cube ka dynamic input sheet wrapper
  void _showCubeSelectorSheet() {
    _showDynamicInputSelectorSheet(
      options: ['Side', 'Total area', 'Lateral area', 'Volume'],
      currentSelection: _cubeInputType,
      heightFraction: 0.55, // Cube mein 4 options hain, to thoda height badha diya
      iconBuilder: (opt) => CustomPaint(
        painter: CubeInputPainter(
          highlightType: opt,
          baseColor: AppColors.textGrey(context).withOpacity(0.5),
          highlightColor: AppColors.orangeColor(context),
        ),
      ),
      onSelected: (selectedVal) {
        setState(() => _cubeInputType = selectedVal);
      },
    );
  }
  Widget _buildCubeInputRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Dropdown Selector (Left Side)
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: _showCubeSelectorSheet, // FIX: Direct naya wrapper function call kiya
              behavior: HitTestBehavior.opaque,
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
                      // FIX: Yahan dynamic CubeInputPainter use kiya taaki selected option highlight ho
                      child: CustomPaint(
                        painter: CubeInputPainter(
                          highlightType: _cubeInputType,
                          baseColor: AppColors.textGrey(context).withOpacity(0.5),
                          highlightColor: AppColors.orangeColor(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _cubeInputType,
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
          const SizedBox(width: 12),
          // Input Field (Right Side)
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
                controller: _cubeValCtrl,
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

  // Sphere ka dynamic input sheet wrapper
  void _showSphereSelectorSheet() {
    _showDynamicInputSelectorSheet(
      options: ['Radius', 'Area', 'Volume'], // Image wale 3 options[cite: 4]
      currentSelection: _sphereInputType,
      heightFraction: 0.5,
      iconBuilder: (opt) => CustomPaint(
        painter: SphereInputPainter(
          highlightType: opt,
          baseColor: AppColors.textGrey(context).withOpacity(0.5),
          highlightColor: AppColors.orangeColor(context),
        ),
      ),
      onSelected: (selectedVal) {
        setState(() => _sphereInputType = selectedVal);
      },
    );
  }

// Sphere ka Input Row
  Widget _buildSphereInputRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Dropdown Selector (Left Side)
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: _showSphereSelectorSheet,
              behavior: HitTestBehavior.opaque,
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
                        painter: SphereInputPainter(
                          highlightType: _sphereInputType,
                          baseColor: AppColors.textGrey(context).withOpacity(0.5),
                          highlightColor: AppColors.orangeColor(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _sphereInputType,
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
          const SizedBox(width: 12),
          // Input Field (Right Side)
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
                controller: _sphereValCtrl,
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

class CubeInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  CubeInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Paint hlStrokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    Paint darkFillPaint = Paint()
      ..color = highlightColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;
    double off = w * 0.3; // 3D depth offset

    // Cube ke 8 Points/Vertices mathematically
    Offset fTL = Offset(0, off); // Front Top-Left
    Offset fTR = Offset(w - off, off); // Front Top-Right
    Offset fBL = Offset(0, h); // Front Bottom-Left
    Offset fBR = Offset(w - off, h); // Front Bottom-Right

    Offset bTL = Offset(off, 0); // Back Top-Left
    Offset bTR = Offset(w, 0); // Back Top-Right
    Offset bBL = Offset(off, h - off); // Back Bottom-Left
    Offset bBR = Offset(w, h - off); // Back Bottom-Right

    // Faces ke paths
    Path topFace = Path()..moveTo(fTL.dx, fTL.dy)..lineTo(bTL.dx, bTL.dy)..lineTo(bTR.dx, bTR.dy)..lineTo(fTR.dx, fTR.dy)..close();
    Path rightFace = Path()..moveTo(fTR.dx, fTR.dy)..lineTo(bTR.dx, bTR.dy)..lineTo(bBR.dx, bBR.dy)..lineTo(fBR.dx, fBR.dy)..close();
    Rect frontFace = Rect.fromLTWH(0, off, w - off, h - off);
    Rect backFace = Rect.fromLTWH(off, 0, w - off, h - off);

    // 1. FILL HIGHLIGHTS
    if (highlightType == 'Volume') {
      // Volume me poora andar ka hissa solid fill hoga
      canvas.drawRect(backFace, fillPaint);
      canvas.drawPath(topFace, fillPaint);
      canvas.drawPath(rightFace, fillPaint);
      canvas.drawRect(frontFace, darkFillPaint);
    } else if (highlightType == 'Total area') {
      // Total area me saare visible faces ko light color se fill karenge
      canvas.drawRect(backFace, fillPaint);
      canvas.drawPath(topFace, fillPaint);
      canvas.drawPath(rightFace, fillPaint);
      canvas.drawRect(frontFace, fillPaint);
    } else if (highlightType == 'Lateral area') {
      // Lateral area me sirf side walls (Front aur Right) fill hongi, Top aur Bottom khali rahenge
      canvas.drawPath(rightFace, fillPaint);
      canvas.drawRect(frontFace, darkFillPaint);
    }

    // 2. DRAW BASE CUBE LINES (Edges)
    canvas.drawRect(backFace, highlightType == 'Total area' ? hlStrokePaint : basePaint);
    canvas.drawRect(frontFace, highlightType == 'Total area' ? hlStrokePaint : basePaint);
    canvas.drawLine(fTL, bTL, highlightType == 'Total area' ? hlStrokePaint : basePaint);
    canvas.drawLine(fTR, bTR, highlightType == 'Total area' ? hlStrokePaint : basePaint);
    canvas.drawLine(fBL, bBL, highlightType == 'Total area' ? hlStrokePaint : basePaint);
    canvas.drawLine(fBR, bBR, highlightType == 'Total area' ? hlStrokePaint : basePaint);

    // 3. STROKE HIGHLIGHTS (Lines / Diagonals)
    if (highlightType == 'Side' || highlightType == 'Side (Edge)') {
      // Sirf front bottom edge ko highlight karenge
      canvas.drawLine(fBL, fBR, hlStrokePaint);
    } else if (highlightType == 'Face Diagonal') {
      // Front face ka diagonal (Top-Left se Bottom-Right)
      canvas.drawLine(fTL, fBR, hlStrokePaint);
    } else if (highlightType == 'Space Diagonal') {
      // Body/Space diagonal (Front Bottom-Left se Back Top-Right, Cube ke beech se)
      canvas.drawLine(fBL, bTR, Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SphereInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  SphereInputPainter({
    required this.highlightType,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Paint hlStrokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    Paint areaFillPaint = Paint()
      ..color = highlightColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    Paint volumeFillPaint = Paint()
      ..color = highlightColor.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    // FIX: size.height * 0.35 mein '*' लगा diya hai
    Rect equator = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height * 0.35,
    );

    if (highlightType == 'Area' || highlightType == 'Total area') {
      // Area ke liye solid filled circle
      canvas.drawCircle(center, radius, areaFillPaint);
    } else if (highlightType == 'Volume') {
      // Volume mein solid fill ke upar base border aur equator line
      canvas.drawCircle(center, radius, volumeFillPaint);
      canvas.drawCircle(center, radius, basePaint);
      canvas.drawOval(equator, basePaint);
    } else {
      // Radius aur Diameter ke liye Base sphere
      canvas.drawCircle(center, radius, basePaint);
      canvas.drawOval(equator, basePaint);

      if (highlightType == 'Radius') {
        // Center se top tak single vertical line
        canvas.drawLine(Offset(center.dx, 0), center, hlStrokePaint);
      } else if (highlightType == 'Diameter') {
        // Top se bottom tak full vertical line
        canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), hlStrokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SphereInputPainter oldDelegate) {
    return oldDelegate.highlightType != highlightType ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.highlightColor != highlightColor;
  }
}