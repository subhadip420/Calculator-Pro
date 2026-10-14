import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import 'custom_action_button.dart';
import 'custom_toast.dart';

class CustomTopBar extends StatefulWidget {
  final String toolId;
  final String title;
  final String iconPath;
  final VoidCallback onBack;
  final bool isHapticsEnabled;
  final double topBarPadding;

  const CustomTopBar({
    super.key,
    required this.toolId,
    required this.title,
    required this.iconPath,
    required this.onBack,
    this.isHapticsEnabled = true,
    this.topBarPadding = 8.0,
  });

  @override
  State<CustomTopBar> createState() => _CustomTopBarState();
}

class _CustomTopBarState extends State<CustomTopBar> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favList = prefs.getStringList('favorite_tools') ?? [];

    setState(() {
      _isFavorite = favList.any((item) => jsonDecode(item)['id'] == widget.toolId);
    });
  }

  Future<void> _toggleFavorite() async {
    if (widget.isHapticsEnabled) HapticFeedback.selectionClick();

    final prefs = await SharedPreferences.getInstance();
    List<String> favList = prefs.getStringList('favorite_tools') ?? [];

    bool currentlyFav = favList.any((item) => jsonDecode(item)['id'] == widget.toolId);

    if (currentlyFav) {
      favList.removeWhere((item) => jsonDecode(item)['id'] == widget.toolId);
      showCustomToast(context, 'Removed from Favorites');
    } else {
      final newItem = jsonEncode({'id': widget.toolId, 'title': widget.title, 'img': widget.iconPath});
      favList.add(newItem);
      showCustomToast(context, 'Added to Favorites');
    }

    await prefs.setStringList('favorite_tools', favList);

    setState(() {
      _isFavorite = !currentlyFav;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- NAYA FIX: DYNAMIC THEME COLORS ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    //
    // final Color surfaceColor = isDark ? const Color(0xFF1E2638) : const Color(0xFFFFFFFF);
    // final Color textGrey = isDark ? const Color(0xFFDBC2AD) : const Color(0xFF757575);
    // final Color textColor = isDark ? Colors.white : Colors.black87; // Title ke liye text color
    //
    // final Color containerBgColor = isDark ? AppColors.cyanColor(context).withOpacity(0.1) : Colors.white;

    // return Padding(
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: widget.topBarPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context).withOpacity(0),
        // NAYA: Bottom Left aur Bottom Right mein Radius add kiya
        // borderRadius: const BorderRadius.only(
        //   bottomLeft: Radius.circular(32.0),
        //   bottomRight: Radius.circular(32.0),
        // ),
        // NAYA: Light mode mein shadow taaki radius cut clearly visible ho
        // boxShadow: isDark
        //     ? []
        //     : [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.04),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   )
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- BACK BUTTON ---
          //ActionButton(
          Tooltip(
            message: 'Back',
            child: ActionButton(
              icon: Icons.arrow_back_ios_new_rounded,
              contentColor: AppColors.textGrey(context), // Dynamic icon color
              bgColor: AppColors.surfaceColor(context).withOpacity(isDark ? 0.5 : 1.0), // Light mode me white surface clear dikhega
              onTap: () {
                if (widget.isHapticsEnabled) HapticFeedback.lightImpact();
                widget.onBack();
              },
            ),
          ),

          // --- TITLE ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.title,
                style: TextStyle(color: AppColors.textGrey(context), fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // --- FAVORITE BUTTON ---
          // ActionButton(
          Tooltip(
            message: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
            child: ActionButton(
              icon: _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              contentColor: _isFavorite ? Colors.amberAccent : AppColors.textGrey(context),
              bgColor: AppColors.surfaceColor(context).withOpacity(isDark ? 0.5 : 1.0),
              onTap: _toggleFavorite,
            ),
          ),
        ],
      ),
    );
  }
}
