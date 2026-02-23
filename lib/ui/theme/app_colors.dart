import 'package:flutter/material.dart';

/// Aspiro Trade — Bybit-inspired dark theme tokens
class AppColors {
  AppColors._();

  // ── Background ──
  static const Color background = Color(0xFF0B0E11);
  static const Color card = Color(0xFF181A20);
  static const Color elevated = Color(0xFF1E2329);
  static const Color overlay = Color(0x99000000); // rgba(0,0,0,0.6)

  // ── Brand ──
  static const Color brand = Color(0xFF20B26C);
  static const Color brandLight = Color(0xFF2DC77A);
  static const Color brandDim = Color(0x1F20B26C); // rgba(32,178,108,0.12)
  static const Color brandSubtle = Color(0x0F20B26C); // rgba(32,178,108,0.06)

  // ── Semantic ──
  static const Color up = Color(0xFF20B26C);
  static const Color down = Color(0xFFEF454A);
  static const Color warning = Color(0xFFF0B90B);
  static const Color info = Color(0xFF3375E9);
  static const Color purple = Color(0xFF9945FF);

  // ── Text ──
  static const Color textPrimary = Color(0xFFEAECEF);
  static const Color textSecondary = Color(0xFF848E9C);
  static const Color textTertiary = Color(0xFF5E6673);
  static const Color textQuaternary = Color(0xFF474D57);

  // ── Border ──
  static const Color border = Color(0xFF2B3139);
  static const Color borderSubtle = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)

  // ── Crypto colors ──
  static const Color btc = Color(0xFFF7931A);
  static const Color eth = Color(0xFF627EEA);
  static const Color sol = Color(0xFF9945FF);
  static const Color bnb = Color(0xFFF3BA2F);
  static const Color xrp = Color(0xFFFFFFFF);
  static const Color ada = Color(0xFF3375E9);
  static const Color doge = Color(0xFFC2A633);
  static const Color avax = Color(0xFFE84142);
  static const Color dot = Color(0xFFE6007A);
  static const Color matic = Color(0xFF8247E5);
  static const Color link = Color(0xFF2B57D5);
  static const Color atom = Color(0xFF6C6CB4);

  // ── Legacy aliases (so old code doesn't break) ──
  static const Color darkBackgroundColor = background;
  static const Color darkSecondaryBackground = card;
  static const Color darkCardColor = elevated;
  static const Color darkTextPrimary = textPrimary;
  static const Color darkTextSecondary = textSecondary;
  static const Color darkAccentGreen = brand;
  static const Color darkAccentRed = down;
  static const Color darkAccentBlue = info;
  static const Color darkBorderColor = border;
  static const Color darkShadow = Color(0x4D000000);
  static const Color darkAccentGold = warning;
}
