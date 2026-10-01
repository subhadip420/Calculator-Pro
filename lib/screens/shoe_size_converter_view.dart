import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';
import '../custom_shoe_size_selector_sheet.dart';
import '../custom_top_bar.dart'; // Apna correct path check kar lena
import '../custom_unit_selector_sheet.dart';

class ShoeSizeConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const ShoeSizeConverterView({super.key, required this.onBack});

  @override
  State<ShoeSizeConverterView> createState() => _ShoeSizeConverterViewState();
}

class _ShoeSizeConverterViewState extends State<ShoeSizeConverterView> {
  bool _isHapticsEnabled = true;

  String _selectedCategory = 'Man';
  int _currentIndex = 0;

  final Map<String, Map<String, List<String>>> shoeSizeData = {
    'Man': {
      'US': [
        '3.5',
        '4',
        '4.5',
        '5',
        '5.5',
        '6',
        '6.5',
        '7',
        '7.5',
        '8',
        '8.5',
        '9',
        '9.5',
        '10',
        '10.5',
        '11',
        '11.5',
        '12',
        '12.5',
        '13',
        '13.5',
        '14',
      ],
      'UK': [
        '3',
        '3.5',
        '4',
        '4.5',
        '5',
        '5.5',
        '6',
        '6.5',
        '7',
        '7.5',
        '8',
        '8.5',
        '9',
        '9.5',
        '10',
        '10.5',
        '11',
        '11.5',
        '12',
        '12.5',
        '13',
        '13.5',
      ],
      'EU': [
        '35',
        '35.5',
        '36',
        '37',
        '37.5',
        '38',
        '38.5',
        '39',
        '40',
        '41',
        '41.5',
        '42',
        '42.5',
        '43',
        '44',
        '44.5',
        '45',
        '45.5',
        '46',
        '47',
        '48',
        '49',
      ],
      'AU': [
        '3',
        '3.5',
        '4',
        '4.5',
        '5',
        '5.5',
        '6',
        '6.5',
        '7',
        '7.5',
        '8',
        '8.5',
        '9',
        '9.5',
        '10',
        '10.5',
        '11',
        '11.5',
        '12',
        '12.5',
        '13',
        '13.5',
      ],
      'JP': [
        '21.5',
        '22',
        '22.5',
        '23',
        '23.5',
        '24',
        '24.5',
        '25',
        '25.5',
        '26',
        '26.5',
        '27.5',
        '27.9',
        '28.2',
        '28.5',
        '29',
        '29.5',
        '30',
        '30.5',
        '31',
        '31.5',
        '32',
      ],
      'cm': [
        '22.8',
        '23.1',
        '23.5',
        '23.8',
        '24.1',
        '24.5',
        '24.8',
        '25.1',
        '25.4',
        '25.7',
        '26',
        '26.5',
        '26.8',
        '27.1',
        '27.3',
        '27.5',
        '27.9',
        '28.3',
        '28.6',
        '28.9',
        '29.2',
        '29.5',
      ],
      'in': [
        '9',
        '9 1/8',
        '9 1/4',
        '9 3/8',
        '9 1/2',
        '9 5/8',
        '9 3/4',
        '9 7/8',
        '10',
        '10 1/8',
        '10 1/4',
        '10 1/2',
        '10 5/8',
        '10 3/4',
        '10 7/8',
        '11',
        '11 1/8',
        '11 1/4',
        '11 3/8',
        '11 1/2',
        '11 5/8',
        '11 3/4',
      ],
    },
    'Women': {
      'US': [
        '5',
        '5.5',
        '6',
        '6.5',
        '7',
        '7.5',
        '8',
        '8.5',
        '9',
        '9.5',
        '10',
        '10.5',
        '11',
        '11.5',
        '12',
        '12.5',
        '13',
        '13.5',
        '14',
        '14.5',
        '15',
        '15.5',
      ],
      'UK': [
        '2.5',
        '3',
        '3.5',
        '4',
        '4.5',
        '5',
        '5.5',
        '6',
        '6.5',
        '7',
        '7.5',
        '8',
        '8.5',
        '9',
        '9.5',
        '10',
        '10.5',
        '11',
        '11.5',
        '12',
        '12.5',
        '13',
      ],
      'EU': [
        '35',
        '35.5',
        '36',
        '37',
        '37.5',
        '38',
        '38.5',
        '39',
        '40',
        '41',
        '41.5',
        '42',
        '42.5',
        '43',
        '44',
        '44.5',
        '45',
        '45.5',
        '46',
        '47',
        '48',
        '49',
      ],
      'AU': [
        '3.5',
        '4',
        '4.5',
        '5',
        '5.5',
        '6',
        '6.5',
        '7',
        '7.5',
        '8',
        '8.5',
        '9',
        '9.5',
        '10',
        '10.5',
        '11',
        '11.5',
        '12',
        '12.5',
        '13',
        '13.5',
        '14',
      ],
      'JP': [
        '21',
        '21.5',
        '22',
        '22.5',
        '23',
        '23.5',
        '24',
        '24.5',
        '25',
        '25.5',
        '26',
        '26.5',
        '27',
        '27.5',
        '28',
        '28.5',
        '29',
        '29.5',
        '30',
        '30.5',
        '31',
        '31.5',
      ],
      'cm': [
        '22.8',
        '23.1',
        '23.5',
        '23.8',
        '24.1',
        '24.5',
        '24.8',
        '25.1',
        '25.4',
        '25.7',
        '26',
        '26.5',
        '26.8',
        '27.1',
        '27.3',
        '27.5',
        '27.9',
        '28.3',
        '28.6',
        '28.9',
        '29.2',
        '29.5',
      ],
      'in': [
        '9',
        '9 1/8',
        '9 1/4',
        '9 3/8',
        '9 1/2',
        '9 5/8',
        '9 3/4',
        '9 7/8',
        '10',
        '10 1/8',
        '10 1/4',
        '10 1/2',
        '10 5/8',
        '10 3/4',
        '10 7/8',
        '11',
        '11 1/8',
        '11 1/4',
        '11 3/8',
        '11 1/2',
        '11 5/8',
        '11 3/4',
      ],
    },
    'Boy': {
      'US': ['11.5', '12', '12.5', '13', '13.5', '1', '1.5', '2', '2.5', '3', '3.5', '4', '4.5', '5'],
      'UK': ['11', '11.5', '12', '12.5', '13', '13.5', '1', '1.5', '2', '2.5', '3', '3.5', '4', '4.5'],
      'EU': ['29', '29.7', '30.5', '31', '31.5', '33', '33.5', '34', '34.7', '35', '35.5', '36', '37', '37.5'],
      'JP': ['16.5', '17', '17.5', '18', '18.5', '19', '19.5', '20', '20.5', '21', '21.5', '22', '22.5', '23'],
      // FIX: Added dummy lists to match lengths and prevent Null Check Error
      'AU': ['-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-'],
      'cm': ['-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-'],
      'in': ['-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-'],
    },
    'Girl': {
      'US': ['9.5', '10', '10.5', '11', '11.5', '12', '12.5', '13', '13.5', '1', '1.5', '2', '2.5', '3', '3.5', '4'],
      'UK': ['8', '8.5', '9', '9.5', '10', '10.5', '11', '11.5', '12', '12.5', '13', '13.5', '1', '1.5', '2', '2.5'],
      'EU': [
        '26',
        '26.5',
        '27',
        '27.5',
        '28',
        '28.5',
        '29',
        '30',
        '30.5',
        '31',
        '31.5',
        '32.2',
        '33',
        '33.5',
        '34',
        '35',
      ],
      'JP': [
        '14.5',
        '15',
        '15.5',
        '16',
        '16.5',
        '17',
        '17.5',
        '18',
        '18.5',
        '19',
        '19.5',
        '20',
        '20.5',
        '21',
        '21.5',
        '22',
      ],
      // FIX: Added dummy lists to match lengths and prevent Null Check Error
      'AU': ['-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-'],
      'cm': ['-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-'],
      'in': ['-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-'],
    },
  };

  @override
  void initState() {
    super.initState();
    _loadHaptics();
  }

  Future<void> _loadHaptics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    });
  }

  void _openSizePicker(String regionKey, String regionName) async {
    if (_isHapticsEnabled) HapticFeedback.selectionClick();
    List<String> availableSizes = shoeSizeData[_selectedCategory]![regionKey]!;

    final int? newIndex = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        // Yahan apni NEW sheet call karni hai
        return ShoeSizeSelectorSheet(
          regionName: regionName,
          sizes: availableSizes,
          selectedIndex: _currentIndex,
          isHapticsEnabled: _isHapticsEnabled,
        );
      },
    );

    if (newIndex != null) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  Widget _buildCategoryButton(String title, IconData icon) {
    bool isSelected = _selectedCategory == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isHapticsEnabled && !isSelected) HapticFeedback.selectionClick();
          setState(() {
            _selectedCategory = title;
            _currentIndex = 0; // NAYA: Category change par index reset kar do default (0) par
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.cyanColor(context).withOpacity(0.15)
                : AppColors.surfaceColor(context).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.cyanColor(context) : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.cyanColor(context) : AppColors.textGrey(context), size: 24),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.cyanColor(context) : AppColors.textGrey(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShoeRow(String badgeText, String title, String regionKey, {bool isBottom = false, bool isTop = false}) {
    String currentValue = shoeSizeData[_selectedCategory]![regionKey]![_currentIndex];

    return InkWell(
      onTap: () => _openSizePicker(regionKey, title), // Click event
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context).withOpacity(0.6),
          border: Border(
            bottom: isBottom
                ? BorderSide.none
                : BorderSide(color: AppColors.textColor(context).withOpacity(0.05), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bgColor(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textColor(context).withOpacity(0.1)),
              ),
              alignment: Alignment.center,
              child: Text(
                badgeText,
                style: TextStyle(color: AppColors.textGrey(context), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: AppColors.textColor(context), fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              currentValue,
              style: TextStyle(color: AppColors.cyanColor(context), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey(context).withOpacity(0.6), size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTopBar(
          toolId: 'shoe_size',
          title: 'Shoe Size',
          iconPath: 'assets/images/shoe_size.png',
          onBack: widget.onBack,
          isHapticsEnabled: _isHapticsEnabled,
        ),

        // --- CATEGORY SELECTOR ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              _buildCategoryButton('Man', Icons.man_rounded),
              _buildCategoryButton('Women', Icons.woman_rounded),
              _buildCategoryButton('Boy', Icons.boy_rounded),
              _buildCategoryButton('Girl', Icons.girl_rounded),
            ],
          ),
        ),

        // --- CONVERSION LIST ---
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'Common',
                    style: TextStyle(
                      color: AppColors.textGrey(context).withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      // RegionKey bhejna zaroori hai map access ke liye
                      _buildShoeRow('US', 'United States', 'US', isTop: true),
                      _buildShoeRow('UK', 'United Kingdom', 'UK'),
                      _buildShoeRow('EU', 'European Union', 'EU'),
                      _buildShoeRow('AU', 'Australia', 'AU'),
                      _buildShoeRow('JP', 'Japan', 'JP', isBottom: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'Other',
                    style: TextStyle(
                      color: AppColors.textGrey(context).withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      _buildShoeRow('cm', 'Centimeters', 'cm', isTop: true),
                      _buildShoeRow('in', 'Inches', 'in', isBottom: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
