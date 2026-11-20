import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_decorations.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onPrimary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'PlusJakartaSans',
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headlineLg,
        headlineSmall: AppTextStyles.headlineLgMobile,
        titleLarge: AppTextStyles.headlineMd,
        titleMedium: AppTextStyles.titleMd,
        titleSmall: AppTextStyles.titleSm,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        labelLarge: AppTextStyles.labelLg,
        labelMedium: AppTextStyles.labelMd,
        labelSmall: AppTextStyles.labelSm,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineMd.copyWith(
          color: AppColors.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: AppColors.primaryContainer, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: AppColors.primaryContainer, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: AppColors.secondaryContainer, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.titleSm,
        ),
      ),
    );
  }
}