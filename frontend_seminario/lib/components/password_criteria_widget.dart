import 'package:flutter/material.dart';
import 'package:frontend_seminario/theme/theme.dart';

Widget buildPasswordCriteria(String text, bool met) {
  return LayoutBuilder(
    builder: (context, constraints) {
      bool isSmallScreen = constraints.maxWidth < 600;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            met ? Icons.check_circle_outline : Icons.highlight_off,
            color: met ? AppTheme.successColor : AppTheme.dangerColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: AppTheme.textSmall.copyWith(
                          color: met
                              ? AppTheme.successColor
                              : AppTheme.dangerColor,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: AppTheme.textSmall.copyWith(
                      color: met ? AppTheme.successColor : AppTheme.dangerColor,
                    ),
                  ),
          ),
        ],
      );
    },
  );
}
