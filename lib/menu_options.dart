import 'package:calculator_pro/screens/power_conversion_view.dart';
import 'package:calculator_pro/screens/pressure_conversion_view.dart';
import 'package:calculator_pro/screens/roman_numerals_converter_view.dart';
import 'package:calculator_pro/settings_page.dart';
import 'package:calculator_pro/screens/shoe_size_converter_view.dart';
import 'package:calculator_pro/screens/speed_conversion_view.dart';
import 'package:calculator_pro/screens/temperature_conversion_view.dart';
import 'package:calculator_pro/screens/time_converter_view.dart';
import 'package:calculator_pro/screens/torque_converter_view.dart';
import 'package:calculator_pro/screens/volume_conversion_view.dart';
import 'package:calculator_pro/screens/volumetric_flow_converter_view.dart';
import 'package:calculator_pro/screens/weight_mass_conversion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/acceleration_converter_view.dart';
import 'screens/angle_converter_view.dart';
import 'custom_action_button.dart';
import 'screens/area_conversion_view.dart';
import 'screens/data_storage_conversion_view.dart';
import 'screens/data_transfer_converter_view.dart';
import 'screens/energy_conversion_view.dart';
import 'screens/force_converter_view.dart';
import 'screens/length_conversion_view.dart';
import 'screens/numeric_base_converter_view.dart'; // NAYA: Aapke custom ActionButton ko import kiya

// 1. NAYA: StatelessWidget se StatefulWidget me convert kiya taaki scroll track kar sakein
class MenuOptions extends StatefulWidget {
  final VoidCallback onClose;

  const MenuOptions({super.key, required this.onClose});

  @override
  State<MenuOptions> createState() => _MenuOptionsState();
}

class _MenuOptionsState extends State<MenuOptions> {
  // Main screen wale same theme colors yahan define kiye
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  // NAYA: Expand/Collapse track karne ke liye variables
  bool _isUnitExpanded = true;
  bool _isOtherExpanded = true;

  String? _currentActiveView;

  // 2. NAYA: Scroll tracking ke liye variables
  late ScrollController _scrollController;
  bool _showTopSearch = false;
  bool _isHapticsEnabled = true;

  double _savedScrollOffset = 0.0;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allTools = [
    {'id': 'length', 'title': 'Length', 'sub': 'Meters, inches, feet & more', 'img': 'assets/images/length.png', 'isOther': false},
    {'id': 'weight', 'title': 'Weight & Mass', 'sub': 'Kilograms, pounds, ounces...', 'img': 'assets/images/weight.png', 'isOther': false},
    {'id': 'area', 'title': 'Area', 'sub': 'Square meters, acres, hectares...', 'img': 'assets/images/area.png', 'isOther': false},
    {'id': 'volume', 'title': 'Volume', 'sub': 'Liters, gallons, cubic meters...', 'img': 'assets/images/volume.png', 'isOther': false},
    {'id': 'temperature', 'title': 'Temperature', 'sub': 'Celsius, Fahrenheit, Kelvin', 'img': 'assets/images/temperature.png', 'isOther': false},
    {'id': 'speed', 'title': 'Speed', 'sub': 'km/h, mph, knots & more', 'img': 'assets/images/speed.png', 'isOther': false},
    {'id': 'pressure', 'title': 'Pressure', 'sub': 'Pascal, bar, psi, atm...', 'img': 'assets/images/pressure.png', 'isOther': false},
    {'id': 'energy', 'title': 'Energy', 'sub': 'Joules, calories, kWh...', 'img': 'assets/images/energy.png', 'isOther': false},
    {'id': 'power', 'title': 'Power', 'sub': 'Watts, kilowatts, horsepower...', 'img': 'assets/images/power.png', 'isOther': false},
    {'id': 'data storage', 'title': 'Data Storage', 'sub': 'Bytes, MB, GB, TB, PB...', 'img': 'assets/images/data_storage.png', 'isOther': false},
    {'id': 'acceleration', 'title': 'Acceleration', 'sub': 'm/s², g, ft/s²...', 'img': 'assets/images/acceleration.png', 'isOther': false},
    {'id': 'angle', 'title': 'Angle', 'sub': 'Degree, Radian, Gradian...', 'img': 'assets/images/angle.png', 'isOther': false},
    {'id': 'data_transfer', 'title': 'Data Transfer', 'sub': 'Mbps, MB/s, GB/s...', 'img': 'assets/images/data_transfer.png', 'isOther': false},
    {'id': 'force', 'title': 'Force', 'sub': 'Newton, Dyne, Pound-force...', 'img': 'assets/images/force.png', 'isOther': false},
    {'id': 'roman_numerals', 'title': 'Roman Numerals', 'sub': 'I, V, X, L, C, M...', 'img': 'assets/images/roman_numerals.png', 'isOther': false},
    {'id': 'torque', 'title': 'Torque', 'sub': 'N·m, lb·ft, kgf·m...', 'img': 'assets/images/torque.png', 'isOther': false},
    {'id': 'volumetric_flow', 'title': 'Volumetric Flow', 'sub': 'm³/s, L/min, gal/h...', 'img': 'assets/images/volumetric_flow.png', 'isOther': false},
    {'id': 'time', 'title': 'Time', 'sub': 'Second, Minute, Hour, Day...', 'img': 'assets/images/time.png', 'isOther': false},
    {'id': 'numeric_base', 'title': 'Numeric Base', 'sub': 'Binary, Octal, Decimal, Hex...', 'img': 'assets/images/numeric_base.png', 'isOther': false},
    {'id': 'shoe_size', 'title': 'Shoe Size', 'sub': 'US, UK, EU, CM...', 'img': 'assets/images/shoe_size.png', 'isOther': false},
    // Other Tools Category
    {'id': 'discount', 'title': 'Discount', 'sub': 'Calculate discounts', 'img': 'assets/images/percentage-discount-symbol.png', 'isOther': true},
    {'id': 'emi', 'title': 'EMI Calculator', 'sub': 'Loan & Mortgage', 'img': 'assets/images/percentage-discount-symbol.png', 'isOther': true},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadHapticsSetting();
    // NAYA: Scroll Listener - Check karta hai ki kitna scroll hua hai
    _scrollController.addListener(() {
      if (_scrollController.offset > 80 && !_showTopSearch) {
        // Agar 80px se zyada scroll ho gaya toh top search button dikhao
        setState(() {
          _showTopSearch = true;
        });
      } else if (_scrollController.offset <= 80 && _showTopSearch) {
        // Upar aane par wapas hide kar do
        setState(() {
          _showTopSearch = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHapticsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true; // Default ON
    });
  }

  // --- NAYA FIX 2: View Open karne ka smart logic ---
  // void _openView(String viewName) {
  //   if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //
  //   // Naye page par jane se pehle current scroll position save karlo
  //   if (_scrollController.hasClients) {
  //     _savedScrollOffset = _scrollController.offset;
  //   }
  //
  //   setState(() {
  //     _currentActiveView = viewName;
  //     _searchController.clear();
  //     _searchQuery = "";
  //   });
  // }

  // --- NAYA FIX 2: View Open karne ka smart logic ---
  void _openView(String viewName) {
    if (_isHapticsEnabled) HapticFeedback.selectionClick();

    // Naye page par jane se pehle current scroll position save karlo
    if (_scrollController.hasClients) {
      _savedScrollOffset = _scrollController.offset;
    }

    // NAYA FIX: Pehle system keyboard ko force-hide karo
    FocusScope.of(context).unfocus();

    // NAYA FIX: 150 milliseconds ka chota delay taaki keyboard smooth niche chala jaye
    // Aur RenderFlex overflow error (yellow tape) na aaye
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return; // Safety check

      setState(() {
        _currentActiveView = viewName;

        // Naya page khulte hi automatically search reset kar do
        _searchController.clear();
        _searchQuery = "";
      });
    });
  }

  // --- NAYA FIX 3: View Close karke Menu par wapas aane ka logic ---
  void _closeView() {
    setState(() {
      _currentActiveView = null; // Menu par aao
    });

    // Animation hone ke thik baad saved scroll position ko restore karo
    Future.delayed(const Duration(milliseconds: 20), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_savedScrollOffset);
      }
    });
  }

  // NAYA: Switch statement for clean routing
  Widget _getActiveViewWidget() {
    switch (_currentActiveView) {
      case 'length':
        return LengthConverterView(
          key: const ValueKey('Length'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'weight':
        return WeightMassConverterView(
          key: const ValueKey('Weight'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'area':
        return AreaConverterView(
            key: const ValueKey('Area'),
            onBack: () => setState(() => _currentActiveView = null)
        );
      case 'volume':
        return VolumeConverterView(
          key: const ValueKey('Volume'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'temperature':
        return TemperatureConverterView(
          key: const ValueKey('Temp'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'speed':
        return SpeedConverterView(
          key: const ValueKey('Speed'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'pressure':
        return PressureConverterView(
          key: const ValueKey('Pressure'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'energy':
        return EnergyConverterView(
          key: const ValueKey('Energy'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'power':
        return PowerConverterView(
          key: const ValueKey('Power'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'data storage':
        return DataStorageConverterView(
          key: const ValueKey('Data'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'acceleration':
        return AccelerationConverterView(
          key: const ValueKey('Acceleration'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'angle':
        return AngleConverterView(
          key: const ValueKey('Angle'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'data_transfer':
        return DataTransferConverterView(
          key: const ValueKey('Data Transfer'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'force':
        return ForceConverterView(
          key: const ValueKey('Force'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'roman_numerals':
        return RomanNumeralsConverterView(
          key: const ValueKey('Roman Numerals'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'torque':
        return TorqueConverterView(
          key: const ValueKey('Torque'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'volumetric_flow':
        return VolumetricFlowConverterView(
          key: const ValueKey('Volumetric Flow'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'time':
        return TimeConverterView(key: const ValueKey('Time'), onBack: () => setState(() => _currentActiveView = null));
      case 'numeric_base':
        return NumericBaseConverterView(
          key: const ValueKey('Numeric Base'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'shoe_size':
        return ShoeSizeConverterView(
          key: const ValueKey('Shoe Size'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      default:
        return _buildMainMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // false ka matlab hai app default tarike se close (pop) nahi hoga
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // didPop true hone ka matlab hai system ne forcefully pop kar diya hai
        if (didPop) return;

        if (_currentActiveView != null) {
          // 1. Agar koi converter page khula hai, toh usko band karke Menu dikhao
          _closeView();
        } else {
          // 2. Agar pehle se Main Menu par hain, toh Menu ko band karke Calculator par jao
          widget.onClose();
        }
      },
      child: Container(
        width: double.infinity,
        color: bgColor,
        child: SafeArea(
          // NAYA: Smooth transition animation ke liye AnimatedSwitcher
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (child, animation) {
              // Halka sa slide aur fade animation
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            // Agar 'length' view active hai, toh naya page dikhao
            // child: _currentActiveView == 'length'
            //     ? LengthConverterView(
            //   key: const ValueKey('LengthView'),
            //   onBack: () {
            //     setState(() {
            //       _currentActiveView = null; // Wapas Main menu par aao
            //     });
            //   },
            // )
            //     : _buildMainMenu(), // Warna apna purana menu dikhao
            child: _getActiveViewWidget(),
          ),
        ),
      ),
    );
  }

  // NAYA FUNCTION: Main Menu ka pura UI yahan shift kar diya
  // Widget _buildMainMenu() {
  //   return Column(
  //     key: const ValueKey('MainMenuView'), // NAYA: AnimatedSwitcher ke liye Key zaroori hai
  //     children: [
  //       // --- 1. TOP BAR ---
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             // Left: Settings Button
  //             ActionButton(
  //               icon: Icons.settings_outlined,
  //               contentColor: textGrey,
  //               bgColor: surfaceColor.withOpacity(0.5),
  //               onTap: () {
  //                 if (_isHapticsEnabled) {
  //                   HapticFeedback.lightImpact(); // Halka sa premium vibration
  //                 }
  //                 Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  //               },
  //             ),
  //
  //             const SizedBox(width: 16),
  //
  //             // Center: Title
  //             const Expanded(
  //               child: Text(
  //                 'Tools & Converters',
  //                 style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //
  //             // 3. Conditional Search Button (Sirf scroll karne par dikhega)
  //             if (_showTopSearch) ...[
  //               ActionButton(
  //                 icon: Icons.search_rounded,
  //                 contentColor: textGrey,
  //                 bgColor: surfaceColor.withOpacity(0.5),
  //                 onTap: () {
  //                   // Jab tap hoga toh smoothly wapas top par scroll kar dega
  //                   _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  //                 },
  //               ),
  //               const SizedBox(width: 8),
  //             ],
  //
  //             // Right: Back Button
  //             ActionButton(
  //               icon: Icons.arrow_forward_ios_rounded,
  //               contentColor: textGrey,
  //               bgColor: surfaceColor.withOpacity(0.5),
  //               onTap: () {
  //                 if (_isHapticsEnabled) {
  //                   HapticFeedback.lightImpact();
  //                 }
  //                 widget.onClose();
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //
  //       // --- 2. SCROLLABLE CONTENT ---
  //       Expanded(
  //         child: SingleChildScrollView(
  //           controller: _scrollController,
  //           physics: const BouncingScrollPhysics(),
  //           padding: const EdgeInsets.fromLTRB(18, 5, 18, 14),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Search Bar Widget
  //               _buildSearchBar(),
  //
  //               const SizedBox(height: 14),
  //               // Favourite Card Widget
  //               _buildFavouriteCard(),
  //
  //               const SizedBox(height: 14),
  //
  //               // --- CATEGORY 1: UNIT CONVERTERS ---
  //               GestureDetector(
  //                 behavior: HitTestBehavior.opaque,
  //                 onTap: () {
  //                   setState(() {
  //                     _isUnitExpanded = !_isUnitExpanded;
  //                   });
  //                 },
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(left: 2.0, bottom: 10.0, right: 8.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       const Text(
  //                         'Unit Converters',
  //                         style: TextStyle(
  //                           color: Colors.cyanAccent,
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.bold,
  //                           letterSpacing: 1.2,
  //                         ),
  //                       ),
  //                       Icon(
  //                         _isUnitExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
  //                         color: Colors.cyanAccent,
  //                         size: 24,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //
  //               // --- CARD VIEW SECTION 1 ---
  //               AnimatedSize(
  //                 duration: const Duration(milliseconds: 300),
  //                 curve: Curves.easeInOutCubic,
  //                 child: _isUnitExpanded
  //                     ? Container(
  //                         padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 0),
  //                         decoration: BoxDecoration(
  //                           color: surfaceColor.withOpacity(0.2),
  //                           borderRadius: BorderRadius.circular(24),
  //                           border: Border.all(color: Colors.white.withOpacity(0.05)),
  //                         ),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             // NAYA: Length par tap lagane ke liye (Agar aapne _buildMenuItem update kar liya hai)
  //                             _buildMenuItem(
  //                               'assets/images/length.png',
  //                               'Length',
  //                               'Meters, inches, feet & more',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() {
  //                                   _currentActiveView = 'length'; // View change command
  //                                 });
  //                               },
  //                             ),
  //                             //_buildMenuItem('assets/images/percentage-discount-symbol.png', 'Weight & Mass', 'Kilograms, pounds, ounces...'),
  //                             _buildMenuItem(
  //                               'assets/images/weight.png',
  //                               'Weight & Mass',
  //                               'Kilograms, pounds, ounces...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() {
  //                                   _currentActiveView = 'weight'; // View change command
  //                                 });
  //                               },
  //                             ),
  //
  //                             // _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Area', 'Square meters, acres, hectares...'),
  //                             // _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Volume', 'Liters, gallons, cubic meters...'),
  //                             // _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Temperature', 'Celsius, Fahrenheit, Kelvin'),
  //                             // _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Speed', 'km/h, mph, knots & more'),
  //                             // _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Pressure', 'Pascal, bar, psi, atm...'),
  //                             // _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Energy', 'Joules, calories, kWh...'),
  //                             // _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Power', 'Watts, kilowatts, horsepower...'),
  //                             // _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Data Storage', 'Bytes, MB, GB, TB, PB...'),
  //                             _buildMenuItem(
  //                               'assets/images/area.png',
  //                               'Area',
  //                               'Square meters, acres, hectares...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'area');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/volume.png',
  //                               'Volume',
  //                               'Liters, gallons, cubic meters...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'volume');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/temperature.png',
  //                               'Temperature',
  //                               'Celsius, Fahrenheit, Kelvin',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'temperature');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/speed.png',
  //                               'Speed',
  //                               'km/h, mph, knots & more',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'speed');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/pressure.png',
  //                               'Pressure',
  //                               'Pascal, bar, psi, atm...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'pressure');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/energy.png',
  //                               'Energy',
  //                               'Joules, calories, kWh...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'energy');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/power.png',
  //                               'Power',
  //                               'Watts, kilowatts, horsepower...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'power');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/data_storage.png',
  //                               'Data Storage',
  //                               'Bytes, MB, GB, TB, PB...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'data storage');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/acceleration.png',
  //                               'Acceleration',
  //                               'm/s², g, ft/s²...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'acceleration');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/angle.png',
  //                               'Angle',
  //                               'Degree, Radian, Gradian...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'angle');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/data_transfer.png',
  //                               'Data Transfer',
  //                               'Mbps, MB/s, GB/s...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'data_transfer');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/force.png',
  //                               'Force',
  //                               'Newton, Dyne, Pound-force...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'force');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/roman_numerals.png',
  //                               'Roman Numerals',
  //                               'I, V, X, L, C, M...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'roman_numerals');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/torque.png',
  //                               'Torque',
  //                               'N·m, lb·ft, kgf·m...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'torque');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/volumetric_flow.png',
  //                               'Volumetric Flow',
  //                               'm³/s, L/min, gal/h...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'volumetric_flow');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/time.png',
  //                               'Time',
  //                               'Second, Minute, Hour, Day...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'time');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/numeric_base.png',
  //                               'Numeric Base',
  //                               'Binary, Octal, Decimal, Hex...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'numeric_base');
  //                               },
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/shoe_size.png',
  //                               'Shoe Size',
  //                               'US, UK, EU, CM...',
  //                               onTap: () {
  //                                 if (_isHapticsEnabled) HapticFeedback.selectionClick();
  //                                 setState(() => _currentActiveView = 'shoe_size');
  //                               },
  //                             ),
  //                           ],
  //                         ),
  //                       )
  //                     : const SizedBox.shrink(),
  //               ),
  //
  //               const SizedBox(height: 14),
  //
  //               // --- CATEGORY 2: OTHER TOOLS ---
  //               GestureDetector(
  //                 behavior: HitTestBehavior.opaque,
  //                 onTap: () {
  //                   setState(() {
  //                     _isOtherExpanded = !_isOtherExpanded;
  //                   });
  //                 },
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(left: 2.0, bottom: 10.0, right: 8.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       const Text(
  //                         'Other Tools',
  //                         style: TextStyle(
  //                           color: Colors.cyanAccent,
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.bold,
  //                           letterSpacing: 1.2,
  //                         ),
  //                       ),
  //                       Icon(
  //                         _isOtherExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
  //                         color: Colors.cyanAccent,
  //                         size: 24,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //
  //               // --- CARD VIEW SECTION 2 ---
  //               AnimatedSize(
  //                 duration: const Duration(milliseconds: 300),
  //                 curve: Curves.easeInOutCubic,
  //                 child: _isOtherExpanded
  //                     ? Container(
  //                         padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 0),
  //                         decoration: BoxDecoration(
  //                           color: surfaceColor.withOpacity(0.2),
  //                           borderRadius: BorderRadius.circular(24),
  //                           border: Border.all(color: Colors.white.withOpacity(0.05)),
  //                         ),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             _buildMenuItem(
  //                               'assets/images/percentage-discount-symbol.png',
  //                               'Discount',
  //                               'Calculate discounts',
  //                             ),
  //                             _buildMenuItem(
  //                               'assets/images/percentage-discount-symbol.png',
  //                               'EMI Calculator',
  //                               'Loan & Mortgage',
  //                             ),
  //                           ],
  //                         ),
  //                       )
  //                     : const SizedBox.shrink(),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // NAYA FUNCTION: Main Menu ka pura UI yahan shift kar diya
  Widget _buildMainMenu() {
    return Column(
      key: const ValueKey('MainMenuView'), // NAYA: AnimatedSwitcher ke liye Key zaroori hai
      children: [
        // --- 1. TOP BAR ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionButton(
                icon: Icons.settings_outlined,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {
                  if (_isHapticsEnabled) HapticFeedback.lightImpact();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                },
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('Tools & Converters', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (_showTopSearch) ...[
                ActionButton(
                  icon: Icons.search_rounded,
                  contentColor: textGrey,
                  bgColor: surfaceColor.withOpacity(0.5),
                  onTap: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                ),
                const SizedBox(width: 8),
              ],
              ActionButton(
                icon: Icons.arrow_forward_ios_rounded,
                contentColor: textGrey,
                bgColor: surfaceColor.withOpacity(0.5),
                onTap: () {
                  if (_isHapticsEnabled) HapticFeedback.lightImpact();
                  widget.onClose();
                },
              ),
            ],
          ),
        ),

        // --- 2. SCROLLABLE CONTENT ---
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 5, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar Widget
                _buildSearchBar(),
                const SizedBox(height: 14),

                // --- SEARCH LOGIC: Agar search khali hai toh Categories dikhao ---
                if (_searchQuery.isEmpty) ...[
                  _buildFavouriteCard(),
                  const SizedBox(height: 14),

                  // --- CATEGORY 1: UNIT CONVERTERS ---
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _isUnitExpanded = !_isUnitExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 10.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Unit Converters', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          Icon(_isUnitExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.cyanAccent, size: 24),
                        ],
                      ),
                    ),
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: _isUnitExpanded
                        ? Container(
                      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 0),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      // NAYA: Ye line automatically aapki _allTools list se buttons banayegi
                      child: Column(
                        children: _allTools.where((tool) => tool['isOther'] == false).map((tool) {
                          return _buildMenuItem(
                            tool['img'], tool['title'], tool['sub'],
                            onTap: () => _openView(tool['id']),
                          );
                        }).toList(),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 14),

                  // --- CATEGORY 2: OTHER TOOLS ---
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _isOtherExpanded = !_isOtherExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 10.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Other Tools', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          Icon(_isOtherExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.cyanAccent, size: 24),
                        ],
                      ),
                    ),
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: _isOtherExpanded
                        ? Container(
                      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 0),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      // NAYA: Ye line "Other Tools" category se automatically banayegi
                      child: Column(
                        children: _allTools.where((tool) => tool['isOther'] == true).map((tool) {
                          return _buildMenuItem(
                            tool['img'], tool['title'], tool['sub'],
                            onTap: () => _openView(tool['id']),
                          );
                        }).toList(),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),
                ]

                // --- SEARCH LOGIC: Agar search box mein type kiya gaya hai, toh filtered result dikhao ---
                else ...[
                  ..._allTools.where((tool) {
                    final titleMatch = tool['title'].toString().toLowerCase().contains(_searchQuery);
                    final subMatch = tool['sub'].toString().toLowerCase().contains(_searchQuery);
                    return titleMatch || subMatch;
                  }).map((tool) {
                    return _buildMenuItem(
                      tool['img'], tool['title'], tool['sub'],
                      onTap: () {
                        FocusScope.of(context).unfocus(); // Click hone par keyboard chupa do
                        _openView(tool['id']);
                      },
                    );
                  }).toList(),

                  // Agar search galat ho aur list khali ho jaye
                  if (_allTools.where((t) => t['title'].toString().toLowerCase().contains(_searchQuery) || t['sub'].toString().toLowerCase().contains(_searchQuery)).isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Center(
                        child: Text("No tools found for '$_searchQuery'", style: TextStyle(color: textGrey.withOpacity(0.7), fontSize: 16)),
                      ),
                    ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET 1: Search Bar ---
  // Widget _buildSearchBar() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: surfaceColor.withOpacity(0.4),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: Colors.white.withOpacity(0.05)),
  //     ),
  //     child: TextField(
  //       onChanged: (value) {
  //         // NAYA: Text change hone par state update hoga
  //         setState(() {
  //           _searchQuery = value.toLowerCase();
  //         });
  //       },
  //       style: const TextStyle(color: Colors.white, fontSize: 16),
  //       cursorColor: cyanColor,
  //       decoration: InputDecoration(
  //         hintText: 'Search',
  //         hintStyle: TextStyle(color: textGrey.withOpacity(0.5), fontSize: 15),
  //         prefixIcon: Icon(Icons.search_rounded, color: textGrey.withOpacity(0.7)),
  //         border: InputBorder.none,
  //         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  //       ),
  //     ),
  //   );
  // }

  // --- WIDGET 2: Favourite Card ---

  // --- WIDGET 1: Search Bar ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: _searchController, // NAYA: Controller yahan attach kiya
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: cyanColor,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: textGrey.withOpacity(0.5), fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, color: textGrey.withOpacity(0.7)),

          // NAYA: 'X' Clear Button Logic
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.close_rounded, color: textGrey.withOpacity(0.7)),
              tooltip: 'Clear search', // NAYA: Tooltip add kar diya hai
              onPressed: () { // FIX: onTap ki jagah onPressed aayega
                setState(() {
                  _searchController.clear(); // Text field ko visually empty karega
                  _searchQuery = ""; // Backend query reset karega
                  FocusScope.of(context).unfocus(); // Keyboard chupa dega
                });
              },
            )
                : null, // Agar search khali hai toh koi icon mat dikhao

          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFavouriteCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 24),
          const SizedBox(width: 16),
          const Text(
            'Favourite',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios_rounded, color: textGrey.withOpacity(0.3), size: 16),
        ],
      ),
    );
  }

  // NAYA: onTap parameter add kiya
  // Widget _buildMenuItem(String imagePath, String title, String subtitle, {VoidCallback? onTap}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 10.0),
  //     child: InkWell(
  //       onTap: onTap, // Click event yahan bind kiya
  //       borderRadius: BorderRadius.circular(16),
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  //         decoration: BoxDecoration(
  //           color: surfaceColor.withOpacity(0.4),
  //           borderRadius: BorderRadius.circular(16),
  //           border: Border.all(color: Colors.white.withOpacity(0.05)),
  //         ),
  //         child: Row(
  //           children: [
  //             Image.asset(
  //               imagePath,
  //               width: 50,
  //               height: 50,
  //               fit: BoxFit.contain,
  //               errorBuilder: (context, error, stackTrace) {
  //                 return const Icon(Icons.image_not_supported, color: Colors.white54, size: 30);
  //               },
  //             ),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               // child: Column(
  //               //   crossAxisAlignment: CrossAxisAlignment.start,
  //               //   children: [
  //               //     Text(
  //               //       title,
  //               //       style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
  //               //     ),
  //               //     const SizedBox(height: 4),
  //               //     Text(subtitle, style: TextStyle(color: textGrey.withOpacity(0.6), fontSize: 13)),
  //               //   ],
  //               // ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   _buildSearchBar(),
  //                   const SizedBox(height: 14),
  //
  //                   // --- LOGIC: Agar search box khali hai, toh normal UI dikhao ---
  //                   if (_searchQuery.isEmpty) ...[
  //                     _buildFavouriteCard(),
  //                     const SizedBox(height: 14),
  //
  //                     // --- CATEGORY 1: UNIT CONVERTERS ---
  //                     GestureDetector(
  //                       behavior: HitTestBehavior.opaque,
  //                       onTap: () => setState(() => _isUnitExpanded = !_isUnitExpanded),
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(left: 2.0, bottom: 10.0, right: 8.0),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             const Text('Unit Converters', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
  //                             Icon(_isUnitExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.cyanAccent, size: 24),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //
  //                     AnimatedSize(
  //                       duration: const Duration(milliseconds: 300),
  //                       curve: Curves.easeInOutCubic,
  //                       child: _isUnitExpanded
  //                           ? Container(
  //                         padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 0),
  //                         decoration: BoxDecoration(
  //                           color: surfaceColor.withOpacity(0.2),
  //                           borderRadius: BorderRadius.circular(24),
  //                           border: Border.all(color: Colors.white.withOpacity(0.05)),
  //                         ),
  //                         // NAYA: Hardcoded ki jagah list se automatically generate kiya
  //                         child: Column(
  //                           children: _allTools.where((tool) => tool['isOther'] == false).map((tool) {
  //                             return _buildMenuItem(
  //                               tool['img'], tool['title'], tool['sub'],
  //                               onTap: () => _openView(tool['id']),
  //                             );
  //                           }).toList(),
  //                         ),
  //                       )
  //                           : const SizedBox.shrink(),
  //                     ),
  //
  //                     const SizedBox(height: 14),
  //
  //                     // --- CATEGORY 2: OTHER TOOLS ---
  //                     GestureDetector(
  //                       behavior: HitTestBehavior.opaque,
  //                       onTap: () => setState(() => _isOtherExpanded = !_isOtherExpanded),
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(left: 2.0, bottom: 10.0, right: 8.0),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             const Text('Other Tools', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
  //                             Icon(_isOtherExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.cyanAccent, size: 24),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //
  //                     AnimatedSize(
  //                       duration: const Duration(milliseconds: 300),
  //                       curve: Curves.easeInOutCubic,
  //                       child: _isOtherExpanded
  //                           ? Container(
  //                         padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 0),
  //                         decoration: BoxDecoration(
  //                           color: surfaceColor.withOpacity(0.2),
  //                           borderRadius: BorderRadius.circular(24),
  //                           border: Border.all(color: Colors.white.withOpacity(0.05)),
  //                         ),
  //                         child: Column(
  //                           children: _allTools.where((tool) => tool['isOther'] == true).map((tool) {
  //                             return _buildMenuItem(
  //                               tool['img'], tool['title'], tool['sub'],
  //                               onTap: () => _openView(tool['id']),
  //                             );
  //                           }).toList(),
  //                         ),
  //                       )
  //                           : const SizedBox.shrink(),
  //                     ),
  //                   ]
  //
  //                   // --- LOGIC: Agar search box mein kuch type hua hai, toh Filtered List dikhao ---
  //                   else ...[
  //                     ..._allTools.where((tool) {
  //                       final titleMatch = tool['title'].toString().toLowerCase().contains(_searchQuery);
  //                       final subMatch = tool['sub'].toString().toLowerCase().contains(_searchQuery);
  //                       return titleMatch || subMatch;
  //                     }).map((tool) {
  //                       return _buildMenuItem(
  //                         tool['img'], tool['title'], tool['sub'],
  //                         onTap: () {
  //                           FocusScope.of(context).unfocus(); // Keyboard hide karne ke liye
  //                           _openView(tool['id']);
  //                         },
  //                       );
  //                     }).toList(),
  //
  //                     // Agar search se kuch match nahi hua
  //                     if (_allTools.where((t) => t['title'].toString().toLowerCase().contains(_searchQuery) || t['sub'].toString().toLowerCase().contains(_searchQuery)).isEmpty)
  //                       Padding(
  //                         padding: const EdgeInsets.only(top: 40.0),
  //                         child: Center(
  //                           child: Text("No tools found for '$_searchQuery'", style: TextStyle(color: textGrey.withOpacity(0.7), fontSize: 16)),
  //                         ),
  //                       ),
  //                   ]
  //                 ],
  //               ),
  //             ),
  //             Icon(Icons.arrow_forward_ios_rounded, color: textGrey.withOpacity(0.3), size: 16),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

// --- WIDGET 3: Menu Item Button ---

  Widget _buildMenuItem(String imagePath, String title, String subtitle, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: onTap, // Click event yahan bind kiya
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Image.asset(
                imagePath,
                width: 45,
                height: 45,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, color: Colors.white54, size: 30);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: textGrey.withOpacity(0.6), fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: textGrey.withOpacity(0.3), size: 16),
            ],
          ),
        ),
      ),
    );
  }

}
