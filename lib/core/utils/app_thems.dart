import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Base font family used across the app.
const _fontFamily = 'Almarai';

/// Creates a TextStyle with `inherit: false` (required by CupertinoTextThemeData)
/// so Flutter can interpolate between light/dark theme styles without crashing.
TextStyle _t({
  required Color color,
  double fontSize = 17,
  FontWeight fontWeight = FontWeight.w400,
}) =>
    TextStyle(
      fontFamily: _fontFamily,
      inherit: false,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: TextDecoration.none,
      textBaseline: TextBaseline.alphabetic,
    );

class AppThems {
  static CupertinoThemeData lightTheme() {
    return CupertinoThemeData(
      textTheme: CupertinoTextThemeData(
        textStyle: _t(color: Colors.black),
        dateTimePickerTextStyle: _t(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        pickerTextStyle: _t(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
        navTitleTextStyle: _t(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        navActionTextStyle: _t(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        actionTextStyle: _t(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: Colors.white,
      brightness: Brightness.light,
      applyThemeToAll: true,
    );
  }

  static CupertinoThemeData darkTheme() {
    return CupertinoThemeData(
      textTheme: CupertinoTextThemeData(
        textStyle: _t(color: Colors.white),
        dateTimePickerTextStyle: _t(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        pickerTextStyle: _t(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
        navTitleTextStyle: _t(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        navActionTextStyle: _t(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        actionTextStyle: _t(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      brightness: Brightness.dark,
      applyThemeToAll: true,
    );
  }
}
