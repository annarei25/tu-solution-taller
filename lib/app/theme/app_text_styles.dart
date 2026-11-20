import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const _familia = 'PlusJakartaSans';

  static const headlineLg = TextStyle(
    fontFamily: _familia,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.56,
    color: AppColors.onSurface,
  );

  static const headlineLgMobile = TextStyle(
    fontFamily: _familia,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.22,
    color: AppColors.onSurface,
  );

  static const headlineMd = TextStyle(
    fontFamily: _familia,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const titleMd = TextStyle(
    fontFamily: _familia,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const titleSm = TextStyle(
    fontFamily: _familia,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const bodyLg = TextStyle(
    fontFamily: _familia,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const bodyMd = TextStyle(
    fontFamily: _familia,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const labelLg = TextStyle(
    fontFamily: _familia,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.48,
    color: AppColors.onSurface,
  );

  static const labelMd = TextStyle(
    fontFamily: _familia,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const labelSm = TextStyle(
    fontFamily: _familia,
    fontSize: 10,
    height: 12 / 10,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );
}