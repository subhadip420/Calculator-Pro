import 'dart:convert';

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
import 'app_colors.dart';
import 'main.dart';
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
  // final Color bgColor = const Color(0xFF0E131D);
  // final Color surfaceColor = const Color(0xFF1E2638);
  // final Color cyanColor = const Color(0xFF4CD7F6);
  // final Color textGrey = const Color(0xFFDBC2AD);

  // bool get isDark => appThemeNotifier.value == 'dark';
  // Color get bgColor => isDark ? const Color(0xFF0E131D) : const Color(0xFFE0E6FC);
  // Color get surfaceColor => isDark ? const Color(0xFF1E2638) : const Color(0xFFFFFFFF);
  // Color get cyanColor => isDark ? Colors.cyanAccent : Colors.cyan;
  // Color get orangeColor => const Color(0xFFFF9500); // Orange bhi same
  // Color get operatorBgColor => isDark ? orangeColor.withOpacity(0.15) : orangeColor.withOpacity(0.3);
  // Color get redColor => const Color(0xFFFFB4AB);
  // Color get textGrey => isDark ? const Color(0xFFDBC2AD) : const Color(0xFF605D5D);
  // Color get white => isDark ? Colors.white : Colors.black87;

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

  List<Map<String, dynamic>> _favoriteTools = [];

  // NAYA: SharedPreferences se real-time data load karne ka function
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favList = prefs.getStringList('favorite_tools') ?? [];

    if (mounted) {
      setState(() {
        _favoriteTools = favList.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
      });
    }
  }

  final List<Map<String, dynamic>> _allTools = [
    // --- UNIT CONVERTERS CATEGORY ---
    {'id': 'acceleration', 'title': 'Acceleration', 'sub': 'm/s², g, ft/s²...', 'img': 'assets/images/acceleration.png', 'category': 'unit_converter'},
    {'id': 'angle', 'title': 'Angle', 'sub': 'Degree, Radian, Gradian...', 'img': 'assets/images/angle.png', 'category': 'unit_converter'},
    {'id': 'area', 'title': 'Area', 'sub': 'Square meters, acres, hectares...', 'img': 'assets/images/area.png', 'category': 'unit_converter'},
    {'id': 'data storage', 'title': 'Data Storage', 'sub': 'Bytes, MB, GB, TB, PB...', 'img': 'assets/images/data_storage.png', 'category': 'unit_converter'},
    {'id': 'data_transfer', 'title': 'Data Transfer', 'sub': 'Mbps, MB/s, GB/s...', 'img': 'assets/images/data_transfer.png', 'category': 'unit_converter'},
    {'id': 'energy', 'title': 'Energy', 'sub': 'Joules, calories, kWh...', 'img': 'assets/images/energy.png', 'category': 'unit_converter'},
    {'id': 'force', 'title': 'Force', 'sub': 'Newton, Dyne, Pound-force...', 'img': 'assets/images/force.png', 'category': 'unit_converter'},
    {'id': 'length', 'title': 'Length', 'sub': 'Meters, inches, feet & more', 'img': 'assets/images/length.png', 'category': 'unit_converter'},
    {'id': 'numeric_base', 'title': 'Numeric Base', 'sub': 'Binary, Octal, Decimal, Hex...', 'img': 'assets/images/numeric_base.png', 'category': 'unit_converter'},
    {'id': 'power', 'title': 'Power', 'sub': 'Watts, kilowatts, horsepower...', 'img': 'assets/images/power.png', 'category': 'unit_converter'},
    {'id': 'pressure', 'title': 'Pressure', 'sub': 'Pascal, bar, psi, atm...', 'img': 'assets/images/pressure.png', 'category': 'unit_converter'},
    {'id': 'roman_numerals', 'title': 'Roman Numerals', 'sub': 'I, V, X, L, C, M...', 'img': 'assets/images/roman_numerals.png', 'category': 'unit_converter'},
    {'id': 'shoe_size', 'title': 'Shoe Size', 'sub': 'US, UK, EU, CM...', 'img': 'assets/images/shoe_size.png', 'category': 'unit_converter'},
    {'id': 'speed', 'title': 'Speed', 'sub': 'km/h, mph, knots & more', 'img': 'assets/images/speed.png', 'category': 'unit_converter'},
    {'id': 'temperature', 'title': 'Temperature', 'sub': 'Celsius, Fahrenheit, Kelvin', 'img': 'assets/images/temperature.png', 'category': 'unit_converter'},
    {'id': 'time', 'title': 'Time', 'sub': 'Second, Minute, Hour, Day...', 'img': 'assets/images/time.png', 'category': 'unit_converter'},
    {'id': 'torque', 'title': 'Torque', 'sub': 'N·m, lb·ft, kgf·m...', 'img': 'assets/images/torque.png', 'category': 'unit_converter'},
    {'id': 'volume', 'title': 'Volume', 'sub': 'Liters, gallons, cubic meters...', 'img': 'assets/images/volume.png', 'category': 'unit_converter'},
    {'id': 'volumetric_flow', 'title': 'Volumetric Flow', 'sub': 'm³/s, L/min, gal/h...', 'img': 'assets/images/volumetric_flow.png', 'category': 'unit_converter'},
    {'id': 'weight', 'title': 'Weight & Mass', 'sub': 'Kilograms, pounds, ounces...', 'img': 'assets/images/weight.png', 'category': 'unit_converter'},
    // --- OTHER TOOLS CATEGORY ---
    {'id': 'discount', 'title': 'Discount', 'sub': 'Calculate discounts', 'img': 'assets/images/percentage-discount-symbol.png', 'category': 'other_tools'},
    {'id': 'emi', 'title': 'EMI Calculator', 'sub': 'Loan & Mortgage', 'img': 'assets/images/percentage-discount-symbol.png', 'category': 'other_tools'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadHapticsSetting();
    _initScrollController();
    _loadFavorites();
    // NAYA: Scroll Listener - Check karta hai ki kitna scroll hua hai
    // _scrollController.addListener(() {
    //   if (_scrollController.offset > 80 && !_showTopSearch) {
    //     // Agar 80px se zyada scroll ho gaya toh top search button dikhao
    //     setState(() {
    //       _showTopSearch = true;
    //     });
    //   } else if (_scrollController.offset <= 80 && _showTopSearch) {
    //     // Upar aane par wapas hide kar do
    //     setState(() {
    //       _showTopSearch = false;
    //     });
    //   }
    // });
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

  // NAYA: Scroll Controller ko initialize karne ka alag function
  void _initScrollController({double initialOffset = 0.0}) {
    _scrollController = ScrollController(initialScrollOffset: initialOffset); // Wahi position se start hoga

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return; // NAYA: Animation ke time crash na ho isliye safety check

      if (_scrollController.offset > 80 && !_showTopSearch) {
        setState(() {
          _showTopSearch = true;
        });
      } else if (_scrollController.offset <= 80 && _showTopSearch) {
        setState(() {
          _showTopSearch = false;
        });
      }
    });
  }

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
    _scrollController.dispose();

    // 2. Naya controller banalo ekdum usi SAVED OFFSET ke sath
    _initScrollController(initialOffset: _savedScrollOffset);
    _loadFavorites();
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
          //onBack: () => setState(() => _currentActiveView = null),
        onBack: _closeView);

      case 'weight':
        return WeightMassConverterView(
          key: const ValueKey('Weight'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'area':
        return AreaConverterView(
            key: const ValueKey('Area'),
        //     onBack: () => setState(() => _currentActiveView = null)
        // );
            onBack: _closeView);
      case 'volume':
        return VolumeConverterView(
          key: const ValueKey('Volume'),
          onBack: () => setState(() => _currentActiveView = null),
        );
      case 'temperature':
        return TemperatureConverterView(
          key: const ValueKey('Temp'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'speed':
        return SpeedConverterView(
          key: const ValueKey('Speed'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'pressure':
        return PressureConverterView(
          key: const ValueKey('Pressure'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'energy':
        return EnergyConverterView(
          key: const ValueKey('Energy'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'power':
        return PowerConverterView(
          key: const ValueKey('Power'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'data storage':
        return DataStorageConverterView(
          key: const ValueKey('Data'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'acceleration':
        return AccelerationConverterView(
          key: const ValueKey('Acceleration'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'angle':
        return AngleConverterView(
          key: const ValueKey('Angle'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'data_transfer':
        return DataTransferConverterView(
          key: const ValueKey('Data Transfer'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'force':
        return ForceConverterView(
          key: const ValueKey('Force'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'roman_numerals':
        return RomanNumeralsConverterView(
          key: const ValueKey('Roman Numerals'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'torque':
        return TorqueConverterView(
          key: const ValueKey('Torque'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'volumetric_flow':
        return VolumetricFlowConverterView(
          key: const ValueKey('Volumetric Flow'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'time':
        return TimeConverterView(key: const ValueKey('Time'),
            //onBack: () => setState(() => _currentActiveView = null));
            onBack: _closeView);
      case 'numeric_base':
        return NumericBaseConverterView(
          key: const ValueKey('Numeric Base'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
      case 'shoe_size':
        return ShoeSizeConverterView(
          key: const ValueKey('Shoe Size'),
        //   onBack: () => setState(() => _currentActiveView = null),
        // );
            onBack: _closeView);
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
        color: AppColors.bgColor(context),
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
            child: _getActiveViewWidget(),
          ),
        ),
      ),
    );
  }

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
                contentColor: AppColors.textGrey(context),
                bgColor: AppColors.surfaceColor(context).withOpacity(0.5),
                onTap: () {
                  if (_isHapticsEnabled) HapticFeedback.lightImpact();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Tools & Converters', style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (_showTopSearch) ...[
                ActionButton(
                  icon: Icons.search_rounded,
                  contentColor: AppColors.textGrey(context),
                  bgColor: AppColors.surfaceColor(context).withOpacity(0.5),
                  onTap: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                ),
                const SizedBox(width: 8),
              ],
              ActionButton(
                icon: Icons.arrow_forward_ios_rounded,
                contentColor: AppColors.textGrey(context),
                bgColor: AppColors.surfaceColor(context).withOpacity(0.5),
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
                          Text('Unit Converters', style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          Icon(_isUnitExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded, color: AppColors.cyanColor(context), size: 24),
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
                        color: AppColors.surfaceColor(context).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      // NAYA: Ye line automatically aapki _allTools list se buttons banayegi
                      child: Column(
                        children: _allTools.where((tool) => tool['category'] == 'unit_converter').map((tool) {
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
                          Text('Other Tools', style: TextStyle(color: AppColors.cyanColor(context), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          Icon(_isOtherExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded, color: AppColors.cyanColor(context), size: 24),
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
                        color: AppColors.surfaceColor(context).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      // NAYA: Ye line "Other Tools" category se automatically banayegi
                      child: Column(
                        children: _allTools.where((tool) => tool['category'] == 'other_tools').map((tool) {
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
                        child: Text("No tools found for '$_searchQuery'", style: TextStyle(color: AppColors.textGrey(context).withOpacity(0.7), fontSize: 16)),
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
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context).withOpacity(0.4),
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
        style: TextStyle(color: AppColors.textColor(context), fontSize: 16),
        cursorColor: AppColors.cyanColor(context),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: AppColors.textGrey(context).withOpacity(0.5), fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textGrey(context).withOpacity(0.7)),

          // NAYA: 'X' Clear Button Logic
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.close_rounded, color: AppColors.textGrey(context).withOpacity(0.7)),
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

  // Widget _buildFavouriteCard() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  //     decoration: BoxDecoration(
  //       color: surfaceColor.withOpacity(0.4),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: Colors.white.withOpacity(0.05)),
  //     ),
  //     child: Row(
  //       children: [
  //         const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 24),
  //         const SizedBox(width: 16),
  //         const Text(
  //           'Favourite',
  //           style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
  //         ),
  //         const Spacer(),
  //         Icon(Icons.arrow_forward_ios_rounded, color: textGrey.withOpacity(0.3), size: 16),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildFavouriteCard() {
    // Agar koi favorite nahi hai, toh card ko hide rakho
    if (_favoriteTools.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 20),
              const SizedBox(width: 8),
               Text(
                'Favorites',
                style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid Section (4 items per row)
          GridView.builder(
            shrinkWrap: true, // Scrollable column ke andar error se bachane ke liye
            physics: const NeverScrollableScrollPhysics(), // Scroll parent handle karega
            itemCount: _favoriteTools.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 1 Row mein 4 items
              crossAxisSpacing: 10,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Icon aur text ke height-width ratio ko set karne ke liye
            ),
            itemBuilder: (context, index) {
              final tool = _favoriteTools[index];
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus(); // Keyboard hide karein
                  _openView(tool['id']); // Direct tool open karein
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.bgColor(context).withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Image.asset(
                        tool['img'],
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, color: Colors.white54, size: 24);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title Text
                    Text(
                      tool['title'],
                      textAlign: TextAlign.center,
                      maxLines: 1, // Text ko ek line me rakhega
                      overflow: TextOverflow.ellipsis, // Agar lamba hua toh '...' dikhayega
                      style: TextStyle(
                        color: AppColors.textGrey(context).withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String imagePath, String title, String subtitle, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: onTap, // Click event yahan bind kiya
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context).withOpacity(0.4),
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
                      style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: AppColors.textGrey(context).withOpacity(0.6), fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textGrey(context).withOpacity(0.3), size: 16),
            ],
          ),
        ),
      ),
    );
  }

}
