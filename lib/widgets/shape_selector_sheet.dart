import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';

// TODO: Yahan apni AppColors class aur ShapeItem model ko import karna mat bhulna agar alag file me daal rahe ho!

void showShapeSelectorGrid({
  required BuildContext context,
  required List<dynamic> shapeList, // TODO: 'dynamic' ko apne 'ShapeItem' model name se replace karein
  required int selectedShapeIndex,
  required bool isHapticsEnabled,
  required ValueChanged<int> onShapeSelected,
}) {
  if (isHapticsEnabled) HapticFeedback.lightImpact();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.textGrey(context).withOpacity(0.3))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sheet Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.textGrey(context).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Text(
                'Select Shape',
                style: TextStyle(color: AppColors.textColor(context), fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Divider(color: AppColors.textGrey(context).withOpacity(0.2), height: 1),

              // Grid View
              GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(5),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 1,
                ),
                itemCount: shapeList.length,
                itemBuilder: (context, index) {
                  bool isSelected = index == selectedShapeIndex;
                  var item = shapeList[index];

                  return GestureDetector(
                    onTap: () {
                      if (isHapticsEnabled) HapticFeedback.selectionClick();
                      onShapeSelected(index); // NAYA: ye callback main screen ko update karega
                      Navigator.pop(sheetContext); // Sheet close karega
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.cyanColor(context).withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.cyanColor(context).withOpacity(0.5) : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 45, child: Center(child: item.iconBuilder)),
                          const SizedBox(height: 5),
                          Text(
                            item.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textColor(context),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('Shapes', style: TextStyle(color: AppColors.textGrey(context), fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}