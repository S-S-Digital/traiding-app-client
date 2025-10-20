import 'package:flutter/material.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';

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

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSecondaryBackground,
    selectedItemColor: AppColors.darkAccentBlue,
    unselectedItemColor: AppColors.darkTextSecondary,
  ),
  dividerColor: AppColors.darkBorderColor,
  shadowColor: AppColors.darkShadow,
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: AppColors.darkTextSecondary),
    fillColor: AppColors.darkSecondaryBackground,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.darkBackgroundColor, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.darkAccentBlue, width: 1.5),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkBackgroundColor.withValues(
        alpha: 0.2,
      ), // фон кнопки
      foregroundColor: Colors.white, // цвет текста и иконок
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppColors.darkBackgroundColor.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      minimumSize: const Size(150, 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkAccentBlue, // основной цвет (кнопки, FAB)
    onPrimary: Colors.white, // текст на primary
    secondary: AppColors.darkAccentGreen, // "купить", акцентные элементы
    onSecondary: AppColors.darkTextSecondary, // текст на secondary
    error: AppColors.darkAccentRed, // "продать"
    onError: Colors.white, // текст на error
    surface: AppColors.darkCardColor, // фон карточек, панели
    onSurface: AppColors.darkTextPrimary, // текст на surface
  ),
);
