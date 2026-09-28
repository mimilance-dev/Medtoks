import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ColorScheme, ThemeData, Typography;

import 'app_tokens.dart';

abstract final class MedtoksColors {
  static const ink = AppColors.lightInk;
  static const teal = AppColors.brand;
  static const coral = AppColors.coral;
  static const canvas = AppColors.lightCanvas;
  static const muted = AppColors.lightMuted;
}

abstract final class MedtoksSpacing {
  static const xs = AppSpacing.xs;
  static const sm = AppSpacing.sm;
  static const md = AppSpacing.lg;
  static const lg = AppSpacing.xxl;
  static const xl = AppSpacing.xxxl;
}

abstract final class AppTheme {
  static const cupertinoLight = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.brand,
    scaffoldBackgroundColor: AppColors.lightCanvas,
    barBackgroundColor: AppColors.lightSurface,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.lightInk,
      textStyle: TextStyle(
        color: AppColors.lightInk,
        fontSize: 16,
        height: 1.45,
      ),
    ),
  );

  static const cupertinoDark = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.brand,
    scaffoldBackgroundColor: AppColors.darkCanvas,
    barBackgroundColor: AppColors.darkSurface,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.darkInk,
      textStyle: TextStyle(
        color: AppColors.darkInk,
        fontSize: 16,
        height: 1.45,
      ),
    ),
  );

  static final cupertinoSystem = CupertinoThemeData(
    primaryColor: CupertinoDynamicColor.withBrightness(
      color: AppColors.brand,
      darkColor: AppColors.brand,
    ),
    scaffoldBackgroundColor: CupertinoDynamicColor.withBrightness(
      color: AppColors.lightCanvas,
      darkColor: AppColors.darkCanvas,
    ),
    barBackgroundColor: CupertinoDynamicColor.withBrightness(
      color: AppColors.lightSurface,
      darkColor: AppColors.darkSurface,
    ),
    textTheme: CupertinoTextThemeData(
      primaryColor: CupertinoDynamicColor.withBrightness(
        color: AppColors.lightInk,
        darkColor: AppColors.darkInk,
      ),
      textStyle: TextStyle(
        color: CupertinoDynamicColor.withBrightness(
          color: AppColors.lightInk,
          darkColor: AppColors.darkInk,
        ),
        fontSize: 16,
        height: 1.45,
      ),
    ),
  );

  static final materialLight = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
      surface: AppColors.lightSurface,
    ),
    scaffoldBackgroundColor: AppColors.lightCanvas,
    dividerColor: AppColors.lightBorder,
    typography: Typography.material2021(),
  );

  static final materialDark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
    ),
    scaffoldBackgroundColor: AppColors.darkCanvas,
    dividerColor: AppColors.darkBorder,
    typography: Typography.material2021(),
  );
}

abstract final class MedtoksTheme {
  static const cupertino = AppTheme.cupertinoLight;
  static const cupertinoDark = AppTheme.cupertinoDark;
  static final material = AppTheme.materialLight;
  static final materialDark = AppTheme.materialDark;
}
