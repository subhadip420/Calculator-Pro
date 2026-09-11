import 'package:calculator_pro/settings_page.dart';
import 'package:flutter/material.dart';
import 'action_button.dart'; // NAYA: Aapke custom ActionButton ko import kiya

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

  // 2. NAYA: Scroll tracking ke liye variables
  late ScrollController _scrollController;
  bool _showTopSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: bgColor, // Main screen ka exact background color
      child: SafeArea(
        child: Column(
          children: [
            // --- 1. TOP BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Settings Button (Ab ActionButton use ho raha hai)
                  ActionButton(
                    icon: Icons.settings_outlined,
                    contentColor: textGrey,
                    bgColor: surfaceColor.withOpacity(0.5),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                    },
                  ),

                  const SizedBox(width: 16),

                  // Center: Title
                  const Expanded( // Expanded ki wajah se Back button automatically right me chala jayega
                    child: Text(
                      'Tools & Converters',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),

                  // 3. NAYA: Conditional Search Button (Sirf scroll karne par dikhega)
                  if (_showTopSearch) ...[
                    ActionButton(
                      icon: Icons.search_rounded,
                      contentColor: textGrey,
                      bgColor: surfaceColor.withOpacity(0.5),
                      onTap: () {
                        // Jab tap hoga toh smoothly wapas top par scroll kar dega
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                    const SizedBox(width: 8), // Search aur Back ke beech gap
                  ],

                  // Right: Back Button (Ab ActionButton use ho raha hai)
                  ActionButton(
                    icon: Icons.arrow_forward_ios_rounded,
                    contentColor: textGrey,
                    bgColor: surfaceColor.withOpacity(0.5),
                    onTap: widget.onClose, // widget.onClose kyunki ye StatefulWidget hai
                  ),
                ],
              ),
            ),

            // --- 2. SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController, // NAYA: Controller attach kiya
                physics: const BouncingScrollPhysics(), // Premium smooth scroll
                padding: const EdgeInsets.fromLTRB(18, 5, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Widget Call kiya
                    _buildSearchBar(),

                    const SizedBox(height: 14),
                    // Favourite Card Widget Call kiya
                    _buildFavouriteCard(),

                    // const SizedBox(height: 14),
                    //
                    // // --- CATEGORY TEXT ---
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 2.0, bottom: 10.0),
                    //   child: Text(
                    //     'Unit Converters',
                    //     style: TextStyle(
                    //       color: Colors.cyanAccent,
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.bold,
                    //       letterSpacing: 1.2,
                    //     ),
                    //   ),
                    // ),
                    //
                    // // --- CARD VIEW WALA SECTION 1 ---
                    // Container(
                    //   padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 0),
                    //   decoration: BoxDecoration(
                    //     color: surfaceColor.withOpacity(0.2),
                    //     borderRadius: BorderRadius.circular(24),
                    //     border: Border.all(color: Colors.white.withOpacity(0.05)),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //
                    //
                    //       // Menu Items
                    //       _buildMenuItem(
                    //         'assets/images/percentage-discount-symbol.png',
                    //         'Length',
                    //         'Meters, inches, feet & more',
                    //       ),
                    //       _buildMenuItem(
                    //         'assets/images/percentage-discount-symbol.png',
                    //         'Weight & Mass',
                    //         'Kilograms, pounds, ounces...',
                    //       ),
                    //       _buildMenuItem(
                    //           'assets/images/percentage-discount-symbol.png',
                    //           'Area',
                    //           'Square meters, acres, hectares...'
                    //       ),
                    //       _buildMenuItem(
                    //           'assets/images/percentage-discount-symbol.png',
                    //           'Volume',
                    //           'Liters, gallons, cubic meters...'
                    //       ),
                    //       _buildMenuItem(
                    //           'assets/images/percentage-discount-symbol.png',
                    //           'Temperature',
                    //           'Celsius, Fahrenheit, Kelvin'
                    //       ),
                    //       _buildMenuItem(
                    //           'assets/images/percentage-discount-symbol.png',
                    //           'Speed',
                    //           'km/h, mph, knots & more'
                    //       ),
                    //       _buildMenuItem(
                    //           'assets/images/percentage-discount-symbol.png',
                    //           'Pressure',
                    //           'Pascal, bar, psi, atm...'
                    //       ),
                    //       _buildMenuItem(
                    //           'assets/images/percentage-discount-symbol.png',
                    //           'Energy',
                    //           'Joules, calories, kWh...'
                    //       ),
                    //       _buildMenuItem(
                    //           'assets/images/percentage-discount-symbol.png',
                    //           'Power',
                    //           'Watts, kilowatts, horsepower...'
                    //       ),
                    //       _buildMenuItem(
                    //           'assets/images/percentage-discount-symbol.png',
                    //           'Data Storage',
                    //           'Bytes, MB, GB, TB, PB...'
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    //
                    // const SizedBox(height: 14),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 2.0, bottom: 10.0),
                    //   child: Text(
                    //     'Other Tools',
                    //     style: TextStyle(
                    //       color: Colors.cyanAccent,
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.bold,
                    //       letterSpacing: 1.2,
                    //     ),
                    //   ),
                    // ),
                    //
                    // // --- CARD VIEW WALA SECTION 2 ---
                    // Container(
                    //   padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 0),
                    //   decoration: BoxDecoration(
                    //     color: surfaceColor.withOpacity(0.2),
                    //     borderRadius: BorderRadius.circular(24),
                    //     border: Border.all(color: Colors.white.withOpacity(0.05)),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       // Menu Items
                    //       _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Discount', 'Calculate discounts'),
                    //       _buildMenuItem('assets/images/percentage-discount-symbol.png', 'EMI Calculator', 'Loan & Mortgage'),
                    //     ],
                    //   ),
                    // ),

                    const SizedBox(height: 14),

                    // --- CATEGORY 1: UNIT CONVERTERS ---
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _isUnitExpanded = !_isUnitExpanded; // Open hai to close, close hai to open
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2.0, bottom: 10.0, right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Text left, arrow right
                          children: [
                            const Text(
                              'Unit Converters',
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            // Expand/Collapse Arrow Icon
                            Icon(
                              _isUnitExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: Colors.cyanAccent,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- CARD VIEW SECTION 1 (Smooth Animation ke sath) ---
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Length', 'Meters, inches, feet & more'),
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Weight & Mass', 'Kilograms, pounds, ounces...'),
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Area', 'Square meters, acres, hectares...'),
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Volume', 'Liters, gallons, cubic meters...'),
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Temperature', 'Celsius, Fahrenheit, Kelvin'),
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Speed', 'km/h, mph, knots & more'),
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Pressure', 'Pascal, bar, psi, atm...'),
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Energy', 'Joules, calories, kWh...'),
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Power', 'Watts, kilowatts, horsepower...'),
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Data Storage', 'Bytes, MB, GB, TB, PB...'),
                          ],
                        ),
                      )
                          : const SizedBox.shrink(), // Agar close hai toh space zero ho jayega
                    ),

                    const SizedBox(height: 14),

                    // --- CATEGORY 2: OTHER TOOLS ---
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _isOtherExpanded = !_isOtherExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2.0, bottom: 10.0, right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Other Tools',
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Icon(
                              _isOtherExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: Colors.cyanAccent,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- CARD VIEW SECTION 2 ---
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'Discount', 'Calculate discounts'),
                            _buildMenuItem('assets/images/percentage-discount-symbol.png', 'EMI Calculator', 'Loan & Mortgage'),
                          ],
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET 1: Search Bar ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: cyanColor,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: textGrey.withOpacity(0.5), fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, color: textGrey.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  // --- WIDGET 2: Favourite Card ---
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

  // Stylish Menu Item Design (Image + Card View)
  Widget _buildMenuItem(String imagePath, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: surfaceColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Image Box
            Image.asset(
              imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, color: Colors.white54, size: 30);
              },
            ),

            const SizedBox(width: 8),

            // Text Content
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

            // Right Arrow
            Icon(Icons.arrow_forward_ios_rounded, color: textGrey.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }
}