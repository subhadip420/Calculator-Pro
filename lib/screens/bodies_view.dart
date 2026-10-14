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

  final TextEditingController _prismLengthCtrl = TextEditingController();
  final TextEditingController _prismWidthCtrl = TextEditingController();
  final TextEditingController _prismHeightCtrl = TextEditingController();

  final TextEditingController _pyrBaseCtrl = TextEditingController();
  final TextEditingController _pyrHeightCtrl = TextEditingController();

  final TextEditingController _pyrFrustBaseCtrl = TextEditingController();
  final TextEditingController _pyrFrustTopCtrl = TextEditingController();
  final TextEditingController _pyrFrustHeightCtrl = TextEditingController();

  final TextEditingController _coneRadiusCtrl = TextEditingController();
  final TextEditingController _coneHeightCtrl = TextEditingController();

  final TextEditingController _coneFrustHeightCtrl = TextEditingController();
  final TextEditingController _coneFrustTopRadCtrl = TextEditingController();
  final TextEditingController _coneFrustBotRadCtrl = TextEditingController();

  final TextEditingController _cylRadiusCtrl = TextEditingController();
  final TextEditingController _cylHeightCtrl = TextEditingController();

  final TextEditingController _sCapRadiusCtrl = TextEditingController();
  final TextEditingController _sCapHeightCtrl = TextEditingController();

  final TextEditingController _sSegHeightCtrl = TextEditingController();
  final TextEditingController _sSegTopRadCtrl = TextEditingController();
  final TextEditingController _sSegBotRadCtrl = TextEditingController();

  final TextEditingController _ellipsoidRadACtrl = TextEditingController();
  final TextEditingController _ellipsoidRadBCtrl = TextEditingController();
  final TextEditingController _ellipsoidRadCCtrl = TextEditingController();

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
        return 'Solve a cone frustum knowing its two radius and height.';
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
                  /// ==========================================
                  /// YAHAN SE PRISM KA CODE ADD KAREIN
                  /// ==========================================
                  else if (currentShape.name == 'Prism') ...[
                      Builder(
                        builder: (context) {
                          double l = double.tryParse(_prismLengthCtrl.text) ?? 0;
                          double w = double.tryParse(_prismWidthCtrl.text) ?? 0;
                          double h = double.tryParse(_prismHeightCtrl.text) ?? 0;

                          double volume = 0, totalArea = 0, lateralArea = 0, spaceDiagonal = 0;
                          bool isValid = false;

                          if (l > 0 && w > 0 && h > 0) {
                            volume = l * w * h;
                            totalArea = 2 * ((l * w) + (l * h) + (w * h));
                            lateralArea = 2 * ((l * h) + (w * h)); // Top aur bottom face ko chhod kar
                            spaceDiagonal = sqrt((l * l) + (w * w) + (h * h));

                            isValid = true;
                          }

                          bool hasPartialInput = _prismLengthCtrl.text.isNotEmpty ||
                              _prismWidthCtrl.text.isNotEmpty ||
                              _prismHeightCtrl.text.isNotEmpty;

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

                              // 3 Fixed Inputs for Prism
                              _buildFixedInputRow(
                                title: 'Length (l)',
                                ctrl: _prismLengthCtrl,
                                icon: CustomPaint(
                                  painter: PrismInputPainter(
                                    highlightType: 'Length',
                                    baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                    highlightColor: AppColors.orangeColor(context),
                                  ),
                                ),
                              ),
                              _buildFixedInputRow(
                                title: 'Width (w)', // Ye depth ko represent karta hai
                                ctrl: _prismWidthCtrl,
                                icon: CustomPaint(
                                  painter: PrismInputPainter(
                                    highlightType: 'Width',
                                    baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                    highlightColor: AppColors.orangeColor(context),
                                  ),
                                ),
                              ),
                              _buildFixedInputRow(
                                title: 'Height (h)',
                                ctrl: _prismHeightCtrl,
                                icon: CustomPaint(
                                  painter: PrismInputPainter(
                                    highlightType: 'Height',
                                    baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                    highlightColor: AppColors.orangeColor(context),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Dynamic Hint Banner
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _getBodyHintMessage(currentShape.name),
                                      style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15),
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
                                        style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                    const SizedBox(height: 12),

                                    if (!isValid && hasPartialInput)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'Enter values greater than 0 for all three dimensions.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: AppColors.redColor(context).withOpacity(0.9), fontSize: 14),
                                          ),
                                        ),
                                      )
                                    else if (isValid) ...[
                                      _buildResultRow('Volume', volume.toStringAsFixed(2), isHighlighted: true),
                                      _buildResultRow('Total area', totalArea.toStringAsFixed(2), isHighlighted: true),
                                      _buildResultRow('Lateral area', lateralArea.toStringAsFixed(2), isHighlighted: true),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                      ),

                                      _buildResultRow('Space Diagonal', spaceDiagonal.toStringAsFixed(2)),
                                    ] else ...[
                                      Center(
                                          child: Text(
                                            'Enter all values to see results.',
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
                    /// YAHAN SE PYRAMID KA CODE ADD KAREIN
                    /// ==========================================
                    else if (currentShape.name == 'Pyramid') ...[
                        Builder(
                          builder: (context) {
                            double baseSide = double.tryParse(_pyrBaseCtrl.text) ?? 0;
                            double height = double.tryParse(_pyrHeightCtrl.text) ?? 0;

                            double volume = 0, totalArea = 0, lateralArea = 0;
                            double slantHeight = 0, lateralEdge = 0;
                            bool isValid = false;

                            if (baseSide > 0 && height > 0) {
                              // Calculations for Square-based Pyramid
                              volume = (baseSide * baseSide * height) / 3;
                              slantHeight = sqrt((height * height) + ((baseSide / 2) * (baseSide / 2)));
                              lateralEdge = sqrt((height * height) + ((baseSide * baseSide) / 2));
                              lateralArea = 2 * baseSide * slantHeight;
                              totalArea = (baseSide * baseSide) + lateralArea;

                              isValid = true;
                            }

                            bool hasPartialInput = _pyrBaseCtrl.text.isNotEmpty || _pyrHeightCtrl.text.isNotEmpty;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Input',
                                  style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),

                                // 2 Fixed Inputs for Pyramid
                                _buildFixedInputRow(
                                  title: 'Base (a)',
                                  ctrl: _pyrBaseCtrl,
                                  icon: CustomPaint(
                                    painter: PyramidInputPainter(
                                      highlightType: 'Base',
                                      baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                      highlightColor: AppColors.orangeColor(context),
                                    ),
                                  ),
                                ),
                                _buildFixedInputRow(
                                  title: 'Height (h)',
                                  ctrl: _pyrHeightCtrl,
                                  icon: CustomPaint(
                                    painter: PyramidInputPainter(
                                      highlightType: 'Height',
                                      baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                      highlightColor: AppColors.orangeColor(context),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Dynamic Hint Banner
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _getBodyHintMessage(currentShape.name),
                                        style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15),
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
                                          style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                      const SizedBox(height: 12),

                                      if (!isValid && hasPartialInput)
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              'Enter values greater than 0 for both Base and Height.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: AppColors.redColor(context).withOpacity(0.9), fontSize: 14),
                                            ),
                                          ),
                                        )
                                      else if (isValid) ...[
                                        _buildResultRow('Volume', volume.toStringAsFixed(2), isHighlighted: true),
                                        _buildResultRow('Total area', totalArea.toStringAsFixed(2), isHighlighted: true),
                                        _buildResultRow('Lateral area', lateralArea.toStringAsFixed(2), isHighlighted: true),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                        ),

                                        _buildResultRow('Slant height', slantHeight.toStringAsFixed(2)),
                                        _buildResultRow('Lateral edge', lateralEdge.toStringAsFixed(2)),
                                      ] else ...[
                                        Center(
                                            child: Text(
                                              'Enter both values to see results.',
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
                      /// YAHAN SE PYRAMID FRUSTUM KA CODE ADD KAREIN
                      /// ==========================================
                      else if (currentShape.name == 'Pyramid frustum') ...[
                          Builder(
                            builder: (context) {
                              double baseSide = double.tryParse(_pyrFrustBaseCtrl.text) ?? 0; // a
                              double topSide = double.tryParse(_pyrFrustTopCtrl.text) ?? 0;   // b
                              double height = double.tryParse(_pyrFrustHeightCtrl.text) ?? 0; // h

                              double volume = 0, totalArea = 0, lateralArea = 0;
                              double slantHeight = 0, lateralEdge = 0;
                              bool isValid = false;

                              if (baseSide > 0 && topSide > 0 && height > 0) {
                                double diff = (baseSide - topSide).abs();

                                // Volume = (h / 3) * (a² + b² + a*b)
                                volume = (height / 3) * ((baseSide * baseSide) + (topSide * topSide) + (baseSide * topSide));

                                // Slant Height (s) = √(h² + ((a - b) / 2)²)
                                slantHeight = sqrt((height * height) + pow(diff / 2, 2));

                                // Lateral Edge (e) = √(h² + (a - b)² / 2)
                                lateralEdge = sqrt((height * height) + (pow(diff, 2) / 2));

                                // Lateral Area = 2 * (a + b) * s
                                lateralArea = 2 * (baseSide + topSide) * slantHeight;

                                // Total Area = Lateral Area + a² + b²
                                totalArea = lateralArea + (baseSide * baseSide) + (topSide * topSide);

                                isValid = true;
                              }

                              bool hasPartialInput = _pyrFrustBaseCtrl.text.isNotEmpty ||
                                  _pyrFrustTopCtrl.text.isNotEmpty ||
                                  _pyrFrustHeightCtrl.text.isNotEmpty;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Input',
                                    style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),

                                  // 3 Fixed Inputs: Height, Top, Base
                                  _buildFixedInputRow(
                                    title: 'Height (h)',
                                    ctrl: _pyrFrustHeightCtrl,
                                    icon: CustomPaint(
                                      painter: PyrFrustumInputPainter(
                                        highlightType: 'Height',
                                        baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                        highlightColor: AppColors.orangeColor(context),
                                      ),
                                    ),
                                  ),
                                  _buildFixedInputRow(
                                    title: 'Top (b)',
                                    ctrl: _pyrFrustTopCtrl,
                                    icon: CustomPaint(
                                      painter: PyrFrustumInputPainter(
                                        highlightType: 'Top',
                                        baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                        highlightColor: AppColors.orangeColor(context),
                                      ),
                                    ),
                                  ),
                                  _buildFixedInputRow(
                                    title: 'Base (a)',
                                    ctrl: _pyrFrustBaseCtrl,
                                    icon: CustomPaint(
                                      painter: PyrFrustumInputPainter(
                                        highlightType: 'Base',
                                        baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                        highlightColor: AppColors.orangeColor(context),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Dynamic Hint Banner
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _getBodyHintMessage(currentShape.name),
                                          style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15),
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
                                            style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                        const SizedBox(height: 12),

                                        if (!isValid && hasPartialInput)
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Text(
                                                'Enter values greater than 0 for Height, Top, and Base.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: AppColors.redColor(context).withOpacity(0.9), fontSize: 14),
                                              ),
                                            ),
                                          )
                                        else if (isValid) ...[
                                          _buildResultRow('Volume', volume.toStringAsFixed(2), isHighlighted: true),
                                          _buildResultRow('Total area', totalArea.toStringAsFixed(2), isHighlighted: true),
                                          _buildResultRow('Lateral area', lateralArea.toStringAsFixed(2), isHighlighted: true),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                          ),

                                          _buildResultRow('Slant height', slantHeight.toStringAsFixed(2)),
                                          _buildResultRow('Lateral edge', lateralEdge.toStringAsFixed(2)),
                                        ] else ...[
                                          Center(
                                              child: Text(
                                                'Enter all values to see results.',
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
                        /// YAHAN SE CONE KA CODE ADD KAREIN
                        /// ==========================================
                        else if (currentShape.name == 'Cone') ...[
                            Builder(
                              builder: (context) {
                                double radius = double.tryParse(_coneRadiusCtrl.text) ?? 0; // r
                                double height = double.tryParse(_coneHeightCtrl.text) ?? 0; // h

                                double volume = 0, totalArea = 0, lateralArea = 0, baseArea = 0, slantHeight = 0;
                                bool isValid = false;

                                if (radius > 0 && height > 0) {
                                  // Slant Height (s) = √(r² + h²)
                                  slantHeight = sqrt((radius * radius) + (height * height));

                                  // Base Area = π * r²
                                  baseArea = pi * radius * radius;

                                  // Lateral Area = π * r * s
                                  lateralArea = pi * radius * slantHeight;

                                  // Total Area = Base Area + Lateral Area
                                  totalArea = baseArea + lateralArea;

                                  // Volume = (1/3) * π * r² * h
                                  volume = (1 / 3) * baseArea * height;

                                  isValid = true;
                                }

                                bool hasPartialInput = _coneRadiusCtrl.text.isNotEmpty || _coneHeightCtrl.text.isNotEmpty;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Input',
                                      style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),

                                    // 2 Fixed Inputs: Radius and Height
                                    _buildFixedInputRow(
                                      title: 'Radius (r)',
                                      ctrl: _coneRadiusCtrl,
                                      icon: CustomPaint(
                                        painter: ConeInputPainter(
                                          highlightType: 'Radius',
                                          baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                          highlightColor: AppColors.orangeColor(context),
                                        ),
                                      ),
                                    ),
                                    _buildFixedInputRow(
                                      title: 'Height (h)',
                                      ctrl: _coneHeightCtrl,
                                      icon: CustomPaint(
                                        painter: ConeInputPainter(
                                          highlightType: 'Height',
                                          baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                          highlightColor: AppColors.orangeColor(context),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Dynamic Hint Banner
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _getBodyHintMessage(currentShape.name),
                                            style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15),
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
                                              style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                          const SizedBox(height: 12),

                                          if (!isValid && hasPartialInput)
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Text(
                                                  'Enter values greater than 0 for both Radius and Height.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: AppColors.redColor(context).withOpacity(0.9), fontSize: 14),
                                                ),
                                              ),
                                            )
                                          else if (isValid) ...[
                                            _buildResultRow('Volume', volume.toStringAsFixed(2), isHighlighted: true),
                                            _buildResultRow('Total area', totalArea.toStringAsFixed(2), isHighlighted: true),
                                            _buildResultRow('Lateral area', lateralArea.toStringAsFixed(2), isHighlighted: true),

                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                            ),

                                            _buildResultRow('Base area', baseArea.toStringAsFixed(2)),
                                            _buildResultRow('Slant height', slantHeight.toStringAsFixed(2)),
                                          ] else ...[
                                            Center(
                                                child: Text(
                                                  'Enter both values to see results.',
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
                          /// YAHAN SE CONE FRUSTUM KA CODE ADD KAREIN
                          /// ==========================================
                          else if (currentShape.name == 'Cone frustum') ...[
                              Builder(
                                builder: (context) {
                                  double height = double.tryParse(_coneFrustHeightCtrl.text) ?? 0;   // h
                                  double topRad = double.tryParse(_coneFrustTopRadCtrl.text) ?? 0;   // r1 (Top radius)
                                  double botRad = double.tryParse(_coneFrustBotRadCtrl.text) ?? 0;   // r2 (Bottom radius)

                                  double volume = 0, totalArea = 0, lateralArea = 0;
                                  double topArea = 0, baseArea = 0, slantHeight = 0;
                                  bool isValid = false;

                                  if (height > 0 && topRad > 0 && botRad > 0) {
                                    double radDiff = (botRad - topRad).abs();

                                    // Slant Height (s) = √(h² + (r2 - r1)²)
                                    slantHeight = sqrt((height * height) + (radDiff * radDiff));

                                    // Top & Bottom Base Areas
                                    topArea = pi * topRad * topRad;
                                    baseArea = pi * botRad * botRad;

                                    // Lateral Area = π * (r1 + r2) * s
                                    lateralArea = pi * (topRad + botRad) * slantHeight;

                                    // Total Area = Lateral Area + Top Area + Base Area
                                    totalArea = lateralArea + topArea + baseArea;

                                    // Volume = (1/3) * π * h * (r1² + r2² + (r1 * r2))
                                    volume = (1 / 3) * pi * height * ((topRad * topRad) + (botRad * botRad) + (topRad * botRad));

                                    isValid = true;
                                  }

                                  bool hasPartialInput = _coneFrustHeightCtrl.text.isNotEmpty ||
                                      _coneFrustTopRadCtrl.text.isNotEmpty ||
                                      _coneFrustBotRadCtrl.text.isNotEmpty;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Input',
                                        style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 12),

                                      // 3 Fixed Inputs: Height, Top radius, Bottom radius
                                      _buildFixedInputRow(
                                        title: 'Height (h)',
                                        ctrl: _coneFrustHeightCtrl,
                                        icon: CustomPaint(
                                          painter: ConeFrustumInputPainter(
                                            highlightType: 'Height',
                                            baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                            highlightColor: AppColors.orangeColor(context),
                                          ),
                                        ),
                                      ),
                                      _buildFixedInputRow(
                                        title: 'Top radius (r₁)',
                                        ctrl: _coneFrustTopRadCtrl,
                                        icon: CustomPaint(
                                          painter: ConeFrustumInputPainter(
                                            highlightType: 'Top radius',
                                            baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                            highlightColor: AppColors.orangeColor(context),
                                          ),
                                        ),
                                      ),
                                      _buildFixedInputRow(
                                        title: 'Bottom radius (r₂)',
                                        ctrl: _coneFrustBotRadCtrl,
                                        icon: CustomPaint(
                                          painter: ConeFrustumInputPainter(
                                            highlightType: 'Bottom radius',
                                            baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                            highlightColor: AppColors.orangeColor(context),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Dynamic Hint Banner
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _getBodyHintMessage(currentShape.name),
                                              style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15),
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
                                                style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                            const SizedBox(height: 12),

                                            if (!isValid && hasPartialInput)
                                              Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16.0),
                                                  child: Text(
                                                    'Enter values greater than 0 for Height, Top radius, and Bottom radius.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: AppColors.redColor(context).withOpacity(0.9), fontSize: 14),
                                                  ),
                                                ),
                                              )
                                            else if (isValid) ...[
                                              _buildResultRow('Volume', volume.toStringAsFixed(2), isHighlighted: true),
                                              _buildResultRow('Total area', totalArea.toStringAsFixed(2), isHighlighted: true),
                                              _buildResultRow('Lateral area', lateralArea.toStringAsFixed(2), isHighlighted: true),

                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                              ),

                                              _buildResultRow('Top area', topArea.toStringAsFixed(2)),
                                              _buildResultRow('Base area', baseArea.toStringAsFixed(2)),
                                              _buildResultRow('Slant height', slantHeight.toStringAsFixed(2)),
                                            ] else ...[
                                              Center(
                                                  child: Text(
                                                    'Enter all values to see results.',
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
                            /// YAHAN SE CYLINDER KA CODE ADD KAREIN
                            /// ==========================================
                            else if (currentShape.name == 'Cylinder') ...[
                                Builder(
                                  builder: (context) {
                                    double radius = double.tryParse(_cylRadiusCtrl.text) ?? 0; // r
                                    double height = double.tryParse(_cylHeightCtrl.text) ?? 0; // h

                                    double volume = 0, totalArea = 0, lateralArea = 0, baseArea = 0, diameter = 0;
                                    bool isValid = false;

                                    if (radius > 0 && height > 0) {
                                      // Diameter (d) = 2 * r
                                      diameter = 2 * radius;

                                      // Base Area = π * r²
                                      baseArea = pi * radius * radius;

                                      // Lateral Area = 2 * π * r * h
                                      lateralArea = 2 * pi * radius * height;

                                      // Total Area = 2 * Base Area + Lateral Area
                                      totalArea = (2 * baseArea) + lateralArea;

                                      // Volume = π * r² * h
                                      volume = baseArea * height;

                                      isValid = true;
                                    }

                                    bool hasPartialInput = _cylRadiusCtrl.text.isNotEmpty || _cylHeightCtrl.text.isNotEmpty;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Input',
                                          style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 12),

                                        // 2 Fixed Inputs: Radius and Height
                                        _buildFixedInputRow(
                                          title: 'Radius (r)',
                                          ctrl: _cylRadiusCtrl,
                                          icon: CustomPaint(
                                            painter: CylinderInputPainter(
                                              highlightType: 'Radius',
                                              baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                              highlightColor: AppColors.orangeColor(context),
                                            ),
                                          ),
                                        ),
                                        _buildFixedInputRow(
                                          title: 'Height (h)',
                                          ctrl: _cylHeightCtrl,
                                          icon: CustomPaint(
                                            painter: CylinderInputPainter(
                                              highlightType: 'Height',
                                              baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                              highlightColor: AppColors.orangeColor(context),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Dynamic Hint Banner
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _getBodyHintMessage(currentShape.name),
                                                style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15),
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
                                                  style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                              const SizedBox(height: 12),

                                              if (!isValid && hasPartialInput)
                                                Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Text(
                                                      'Enter values greater than 0 for both Radius and Height.',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: AppColors.redColor(context).withOpacity(0.9), fontSize: 14),
                                                    ),
                                                  ),
                                                )
                                              else if (isValid) ...[
                                                _buildResultRow('Volume', volume.toStringAsFixed(2), isHighlighted: true),
                                                _buildResultRow('Total area', totalArea.toStringAsFixed(2), isHighlighted: true),
                                                _buildResultRow('Lateral area', lateralArea.toStringAsFixed(2), isHighlighted: true),

                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                  child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                                ),

                                                _buildResultRow('Base area', baseArea.toStringAsFixed(2)),
                                                _buildResultRow('Diameter', diameter.toStringAsFixed(2)),
                                              ] else ...[
                                                Center(
                                                    child: Text(
                                                      'Enter both values to see results.',
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
                              /// YAHAN SE SPHERE CAP KA CODE ADD KAREIN
                              /// ==========================================
                              /// ==========================================
                              /// YAHAN SE SPHERE CAP KA CODE ADD KAREIN
                              /// ==========================================
                              else if (currentShape.name == 'Sphere cap') ...[
                                  Builder(
                                    builder: (context) {
                                      double baseRadius = double.tryParse(_sCapRadiusCtrl.text) ?? 0; // Input: Base Radius (a)
                                      double height = double.tryParse(_sCapHeightCtrl.text) ?? 0;     // Input: Cap Height (h)

                                      double volume = 0, totalArea = 0, lateralArea = 0, baseArea = 0, sphereRadius = 0;
                                      bool isValid = false;

                                      if (baseRadius > 0 && height > 0) {
                                        // Sphere Radius (R) = (a² + h²) / (2h)
                                        sphereRadius = ((baseRadius * baseRadius) + (height * height)) / (2 * height);

                                        // Base Area = π * a²
                                        baseArea = pi * baseRadius * baseRadius;

                                        // Lateral (Dome) Area = 2 * π * R * h
                                        lateralArea = 2 * pi * sphereRadius * height;

                                        // Total Area = Lateral Area + Base Area
                                        totalArea = lateralArea + baseArea;

                                        // Volume = (1/3) * π * h² * (3R - h)
                                        volume = (1 / 3) * pi * height * height * ((3 * sphereRadius) - height);

                                        isValid = true;
                                      }

                                      bool hasPartialInput = _sCapRadiusCtrl.text.isNotEmpty || _sCapHeightCtrl.text.isNotEmpty;

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Input',
                                            style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 12),

                                          // 2 Fixed Inputs: Base radius and Height
                                          _buildFixedInputRow(
                                            title: 'Base radius (a)', // FIX: Ab yeh Base radius hai
                                            ctrl: _sCapRadiusCtrl,
                                            icon: CustomPaint(
                                              painter: SphereCapInputPainter(
                                                highlightType: 'Base radius', // Painter mein humne 'Base radius' ka highlight banaya tha
                                                baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                                highlightColor: AppColors.orangeColor(context),
                                              ),
                                            ),
                                          ),
                                          _buildFixedInputRow(
                                            title: 'Height (h)',
                                            ctrl: _sCapHeightCtrl,
                                            icon: CustomPaint(
                                              painter: SphereCapInputPainter(
                                                highlightType: 'Height',
                                                baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                                highlightColor: AppColors.orangeColor(context),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          // Dynamic Hint Banner
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _getBodyHintMessage(currentShape.name),
                                                  style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15),
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
                                                    style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                                const SizedBox(height: 12),

                                                if (!isValid && hasPartialInput)
                                                  Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: Text(
                                                        'Enter values greater than 0 for both Base Radius and Height.',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(color: AppColors.redColor(context).withOpacity(0.9), fontSize: 14),
                                                      ),
                                                    ),
                                                  )
                                                else if (isValid) ...[
                                                  _buildResultRow('Volume', volume.toStringAsFixed(2), isHighlighted: true),
                                                  _buildResultRow('Total area', totalArea.toStringAsFixed(2), isHighlighted: true),
                                                  _buildResultRow('Lateral area', lateralArea.toStringAsFixed(2), isHighlighted: true),

                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                    child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                                  ),

                                                  _buildResultRow('Base area', baseArea.toStringAsFixed(2)),
                                                  _buildResultRow('Sphere radius', sphereRadius.toStringAsFixed(2)), // FIX: Result mein Sphere radius dikhayenge
                                                ] else ...[
                                                  Center(
                                                      child: Text(
                                                        'Enter both values to see results.',
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
                                /// YAHAN SE SPHERE SEGMENT KA CODE ADD KAREIN
                                /// ==========================================
                                else if (currentShape.name == 'Sphere segment') ...[
                                    Builder(
                                      builder: (context) {
                                        double height = double.tryParse(_sSegHeightCtrl.text) ?? 0;   // h
                                        double topRad = double.tryParse(_sSegTopRadCtrl.text) ?? 0;   // r₁
                                        double botRad = double.tryParse(_sSegBotRadCtrl.text) ?? 0;   // r₂

                                        double volume = 0, totalArea = 0, lateralArea = 0;
                                        double topArea = 0, baseArea = 0, sphereRadius = 0;
                                        bool isValid = false;

                                        if (height > 0 && topRad > 0 && botRad > 0) {
                                          // Distance 'd' ka logic Sphere Radius nikalne ke liye
                                          double d = ((topRad * topRad) - (botRad * botRad) - (height * height)) / (2 * height);

                                          // Sphere Radius (R)
                                          sphereRadius = sqrt((topRad * topRad) + (d * d));

                                          // Volume = (π * h / 6) * (3r₁² + 3r₂² + h²)
                                          volume = (pi * height / 6) * ((3 * topRad * topRad) + (3 * botRad * botRad) + (height * height));

                                          // Top aur Bottom Areas
                                          topArea = pi * topRad * topRad;
                                          baseArea = pi * botRad * botRad;

                                          // Lateral Area = 2 * π * R * h
                                          lateralArea = 2 * pi * sphereRadius * height;

                                          // Total Area = Lateral Area + Top Area + Base Area
                                          totalArea = lateralArea + topArea + baseArea;

                                          isValid = true;
                                        }

                                        bool hasPartialInput = _sSegHeightCtrl.text.isNotEmpty ||
                                            _sSegTopRadCtrl.text.isNotEmpty ||
                                            _sSegBotRadCtrl.text.isNotEmpty;

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Input',
                                              style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 12),

                                            // 3 Fixed Inputs: Height, Top radius, Bottom radius
                                            _buildFixedInputRow(
                                              title: 'Height (h)',
                                              ctrl: _sSegHeightCtrl,
                                              icon: CustomPaint(
                                                painter: SphereSegInputPainter(
                                                  highlightType: 'Height',
                                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                                  highlightColor: AppColors.orangeColor(context),
                                                ),
                                              ),
                                            ),
                                            _buildFixedInputRow(
                                              title: 'Top radius (r₁)',
                                              ctrl: _sSegTopRadCtrl,
                                              icon: CustomPaint(
                                                painter: SphereSegInputPainter(
                                                  highlightType: 'Top radius',
                                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                                  highlightColor: AppColors.orangeColor(context),
                                                ),
                                              ),
                                            ),
                                            _buildFixedInputRow(
                                              title: 'Bottom radius (r₂)',
                                              ctrl: _sSegBotRadCtrl,
                                              icon: CustomPaint(
                                                painter: SphereSegInputPainter(
                                                  highlightType: 'Bottom radius',
                                                  baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                                  highlightColor: AppColors.orangeColor(context),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            // Dynamic Hint Banner
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    _getBodyHintMessage(currentShape.name),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15),
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
                                                      style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                                  const SizedBox(height: 12),

                                                  if (!isValid && hasPartialInput)
                                                    Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(16.0),
                                                        child: Text(
                                                          'Enter values greater than 0 for Height, Top radius, and Bottom radius.',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(color: AppColors.redColor(context).withOpacity(0.9), fontSize: 14),
                                                        ),
                                                      ),
                                                    )
                                                  else if (isValid) ...[
                                                    _buildResultRow('Volume', volume.toStringAsFixed(2), isHighlighted: true),
                                                    _buildResultRow('Total area', totalArea.toStringAsFixed(2), isHighlighted: true),
                                                    _buildResultRow('Lateral area', lateralArea.toStringAsFixed(2), isHighlighted: true),

                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                                      child: Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),
                                                    ),

                                                    _buildResultRow('Top area', topArea.toStringAsFixed(2)),
                                                    _buildResultRow('Base area', baseArea.toStringAsFixed(2)),
                                                    _buildResultRow('Sphere radius', sphereRadius.toStringAsFixed(2)),
                                                  ] else ...[
                                                    Center(
                                                        child: Text(
                                                          'Enter all values to see results.',
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
                                  /// YAHAN SE ELLIPSOID KA CODE ADD KAREIN
                                  /// ==========================================
                                  else if (currentShape.name == 'Ellipsoid') ...[
                                      Builder(
                                        builder: (context) {
                                          double a = double.tryParse(_ellipsoidRadACtrl.text) ?? 0; // Radius a (x-axis)
                                          double b = double.tryParse(_ellipsoidRadBCtrl.text) ?? 0; // Radius b (y-axis)
                                          double c = double.tryParse(_ellipsoidRadCCtrl.text) ?? 0; // Radius c (z-axis)

                                          double volume = 0, totalArea = 0;
                                          bool isValid = false;

                                          if (a > 0 && b > 0 && c > 0) {
                                            // Volume = (4/3) * π * a * b * c
                                            volume = (4 / 3) * pi * a * b * c;

                                            // Surface Area approximation (Knud Thomsen's formula, highly accurate)
                                            // S ≈ 4 * π * [ ((ab)^p + (ac)^p + (bc)^p) / 3 ]^(1/p)  where p = 1.6075
                                            double p = 1.6075;
                                            double term1 = pow(a * b, p).toDouble();
                                            double term2 = pow(a * c, p).toDouble();
                                            double term3 = pow(b * c, p).toDouble();

                                            totalArea = 4 * pi * pow((term1 + term2 + term3) / 3, 1 / p);

                                            isValid = true;
                                          }

                                          bool hasPartialInput = _ellipsoidRadACtrl.text.isNotEmpty ||
                                              _ellipsoidRadBCtrl.text.isNotEmpty ||
                                              _ellipsoidRadCCtrl.text.isNotEmpty;

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Input',
                                                style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 12),

                                              // 3 Fixed Inputs for Ellipsoid: Radius a, Radius b, Radius c
                                              _buildFixedInputRow(
                                                title: 'Radius a (x)',
                                                ctrl: _ellipsoidRadACtrl,
                                                icon: CustomPaint(
                                                  painter: EllipsoidInputPainter(
                                                    highlightType: 'Radius a (x)',
                                                    baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                                    highlightColor: AppColors.orangeColor(context),
                                                  ),
                                                ),
                                              ),
                                              _buildFixedInputRow(
                                                title: 'Radius b (y)',
                                                ctrl: _ellipsoidRadBCtrl,
                                                icon: CustomPaint(
                                                  painter: EllipsoidInputPainter(
                                                    highlightType: 'Radius b (y)',
                                                    baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                                    highlightColor: AppColors.orangeColor(context),
                                                  ),
                                                ),
                                              ),
                                              _buildFixedInputRow(
                                                title: 'Radius c (z)',
                                                ctrl: _ellipsoidRadCCtrl,
                                                icon: CustomPaint(
                                                  painter: EllipsoidInputPainter(
                                                    highlightType: 'Radius c (z)',
                                                    baseColor: AppColors.textGrey(context).withOpacity(0.5),
                                                    highlightColor: AppColors.orangeColor(context),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),

                                              // Dynamic Hint Banner
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textGrey(context), size: 24),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      _getBodyHintMessage(currentShape.name),
                                                      style: TextStyle(color: AppColors.textColor(context).withOpacity(0.9), fontSize: 15),
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
                                                        style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Divider(color: AppColors.cyanColor(context).withOpacity(0.2), height: 1),
                                                    const SizedBox(height: 12),

                                                    if (!isValid && hasPartialInput)
                                                      Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(16.0),
                                                          child: Text(
                                                            'Enter values greater than 0 for all three radii.',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(color: AppColors.redColor(context).withOpacity(0.9), fontSize: 14),
                                                          ),
                                                        ),
                                                      )
                                                    else if (isValid) ...[
                                                      _buildResultRow('Volume', volume.toStringAsFixed(2), isHighlighted: true),
                                                      _buildResultRow('Total area', totalArea.toStringAsFixed(2), isHighlighted: true),
                                                    ] else ...[
                                                      Center(
                                                          child: Text(
                                                            'Enter all three radii to see results.',
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
            flex: 6,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textGrey(context).withOpacity(0.2)),
              ),
              // child: Row(
              //   children: [
              //     SizedBox(
              //       width: 24,
              //       height: 24,
              //       child: icon, // Dynamic icon yahan render hoga
              //     ),
              //     const SizedBox(width: 16),
              //     Text(
              //       title,
              //       style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold),
              //     ),
              //   ],
              // ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: icon, // Dynamic icon yahan render hoga
                  ),
                  const SizedBox(width: 16),
                  Expanded( // FIX: Text wrap karne ke liye Expanded zaroori hai
                    child: Text(
                      title,
                      maxLines: 2, // Max 2 lines set kiya
                      overflow: TextOverflow.ellipsis, // Agar 2 line se bada hua toh '...' dikhayega
                      style: TextStyle(
                        color: AppColors.textColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
      case 'Prism':
        painter = PrismInputPainter(
          highlightType: label,
          baseColor: AppColors.textGrey(context).withOpacity(0.2),
          highlightColor: iconColor,
        );
        break;
      case 'Pyramid':
        painter = PyramidInputPainter(
          highlightType: label,
          baseColor: AppColors.textGrey(context).withOpacity(0.2),
          highlightColor: iconColor,
        );
        break;
      case 'Pyramid frustum':
        painter = PyrFrustumInputPainter(
          highlightType: label,
          baseColor: AppColors.textGrey(context).withOpacity(0.2),
          highlightColor: iconColor,
        );
        break;
      case 'Cone':
        painter = ConeInputPainter(
          highlightType: label,
          baseColor: AppColors.textGrey(context).withOpacity(0.2),
          highlightColor: iconColor,
        );
        break;
      case 'Cone frustum':
        painter = ConeFrustumInputPainter(
          highlightType: label,
          baseColor: AppColors.textGrey(context).withOpacity(0.2),
          highlightColor: iconColor,
        );
        break;
      case 'Cylinder':
        painter = CylinderInputPainter(
          highlightType: label,
          baseColor: AppColors.textGrey(context).withOpacity(0.2),
          highlightColor: iconColor,
        );
        break;
      case 'Sphere':
        painter = SphereInputPainter( // FIX: SpherePainter ki jagah SphereInputPainter lagaya
          highlightType: label,
          baseColor: AppColors.textGrey(context).withOpacity(0.2),
          highlightColor: iconColor,
        );
        break;
      case 'Sphere cap':
        painter = SphereCapInputPainter(
          highlightType: label,
          baseColor: AppColors.textGrey(context).withOpacity(0.2),
          highlightColor: iconColor,
        );
        break;
      case 'Sphere segment':
        painter = SphereSegInputPainter(
          highlightType: label,
          baseColor: AppColors.textGrey(context).withOpacity(0.2),
          highlightColor: iconColor,
        );
        break;
      case 'Ellipsoid':
        painter = EllipsoidInputPainter(
          highlightType: label,
          baseColor: AppColors.textGrey(context).withOpacity(0.2),
          highlightColor: iconColor,
        );
        break;
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

// class PrismPainter extends CustomPainter {
//   final Color color;
//   PrismPainter({required this.color});
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
//     double w = size.width, h = size.height, offX = w * 0.3, offY = h * 0.3;
//     canvas.drawRect(Rect.fromLTWH(offX, 0, w - offX, h - offY), p);
//     canvas.drawRect(Rect.fromLTWH(0, offY, w - offX, h - offY), p);
//     canvas.drawLine(Offset(0, offY), Offset(offX, 0), p);
//     canvas.drawLine(Offset(w - offX, offY), Offset(w, 0), p);
//     canvas.drawLine(Offset(0, h), Offset(offX, h - offY), p);
//     canvas.drawLine(Offset(w - offX, h), Offset(w, h - offY), p);
//   }
//   @override
//   bool shouldRepaint(covariant CustomPainter old) => false;
// }
class PrismPainter extends CustomPainter {
  final Color color;
  PrismPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double w = size.width;
    double h = size.height;

    // Prism ko rectangular banane ke liye width jyada aur height kam rakhi hai
    double fw = w * 0.75; // Front face ki width
    double fh = h * 0.45; // Front face ki height
    double offX = w * 0.25; // 3D depth (Right ki taraf)
    double offY = h * 0.30; // 3D depth (Upar ki taraf)

    // Faces define kiye (Rectangular)
    Rect frontRect = Rect.fromLTWH(0, h - fh, fw, fh);
    Rect backRect = Rect.fromLTWH(offX, h - fh - offY, fw, fh);

    // Pehle Back Face draw karein
    canvas.drawRect(backRect, p);

    // Phir Front Face draw karein
    canvas.drawRect(frontRect, p);

    // Corners ko connect karne wali 3D lines
    canvas.drawLine(Offset(0, h - fh), Offset(offX, h - fh - offY), p); // Top-Left connect
    canvas.drawLine(Offset(fw, h - fh), Offset(offX + fw, h - fh - offY), p); // Top-Right connect
    canvas.drawLine(Offset(0, h), Offset(offX, h - offY), p); // Bottom-Left connect
    canvas.drawLine(Offset(fw, h), Offset(offX + fw, h - offY), p); // Bottom-Right connect
  }

  @override
  bool shouldRepaint(covariant PrismPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// class PyramidPainter extends CustomPainter {
//   final Color color;
//   PyramidPainter({required this.color});
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
//     double w = size.width, h = size.height;
//     Offset apex = Offset(w / 2, 0);
//     Offset bL = Offset(0, h * 0.8), bR = Offset(w * 0.7, h), bBack = Offset(w, h * 0.6);
//     canvas.drawLine(bL, bR, p); canvas.drawLine(bR, bBack, p); canvas.drawLine(bBack, bL, p);
//     canvas.drawLine(apex, bL, p); canvas.drawLine(apex, bR, p); canvas.drawLine(apex, bBack, p);
//     canvas.drawLine(apex, Offset((bL.dx + bBack.dx)/2, (bL.dy + bBack.dy)/2), Paint()..color=color.withOpacity(0.3)..style=PaintingStyle.stroke);
//   }
//   @override
//   bool shouldRepaint(covariant CustomPainter old) => false;
// }

// class PyrFrustumPainter extends CustomPainter {
//   final Color color;
//   PyrFrustumPainter({required this.color});
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
//     double w = size.width, h = size.height;
//     Path path = Path()
//       ..moveTo(w*0.3, h*0.2)
//       ..lineTo(w*0.7, h*0.2)
//       ..lineTo(w, h)
//       ..lineTo(0, h*0.8)
//       ..close();
//     canvas.drawPath(path, p);
//     canvas.drawLine(Offset(0, h*0.8), Offset(w*0.3, h*0.2), p);
//     canvas.drawLine(Offset(w, h), Offset(w*0.7, h*0.2), p);
//     canvas.drawLine(Offset(0, h*0.8), Offset(w*0.6, h*0.7), p);
//     canvas.drawLine(Offset(w, h), Offset(w*0.6, h*0.7), p);
//   }
//   @override
//   bool shouldRepaint(covariant CustomPainter old) => false;
// }

class PyramidPainter extends CustomPainter {
  final Color color;
  PyramidPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    double w = size.width;
    double h = size.height;

    // 1. Top Apex Point
    Offset apex = Offset(w * 0.50, h * 0.08);

    // 2. Bottom Base (3D Parallelogram)
    Offset bFL = Offset(w * 0.08, h * 0.88); // Bottom Front-Left
    Offset bFR = Offset(w * 0.70, h * 0.88); // Bottom Front-Right
    Offset bBR = Offset(w * 0.92, h * 0.62); // Bottom Back-Right
    Offset bBL = Offset(w * 0.30, h * 0.62); // Bottom Back-Left

    // Base Draw Karein
    Path basePath = Path()
      ..moveTo(bFL.dx, bFL.dy)
      ..lineTo(bFR.dx, bFR.dy)
      ..lineTo(bBR.dx, bBR.dy)
      ..lineTo(bBL.dx, bBL.dy)
      ..close();
    canvas.drawPath(basePath, p);

    // 3. Charo Corners ko Apex (Top) se Connect Karein
    canvas.drawLine(apex, bFL, p); // Front-Left edge
    canvas.drawLine(apex, bFR, p); // Front-Right edge
    canvas.drawLine(apex, bBR, p); // Back-Right edge
    canvas.drawLine(apex, bBL, p); // Back-Left edge
  }

  @override
  bool shouldRepaint(covariant PyramidPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class PyrFrustumPainter extends CustomPainter {
  final Color color;
  PyrFrustumPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    double w = size.width;
    double h = size.height;

    // 1. Bottom Base (Bada 3D Parallelogram)
    Offset bFL = Offset(w * 0.05, h * 0.85); // Bottom Front-Left
    Offset bFR = Offset(w * 0.72, h * 0.85); // Bottom Front-Right
    Offset bBR = Offset(w * 0.95, h * 0.60); // Bottom Back-Right
    Offset bBL = Offset(w * 0.28, h * 0.60); // Bottom Back-Left

    // 2. Top Base (Chota 3D Parallelogram)
    Offset tFL = Offset(w * 0.28, h * 0.32); // Top Front-Left
    Offset tFR = Offset(w * 0.58, h * 0.32); // Top Front-Right
    Offset tBR = Offset(w * 0.72, h * 0.16); // Top Back-Right
    Offset tBL = Offset(w * 0.42, h * 0.16); // Top Back-Left

    // Bottom Base Draw Karein
    Path bottomBase = Path()
      ..moveTo(bFL.dx, bFL.dy)
      ..lineTo(bFR.dx, bFR.dy)
      ..lineTo(bBR.dx, bBR.dy)
      ..lineTo(bBL.dx, bBL.dy)
      ..close();
    canvas.drawPath(bottomBase, p);

    // Top Base Draw Karein
    Path topBase = Path()
      ..moveTo(tFL.dx, tFL.dy)
      ..lineTo(tFR.dx, tFR.dy)
      ..lineTo(tBR.dx, tBR.dy)
      ..lineTo(tBL.dx, tBL.dy)
      ..close();
    canvas.drawPath(topBase, p);

    // 3. Dono Bases ke 4 Corners ko Connect Karein (Slanted Edges)
    canvas.drawLine(bFL, tFL, p); // Front-Left edge
    canvas.drawLine(bFR, tFR, p); // Front-Right edge
    canvas.drawLine(bBR, tBR, p); // Back-Right edge
    canvas.drawLine(bBL, tBL, p); // Back-Left edge
  }

  @override
  bool shouldRepaint(covariant PyrFrustumPainter oldDelegate) {
    return oldDelegate.color != color;
  }
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

// class SphereSegPainter extends CustomPainter {
//   final Color color;
//   SphereSegPainter({required this.color});
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
//     double w = size.width, h = size.height;
//     canvas.drawOval(Rect.fromLTWH(w*0.1, 0, w*0.8, h*0.25), p);
//     canvas.drawOval(Rect.fromLTWH(0, h*0.75, w, h*0.25), p);
//     canvas.drawArc(Rect.fromLTWH(-w*0.2, 0, w*1.4, h), 2.5, 1.2, false, p);
//     canvas.drawArc(Rect.fromLTWH(-w*0.2, 0, w*1.4, h), -0.6, 1.2, false, p);
//   }
//   @override
//   bool shouldRepaint(covariant CustomPainter old) => false;
// }

class SphereSegPainter extends CustomPainter {
  final Color color;
  SphereSegPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    double w = size.width;
    double h = size.height;

    // 1. Top Base Oval (Chota circle)
    Rect topOval = Rect.fromLTWH(w * 0.20, h * 0.10, w * 0.60, h * 0.20);
    // 2. Bottom Base Oval (Bada circle)
    Rect botOval = Rect.fromLTWH(w * 0.05, h * 0.70, w * 0.90, h * 0.20);

    canvas.drawOval(topOval, p);
    canvas.drawOval(botOval, p);

    // Ovals ke exact left aur right center points
    Offset topLeft = Offset(w * 0.20, h * 0.20);
    Offset botLeft = Offset(w * 0.05, h * 0.80);
    Offset topRight = Offset(w * 0.80, h * 0.20);
    Offset botRight = Offset(w * 0.95, h * 0.80);

    // 3. Side ki spherical curves draw karna
    Path sideEdges = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
    // Left side ka bahar ki taraf nikla hua curve (Bulge)
      ..quadraticBezierTo(-w * 0.05, h * 0.50, botLeft.dx, botLeft.dy)

      ..moveTo(topRight.dx, topRight.dy)
    // Right side ka bahar ki taraf nikla hua curve (Bulge)
      ..quadraticBezierTo(w * 1.05, h * 0.50, botRight.dx, botRight.dy);

    canvas.drawPath(sideEdges, p);
  }

  @override
  bool shouldRepaint(covariant SphereSegPainter old) {
    return old.color != color;
  }
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

class PrismInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  PrismInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()..color = baseColor..style = PaintingStyle.stroke..strokeWidth = 2.0;
    Paint hlStrokePaint = Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 3.0;
    Paint fillPaint = Paint()..color = highlightColor.withOpacity(0.4)..style = PaintingStyle.fill;

    double w = size.width, h = size.height;
    double fw = w * 0.75, fh = h * 0.45;
    double offX = w * 0.25, offY = h * 0.30;

    Offset fTL = Offset(0, h - fh), fTR = Offset(fw, h - fh);
    Offset fBL = Offset(0, h), fBR = Offset(fw, h);
    Offset bTL = Offset(offX, h - fh - offY), bTR = Offset(offX + fw, h - fh - offY);
    Offset bBL = Offset(offX, h - offY), bBR = Offset(offX + fw, h - offY);

    Rect frontRect = Rect.fromLTWH(0, h - fh, fw, fh);
    Rect backRect = Rect.fromLTWH(offX, h - fh - offY, fw, fh);
    Path topFace = Path()..moveTo(fTL.dx, fTL.dy)..lineTo(bTL.dx, bTL.dy)..lineTo(bTR.dx, bTR.dy)..lineTo(fTR.dx, fTR.dy)..close();
    Path rightFace = Path()..moveTo(fTR.dx, fTR.dy)..lineTo(bTR.dx, bTR.dy)..lineTo(bBR.dx, bBR.dy)..lineTo(fBR.dx, fBR.dy)..close();

    // FILL HIGHLIGHTS
    if (highlightType == 'Volume' || highlightType == 'Total area') {
      canvas.drawRect(backRect, fillPaint);
      canvas.drawPath(topFace, fillPaint);
      canvas.drawPath(rightFace, fillPaint);
      canvas.drawRect(frontRect, Paint()..color = highlightColor.withOpacity(0.7)..style = PaintingStyle.fill);
    } else if (highlightType == 'Lateral area') {
      canvas.drawRect(backRect, fillPaint);
      canvas.drawPath(rightFace, fillPaint);
      canvas.drawRect(frontRect, Paint()..color = highlightColor.withOpacity(0.7)..style = PaintingStyle.fill);
    }

    // DRAW BASE
    canvas.drawRect(backRect, basePaint);
    canvas.drawRect(frontRect, basePaint);
    canvas.drawLine(fTL, bTL, basePaint);
    canvas.drawLine(fTR, bTR, basePaint);
    canvas.drawLine(fBL, bBL, basePaint);
    canvas.drawLine(fBR, bBR, basePaint);

    // STROKE HIGHLIGHTS
    if (highlightType == 'Length') {
      canvas.drawLine(fBL, fBR, hlStrokePaint); // Front bottom edge
    } else if (highlightType == 'Height') {
      canvas.drawLine(fTR, fBR, hlStrokePaint); // Front right vertical edge
    } else if (highlightType == 'Width') {
      canvas.drawLine(fBR, bBR, hlStrokePaint); // Bottom depth edge (right side)
    } else if (highlightType == 'Space Diagonal') {
      canvas.drawLine(fBL, bTR, Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
  }

  @override
  bool shouldRepaint(covariant PrismInputPainter oldDelegate) {
    return oldDelegate.highlightType != highlightType || oldDelegate.highlightColor != highlightColor;
  }
}

class PyramidInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  PyramidInputPainter({required this.highlightType, required this.baseColor, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()..color = baseColor..style = PaintingStyle.stroke..strokeWidth = 2.0;
    Paint hlStrokePaint = Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 3.0;
    Paint dashedPaint = Paint()..color = highlightColor..style = PaintingStyle.stroke..strokeWidth = 2.0;
    Paint fillPaint = Paint()..color = highlightColor.withOpacity(0.4)..style = PaintingStyle.fill;
    Paint darkFillPaint = Paint()..color = highlightColor.withOpacity(0.7)..style = PaintingStyle.fill;

    double w = size.width, h = size.height;

    // 3D Parallelogram Base & Apex (Top) points
    Offset apex = Offset(w * 0.5, 0);
    Offset fL = Offset(0, h * 0.85); // Front-Left
    Offset fR = Offset(w * 0.6, h); // Front-Right
    Offset bL = Offset(w * 0.4, h * 0.6); // Back-Left
    Offset bR = Offset(w, h * 0.75); // Back-Right
    Offset baseCenter = Offset(w * 0.5, h * 0.8); // Center of base (for Height)
    Offset slantMid = Offset(w * 0.8, h * 0.875); // Mid of fR and bR (for Slant Height)

    // Base Polygon Paths
    Path basePath = Path()..moveTo(fL.dx, fL.dy)..lineTo(fR.dx, fR.dy)..lineTo(bR.dx, bR.dy)..lineTo(bL.dx, bL.dy)..close();
    Path frontFace = Path()..moveTo(apex.dx, apex.dy)..lineTo(fL.dx, fL.dy)..lineTo(fR.dx, fR.dy)..close();
    Path rightFace = Path()..moveTo(apex.dx, apex.dy)..lineTo(fR.dx, fR.dy)..lineTo(bR.dx, bR.dy)..close();

    // 1. FILL HIGHLIGHTS
    if (highlightType == 'Volume' || highlightType == 'Total area') {
      canvas.drawPath(frontFace, darkFillPaint);
      canvas.drawPath(rightFace, fillPaint);
      if (highlightType == 'Total area') canvas.drawPath(basePath, fillPaint);
    } else if (highlightType == 'Lateral area') {
      canvas.drawPath(frontFace, darkFillPaint);
      canvas.drawPath(rightFace, fillPaint);
    }

    // 2. DRAW BASE PYRAMID (Visible & Hidden edges)
    // Hidden edges (lighter/thinner)
    Paint hiddenPaint = Paint()..color = baseColor.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    canvas.drawLine(fL, bL, hiddenPaint);
    canvas.drawLine(bL, bR, hiddenPaint);
    canvas.drawLine(apex, bL, hiddenPaint);

    // Visible edges
    canvas.drawLine(fL, fR, highlightType == 'Base' ? hlStrokePaint : basePaint);
    canvas.drawLine(fR, bR, highlightType == 'Base' ? hlStrokePaint : basePaint);

    // Sirf Base par back lines ko bhi highlight karna hai
    if (highlightType == 'Base') {
      canvas.drawLine(fL, bL, hlStrokePaint);
      canvas.drawLine(bL, bR, hlStrokePaint);
    }

    canvas.drawLine(apex, fL, basePaint);
    canvas.drawLine(apex, fR, basePaint);
    canvas.drawLine(apex, bR, basePaint);

    // 3. SPECIFIC STROKE HIGHLIGHTS
    if (highlightType == 'Height') {
      // Center se Apex tak straight vertical dashed line (hum simple solid rakhenge for clarity)
      canvas.drawLine(apex, baseCenter, hlStrokePaint);
      canvas.drawCircle(baseCenter, 2, fillPaint);
    } else if (highlightType == 'Slant height') {
      // Apex se side-face ke mid tak
      canvas.drawLine(apex, slantMid, hlStrokePaint);
    } else if (highlightType == 'Lateral edge') {
      // Apex se Front-Right corner tak
      canvas.drawLine(apex, fR, hlStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PyramidInputPainter oldDelegate) {
    return oldDelegate.highlightType != highlightType || oldDelegate.highlightColor != highlightColor;
  }
}

class PyrFrustumInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  PyrFrustumInputPainter({
    required this.highlightType,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    Paint hlStrokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    Paint darkFillPaint = Paint()
      ..color = highlightColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;

    // Bottom Base Coordinates (Bada 3D Parallelogram)
    Offset bFL = Offset(w * 0.05, h * 0.85);
    Offset bFR = Offset(w * 0.72, h * 0.85);
    Offset bBR = Offset(w * 0.95, h * 0.60);
    Offset bBL = Offset(w * 0.28, h * 0.60);

    // Top Base Coordinates (Chota 3D Parallelogram)
    Offset tFL = Offset(w * 0.28, h * 0.32);
    Offset tFR = Offset(w * 0.58, h * 0.32);
    Offset tBR = Offset(w * 0.72, h * 0.16);
    Offset tBL = Offset(w * 0.42, h * 0.16);

    // Paths for Faces
    Path bottomBase = Path()..moveTo(bFL.dx, bFL.dy)..lineTo(bFR.dx, bFR.dy)..lineTo(bBR.dx, bBR.dy)..lineTo(bBL.dx, bBL.dy)..close();
    Path topBase = Path()..moveTo(tFL.dx, tFL.dy)..lineTo(tFR.dx, tFR.dy)..lineTo(tBR.dx, tBR.dy)..lineTo(tBL.dx, tBL.dy)..close();
    Path frontFace = Path()..moveTo(tFL.dx, tFL.dy)..lineTo(tFR.dx, tFR.dy)..lineTo(bFR.dx, bFR.dy)..lineTo(bFL.dx, bFL.dy)..close();
    Path rightFace = Path()..moveTo(tFR.dx, tFR.dy)..lineTo(tBR.dx, tBR.dy)..lineTo(bBR.dx, bBR.dy)..lineTo(bFR.dx, bFR.dy)..close();

    // 1. FILL HIGHLIGHTS (Volume, Total area, Lateral area)
    if (highlightType == 'Volume' || highlightType == 'Total area') {
      canvas.drawPath(bottomBase, fillPaint);
      canvas.drawPath(frontFace, darkFillPaint);
      canvas.drawPath(rightFace, fillPaint);
      canvas.drawPath(topBase, fillPaint);
    } else if (highlightType == 'Lateral area') {
      canvas.drawPath(frontFace, darkFillPaint);
      canvas.drawPath(rightFace, fillPaint);
    }

    // 2. BASE WIREFRAME DRAW KAREIN
    canvas.drawPath(bottomBase, basePaint);
    canvas.drawPath(topBase, basePaint);
    canvas.drawLine(bFL, tFL, basePaint);
    canvas.drawLine(bFR, tFR, basePaint);
    canvas.drawLine(bBR, tBR, basePaint);
    canvas.drawLine(bBL, tBL, basePaint);

    // 3. SPECIFIC STROKE HIGHLIGHTS
    if (highlightType == 'Base') {
      // Bottom base highlight
      canvas.drawPath(bottomBase, hlStrokePaint);
    } else if (highlightType == 'Top') {
      // Top base highlight
      canvas.drawPath(topBase, hlStrokePaint);
    } else if (highlightType == 'Height') {
      // Top center se Bottom center tak vertical line
      Offset topCenter = Offset((tFL.dx + tBR.dx) / 2, (tFL.dy + tBR.dy) / 2);
      Offset botCenter = Offset((bFL.dx + bBR.dx) / 2, (bFL.dy + bBR.dy) / 2);
      canvas.drawLine(topCenter, botCenter, hlStrokePaint);
    } else if (highlightType == 'Slant height') {
      // Right face ke top-mid se bottom-mid tak slant line
      Offset topRightMid = Offset((tFR.dx + tBR.dx) / 2, (tFR.dy + tBR.dy) / 2);
      Offset botRightMid = Offset((bFR.dx + bBR.dx) / 2, (bFR.dy + bBR.dy) / 2);
      canvas.drawLine(topRightMid, botRightMid, hlStrokePaint);
    } else if (highlightType == 'Lateral edge') {
      // Front-Right slanted corner edge
      canvas.drawLine(tFR, bFR, hlStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PyrFrustumInputPainter oldDelegate) {
    return oldDelegate.highlightType != highlightType ||
        oldDelegate.highlightColor != highlightColor;
  }
}

class ConeInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  ConeInputPainter({
    required this.highlightType,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    Paint hlStrokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    Paint darkFillPaint = Paint()
      ..color = highlightColor.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;

    // Coordinates for Cone
    Offset apex = Offset(w * 0.5, h * 0.08);
    Rect baseOval = Rect.fromLTWH(w * 0.1, h * 0.72, w * 0.8, h * 0.22);
    Offset baseCenter = Offset(w * 0.5, h * 0.83);
    Offset baseLeft = Offset(w * 0.1, h * 0.83);
    Offset baseRight = Offset(w * 0.9, h * 0.83);

    Path coneBody = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(baseLeft.dx, baseLeft.dy)
      ..arcTo(baseOval, pi, -pi, false)
      ..close();

    // 1. FILL HIGHLIGHTS
    if (highlightType == 'Volume' || highlightType == 'Total area') {
      canvas.drawPath(coneBody, fillPaint);
      canvas.drawOval(baseOval, darkFillPaint);
    } else if (highlightType == 'Lateral area') {
      canvas.drawPath(coneBody, darkFillPaint);
    } else if (highlightType == 'Base area') {
      canvas.drawOval(baseOval, darkFillPaint);
    }

    // 2. DRAW BASE WIREFRAME
    canvas.drawOval(baseOval, highlightType == 'Base area' ? hlStrokePaint : basePaint);
    canvas.drawLine(apex, baseLeft, basePaint);
    canvas.drawLine(apex, baseRight, basePaint);

    // 3. SPECIFIC STROKE HIGHLIGHTS
    if (highlightType == 'Radius') {
      // Base center se right edge tak line
      canvas.drawLine(baseCenter, baseRight, hlStrokePaint);
      canvas.drawCircle(baseCenter, 2.0, darkFillPaint);
    } else if (highlightType == 'Height') {
      // Apex se base center tak straight vertical line
      canvas.drawLine(apex, baseCenter, hlStrokePaint);
      canvas.drawCircle(baseCenter, 2.0, darkFillPaint);
    } else if (highlightType == 'Slant height') {
      // Right slanted edge highlight
      canvas.drawLine(apex, baseRight, hlStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConeInputPainter oldDelegate) {
    return oldDelegate.highlightType != highlightType ||
        oldDelegate.highlightColor != highlightColor;
  }
}

class ConeFrustumInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  ConeFrustumInputPainter({
    required this.highlightType,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    Paint hlStrokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    Paint darkFillPaint = Paint()
      ..color = highlightColor.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;

    // Top Oval (Chota Circle in 3D)
    Rect topOval = Rect.fromLTWH(w * 0.22, h * 0.08, w * 0.56, h * 0.18);
    Offset topCenter = Offset(w * 0.50, h * 0.17);
    Offset topLeft = Offset(w * 0.22, h * 0.17);
    Offset topRight = Offset(w * 0.78, h * 0.17);

    // Bottom Oval (Bada Circle in 3D)
    Rect botOval = Rect.fromLTWH(w * 0.05, h * 0.72, w * 0.90, h * 0.22);
    Offset botCenter = Offset(w * 0.50, h * 0.83);
    Offset botLeft = Offset(w * 0.05, h * 0.83);
    Offset botRight = Offset(w * 0.95, h * 0.83);

    // Lateral Body Path
    Path bodyPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(botLeft.dx, botLeft.dy)
      ..arcTo(botOval, pi, -pi, false)
      ..lineTo(topRight.dx, topRight.dy)
      ..arcTo(topOval, 0, pi, false)
      ..close();

    // 1. FILL HIGHLIGHTS
    if (highlightType == 'Volume' || highlightType == 'Total area') {
      canvas.drawPath(bodyPath, fillPaint);
      canvas.drawOval(botOval, darkFillPaint);
      canvas.drawOval(topOval, darkFillPaint);
    } else if (highlightType == 'Lateral area') {
      canvas.drawPath(bodyPath, darkFillPaint);
    } else if (highlightType == 'Top area') {
      canvas.drawOval(topOval, darkFillPaint);
    } else if (highlightType == 'Base area') {
      canvas.drawOval(botOval, darkFillPaint);
    }

    // 2. DRAW BASE WIREFRAME
    canvas.drawOval(topOval, highlightType == 'Top area' ? hlStrokePaint : basePaint);
    canvas.drawOval(botOval, highlightType == 'Base area' ? hlStrokePaint : basePaint);
    canvas.drawLine(topLeft, botLeft, basePaint);
    canvas.drawLine(topRight, botRight, basePaint);

    // 3. SPECIFIC STROKE HIGHLIGHTS
    if (highlightType == 'Height') {
      // Top center se Bottom center tak straight vertical line
      canvas.drawLine(topCenter, botCenter, hlStrokePaint);
      canvas.drawCircle(topCenter, 1.8, darkFillPaint);
      canvas.drawCircle(botCenter, 1.8, darkFillPaint);
    } else if (highlightType == 'Top radius') {
      // Top center se Top right edge tak line
      canvas.drawLine(topCenter, topRight, hlStrokePaint);
      canvas.drawCircle(topCenter, 1.8, darkFillPaint);
    } else if (highlightType == 'Bottom radius') {
      // Bottom center se Bottom right edge tak line
      canvas.drawLine(botCenter, botRight, hlStrokePaint);
      canvas.drawCircle(botCenter, 1.8, darkFillPaint);
    } else if (highlightType == 'Slant height') {
      // Right slanted edge highlight
      canvas.drawLine(topRight, botRight, hlStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConeFrustumInputPainter oldDelegate) {
    return oldDelegate.highlightType != highlightType ||
        oldDelegate.highlightColor != highlightColor;
  }
}

class CylinderInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  CylinderInputPainter({
    required this.highlightType,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    Paint hlStrokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    Paint darkFillPaint = Paint()
      ..color = highlightColor.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;

    // Top Oval
    Rect topOval = Rect.fromLTWH(w * 0.15, h * 0.08, w * 0.70, h * 0.20);
    Offset topCenter = Offset(w * 0.50, h * 0.18);
    Offset topLeft = Offset(w * 0.15, h * 0.18);
    Offset topRight = Offset(w * 0.85, h * 0.18);

    // Bottom Oval
    Rect botOval = Rect.fromLTWH(w * 0.15, h * 0.72, w * 0.70, h * 0.20);
    Offset botCenter = Offset(w * 0.50, h * 0.82);
    Offset botLeft = Offset(w * 0.15, h * 0.82);
    Offset botRight = Offset(w * 0.85, h * 0.82);

    // Lateral Body Path
    Path bodyPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(botLeft.dx, botLeft.dy)
      ..arcTo(botOval, pi, -pi, false)
      ..lineTo(topRight.dx, topRight.dy)
      ..arcTo(topOval, 0, pi, false)
      ..close();

    // 1. FILL HIGHLIGHTS
    if (highlightType == 'Volume' || highlightType == 'Total area') {
      canvas.drawPath(bodyPath, fillPaint);
      canvas.drawOval(botOval, darkFillPaint);
      canvas.drawOval(topOval, darkFillPaint);
    } else if (highlightType == 'Lateral area') {
      canvas.drawPath(bodyPath, darkFillPaint);
    } else if (highlightType == 'Base area') {
      canvas.drawOval(botOval, darkFillPaint);
    }

    // 2. DRAW BASE WIREFRAME
    canvas.drawOval(topOval, basePaint);
    canvas.drawOval(botOval, highlightType == 'Base area' ? hlStrokePaint : basePaint);
    canvas.drawLine(topLeft, botLeft, basePaint);
    canvas.drawLine(topRight, botRight, basePaint);

    // 3. SPECIFIC STROKE HIGHLIGHTS
    if (highlightType == 'Radius') {
      // Bottom center se right edge tak line
      canvas.drawLine(botCenter, botRight, hlStrokePaint);
      canvas.drawCircle(botCenter, 1.8, darkFillPaint);
    } else if (highlightType == 'Diameter') {
      // Bottom left se right edge tak full line
      canvas.drawLine(botLeft, botRight, hlStrokePaint);
      canvas.drawCircle(botCenter, 1.8, darkFillPaint);
    } else if (highlightType == 'Height') {
      // Top center se Bottom center tak vertical line
      canvas.drawLine(topCenter, botCenter, hlStrokePaint);
      canvas.drawCircle(topCenter, 1.8, darkFillPaint);
      canvas.drawCircle(botCenter, 1.8, darkFillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CylinderInputPainter oldDelegate) {
    return oldDelegate.highlightType != highlightType ||
        oldDelegate.highlightColor != highlightColor;
  }
}

class SphereCapInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  SphereCapInputPainter({
    required this.highlightType,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    Paint hlStrokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    Paint darkFillPaint = Paint()
      ..color = highlightColor.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;

    // Aapke exact purane rectangles
    Rect arcRect = Rect.fromLTWH(0, 0, w, h * 1.5);
    Rect baseOval = Rect.fromLTWH(0, h * 0.6, w, h * 0.3);

    // Coordinates for highlights
    Offset center = Offset(w / 2, h * 0.75); // Base oval ka center
    Offset topPole = Offset(w / 2, 0);       // Cap ka top
    Offset rightEdge = Offset(w, h * 0.75);  // Base oval ka right edge

    // Dome Path (Top arc + bottom curve of oval)
    Path domePath = Path()
      ..addArc(arcRect, pi, pi)
      ..arcTo(baseOval, 0, pi, false)
      ..close();

    // 1. FILL HIGHLIGHTS
    if (highlightType == 'Volume' || highlightType == 'Total area') {
      canvas.drawPath(domePath, fillPaint);
      canvas.drawOval(baseOval, darkFillPaint);
    } else if (highlightType == 'Lateral area') {
      canvas.drawPath(domePath, darkFillPaint);
    } else if (highlightType == 'Base area') {
      canvas.drawOval(baseOval, darkFillPaint);
    }

    // 2. DRAW BASE WIREFRAME (Aapke original design jaisa)
    canvas.drawArc(
      arcRect,
      pi,
      pi,
      false,
      highlightType == 'Lateral area' ? hlStrokePaint : basePaint,
    );
    canvas.drawOval(
      baseOval,
      highlightType == 'Base area' ? hlStrokePaint : basePaint,
    );

    // 3. SPECIFIC STROKE HIGHLIGHTS
    if (highlightType == 'Base radius') {
      // Base center se right edge tak (a)
      canvas.drawLine(center, rightEdge, hlStrokePaint);
      canvas.drawCircle(center, 2.0, darkFillPaint);
    } else if (highlightType == 'Height') {
      // Top se base center tak vertical line (h)
      canvas.drawLine(topPole, center, hlStrokePaint);
      canvas.drawCircle(center, 2.0, darkFillPaint);
      canvas.drawCircle(topPole, 2.0, darkFillPaint);
    } else if (highlightType == 'Sphere radius') { // FIX: Yahan 'Sphere radius' aayega Result ke label ke liye
      // Sphere radius (R) ke liye ek slanted line draw karenge arc tak
      Offset slantPoint = Offset(
          w / 2 + (w / 2) * cos(pi / 4),
          h * 0.75 - (h * 0.75) * sin(pi / 4) // FIX: Missing minus (-) operator lagaya
      );
      canvas.drawLine(center, slantPoint, hlStrokePaint);
      canvas.drawCircle(center, 2.0, darkFillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SphereCapInputPainter oldDelegate) {
    return oldDelegate.highlightType != highlightType ||
        oldDelegate.highlightColor != highlightColor;
  }
}

class SphereSegInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  SphereSegInputPainter({
    required this.highlightType,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Paint hlStrokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    Paint darkFillPaint = Paint()
      ..color = highlightColor.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;

    // 1. Top Base Oval
    Rect topOval = Rect.fromLTWH(w * 0.20, h * 0.10, w * 0.60, h * 0.20);
    Offset topCenter = Offset(w * 0.50, h * 0.20);
    Offset topLeft = Offset(w * 0.20, h * 0.20);
    Offset topRight = Offset(w * 0.80, h * 0.20);

    // 2. Bottom Base Oval
    Rect botOval = Rect.fromLTWH(w * 0.05, h * 0.70, w * 0.90, h * 0.20);
    Offset botCenter = Offset(w * 0.50, h * 0.80);
    Offset botLeft = Offset(w * 0.05, h * 0.80);
    Offset botRight = Offset(w * 0.95, h * 0.80);

    // 3. Complete Barrel Path for solid fills
    Path barrelPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..quadraticBezierTo(-w * 0.05, h * 0.50, botLeft.dx, botLeft.dy)
      ..arcTo(botOval, pi, -pi, false)
      ..quadraticBezierTo(w * 1.05, h * 0.50, topRight.dx, topRight.dy)
      ..arcTo(topOval, 0, pi, false)
      ..close();

    // Side curved borders ke liye alag path (sirf lines draw karne ke liye)
    Path sideEdges = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..quadraticBezierTo(-w * 0.05, h * 0.50, botLeft.dx, botLeft.dy)
      ..moveTo(topRight.dx, topRight.dy)
      ..quadraticBezierTo(w * 1.05, h * 0.50, botRight.dx, botRight.dy);

    // --- FILL HIGHLIGHTS ---
    if (highlightType == 'Volume' || highlightType == 'Total area') {
      canvas.drawPath(barrelPath, fillPaint);
      canvas.drawOval(topOval, darkFillPaint);
      canvas.drawOval(botOval, darkFillPaint);
    } else if (highlightType == 'Lateral area') {
      canvas.drawPath(barrelPath, darkFillPaint);
    } else if (highlightType == 'Top area') {
      canvas.drawOval(topOval, darkFillPaint);
    } else if (highlightType == 'Base area') {
      canvas.drawOval(botOval, darkFillPaint);
    }

    // --- DRAW BASE WIREFRAME ---
    canvas.drawOval(topOval, highlightType == 'Top area' ? hlStrokePaint : basePaint);
    canvas.drawOval(botOval, highlightType == 'Base area' ? hlStrokePaint : basePaint);
    canvas.drawPath(sideEdges, highlightType == 'Lateral area' ? hlStrokePaint : basePaint);

    // --- SPECIFIC STROKE HIGHLIGHTS ---
    if (highlightType == 'Height') {
      // Top se bottom center tak straight vertical line
      canvas.drawLine(topCenter, botCenter, hlStrokePaint);
      canvas.drawCircle(topCenter, 1.8, darkFillPaint);
      canvas.drawCircle(botCenter, 1.8, darkFillPaint);
    } else if (highlightType == 'Top radius') {
      // Top center se right edge tak (r1)
      canvas.drawLine(topCenter, topRight, hlStrokePaint);
      canvas.drawCircle(topCenter, 1.8, darkFillPaint);
    } else if (highlightType == 'Bottom radius') {
      // Bottom center se right edge tak (r2)
      canvas.drawLine(botCenter, botRight, hlStrokePaint);
      canvas.drawCircle(botCenter, 1.8, darkFillPaint);
    } else if (highlightType == 'Sphere radius') {
      // Center of segment se curve tak (R)
      Offset midCenter = Offset(w * 0.50, h * 0.50);
      Offset midCurveRight = Offset(w * 0.98, h * 0.50);
      canvas.drawLine(midCenter, midCurveRight, hlStrokePaint);
      canvas.drawCircle(midCenter, 1.8, darkFillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SphereSegInputPainter oldDelegate) {
    return oldDelegate.highlightType != highlightType ||
        oldDelegate.highlightColor != highlightColor;
  }
}

class EllipsoidInputPainter extends CustomPainter {
  final String highlightType;
  final Color baseColor;
  final Color highlightColor;

  EllipsoidInputPainter({
    required this.highlightType,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Paint faintPaint = Paint()
      ..color = baseColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    Paint hlStrokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    Paint fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    Paint darkFillPaint = Paint()
      ..color = highlightColor.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    double w = size.width;
    double h = size.height;
    Offset center = Offset(w / 2, h / 2);

    // Ellipsoid outer boundary (A wide horizontal oval)
    Rect outerOval = Rect.fromCenter(center: center, width: w * 0.9, height: h * 0.65);

    // 3D Equator (Horizontal depth ring)
    Rect equator = Rect.fromCenter(center: center, width: w * 0.9, height: h * 0.25);

    // 3D Meridian (Vertical depth ring)
    Rect meridian = Rect.fromCenter(center: center, width: w * 0.35, height: h * 0.65);

    // --- FILL HIGHLIGHTS ---
    if (highlightType == 'Volume' || highlightType == 'Total area') {
      canvas.drawOval(outerOval, fillPaint);
      canvas.drawOval(equator, darkFillPaint);
      canvas.drawOval(meridian, darkFillPaint);
    }

    // --- DRAW BASE WIREFRAME ---
    canvas.drawOval(outerOval, basePaint);
    canvas.drawOval(equator, faintPaint);
    canvas.drawOval(meridian, faintPaint);

    // --- SPECIFIC RADIUS HIGHLIGHTS ---
    if (highlightType == 'Radius a (x)') {
      // Radius 'a' (x-axis): Center se horizontal right edge tak
      Offset rightEdge = Offset(center.dx + (w * 0.45), center.dy);
      canvas.drawLine(center, rightEdge, hlStrokePaint);
      canvas.drawCircle(center, 2.0, darkFillPaint);
    } else if (highlightType == 'Radius b (y)') {
      // Radius 'b' (y-axis / depth): Center se equator ke bottom edge tak (3D perspective)
      Offset depthBottomEdge = Offset(center.dx, center.dy + (h * 0.125));
      canvas.drawLine(center, depthBottomEdge, hlStrokePaint);
      canvas.drawCircle(center, 2.0, darkFillPaint);
    } else if (highlightType == 'Radius c (z)') {
      // Radius 'c' (z-axis): Center se top edge tak
      Offset topEdge = Offset(center.dx, center.dy - (h * 0.325));
      canvas.drawLine(center, topEdge, hlStrokePaint);
      canvas.drawCircle(center, 2.0, darkFillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant EllipsoidInputPainter oldDelegate) {
    return oldDelegate.highlightType != highlightType ||
        oldDelegate.highlightColor != highlightColor;
  }
}