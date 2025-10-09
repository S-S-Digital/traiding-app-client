import 'package:flutter/material.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBackgroundColor,
  // primaryColor: AppColors.primaryColor,
  cardColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.darkAccentBlue,
    unselectedItemColor: AppColors.darkTextPrimary,
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackgroundColor,
  primaryColor: AppColors.darkAccentBlue,
  cardColor: AppColors.darkCardColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSecondaryBackground,
    foregroundColor: AppColors.darkTextPrimary,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
    bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSecondaryBackground,
    selectedItemColor: AppColors.darkAccentBlue,
    unselectedItemColor: AppColors.darkTextSecondary,
  ),
  dividerColor: AppColors.darkBorderColor,
  shadowColor: AppColors.darkShadow,
);
