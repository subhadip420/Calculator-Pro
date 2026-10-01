import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class ShoeSizeSelectorSheet extends StatelessWidget {
  final String regionName;
  final List<String> sizes;
  final int selectedIndex;
  final bool isHapticsEnabled;

  const ShoeSizeSelectorSheet({
    super.key,
    required this.regionName,
    required this.sizes,
    required this.selectedIndex,
    this.isHapticsEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppColors.bgColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.textColor(context).withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Drag Handle & Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textColor(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select $regionName Size',
                  style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.textColor(context).withOpacity(0.05), height: 1),

          // Size (Values) List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: sizes.length,
              itemBuilder: (context, index) {
                bool isSelected = index == selectedIndex;
                return InkWell(
                  onTap: () {
                    if (isHapticsEnabled) HapticFeedback.selectionClick();
                    Navigator.pop(context, index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: isSelected ? AppColors.cyanColor(context).withOpacity(0.1) : Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sizes[index],
                          style: TextStyle(
                            color: isSelected ? AppColors.cyanColor(context) : AppColors.textColor(context),
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) Icon(Icons.check_circle_rounded, color: AppColors.cyanColor(context), size: 22),
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
  }
}
