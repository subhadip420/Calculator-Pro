import 'dart:convert'; // NAYA: Map ko String me convert karne ke liye
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_action_button.dart';
import 'custom_toast.dart'; // Apna custom button import karein

class CustomTopBar extends StatefulWidget {
  final String toolId;      // Tool ka unique ID (e.g., 'length')
  final String title;       // Tool ka Title (e.g., 'Length Conversion')
  final String iconPath;    // Tool ka image path (e.g., 'assets/images/length.png')
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
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color textGrey = const Color(0xFFDBC2AD);
  final Color cyanColor = const Color(0xFF4CD7F6);

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Check karna ki ye tool pehle se favourite hai ya nahi
  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favList = prefs.getStringList('favorite_tools') ?? [];

    setState(() {
      // Decode karke check karo ki list me hamara toolId hai ya nahi
      _isFavorite = favList.any((item) => jsonDecode(item)['id'] == widget.toolId);
    });
  }

  // Favourite Toggle Logic
  Future<void> _toggleFavorite() async {
    if (widget.isHapticsEnabled) HapticFeedback.selectionClick();

    final prefs = await SharedPreferences.getInstance();
    List<String> favList = prefs.getStringList('favorite_tools') ?? [];

    bool currentlyFav = favList.any((item) => jsonDecode(item)['id'] == widget.toolId);

    if (currentlyFav) {
      // 1. Agar pehle se hai, toh REMOVE karo
      favList.removeWhere((item) => jsonDecode(item)['id'] == widget.toolId);
      //_showToast("Removed from Favorites");
      showCustomToast(context, 'Removed from Favorites');
    } else {
      // 2. Agar nahi hai, toh JSON banakar ADD karo
      final newItem = jsonEncode({
        'id': widget.toolId,
        'title': widget.title,
        'img': widget.iconPath,
      });
      favList.add(newItem);
      //_showToast("Added to Favorites");
      showCustomToast(context, 'Added to Favorites');
    }

    // SharedPreferences me nayi list save kardo
    await prefs.setStringList('favorite_tools', favList);

    // Star UI update karne ke liye state badlo
    setState(() {
      _isFavorite = !currentlyFav;
    });
  }

  // Premium Floating Toast (SnackBar)
  // void _showToast(String message) {
  //   ScaffoldMessenger.of(context).clearSnackBars(); // Purana toast hatao
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         message,
  //         textAlign: TextAlign.center,
  //         style: TextStyle(color: cyanColor, fontSize: 14),
  //       ),
  //       backgroundColor: surfaceColor.withOpacity(0.9), // Premium look ke liye transparent cyan
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         side: BorderSide(color: surfaceColor.withOpacity(0.5), width: 1),
  //       ),
  //       margin: const EdgeInsets.only(bottom: 100, left: 60, right: 60), // Center me chota box
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: widget.topBarPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- BACK BUTTON ---
          ActionButton(
            icon: Icons.arrow_back_ios_new_rounded,
            contentColor: textGrey,
            bgColor: surfaceColor.withOpacity(0.5),
            onTap: () {
              if (widget.isHapticsEnabled) HapticFeedback.lightImpact();
              widget.onBack();
            },
          ),

          // --- TITLE ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // --- FAVORITE BUTTON ---
          ActionButton(
            // NAYA: Condition ke hisaab se Filled ya Border icon
            icon: _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            contentColor: _isFavorite ? Colors.amberAccent : textGrey, // Favourite hone par golden color
            bgColor: surfaceColor.withOpacity(0.5),
            onTap: _toggleFavorite, // Direct naya logic attach kiya
          ),
        ],
      ),
    );
  }
}