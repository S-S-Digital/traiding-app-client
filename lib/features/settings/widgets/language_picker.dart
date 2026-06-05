import 'dart:ui';

import 'package:aspiro_trade/app/aspiro_trade_app.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows an iOS-style bottom sheet with a CupertinoPicker wheel for language.
Future<void> showLanguagePicker(BuildContext context) {
  final provider = context.locale;
  int selectedIndex = provider.language == AppLanguage.ru ? 1 : 0;

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return _LanguagePickerSheet(
        initialIndex: selectedIndex,
        onSelect: (lang) {
          provider.setLanguage(lang);
        },
      );
    },
  );
}

class _LanguagePickerSheet extends StatefulWidget {
  const _LanguagePickerSheet({
    required this.initialIndex,
    required this.onSelect,
  });

  final int initialIndex;
  final ValueChanged<AppLanguage> onSelect;

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet>
    with SingleTickerProviderStateMixin {
  late final FixedExtentScrollController _scrollController;
  late int _currentIndex;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const _languages = [
    _LangOption(code: 'EN', name: 'English', nameNative: 'English', lang: AppLanguage.en),
    _LangOption(code: 'RU', name: 'Русский', nameNative: 'Russian', lang: AppLanguage.ru),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _scrollController = FixedExtentScrollController(initialItem: _currentIndex);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onChanged(int index) {
    if (index != _currentIndex) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex = index);
      widget.onSelect(_languages[index].lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E).withValues(alpha: 0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Handle ──
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Title row ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.language,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Picker wheel ──
                  SizedBox(
                    height: 180,
                    child: CupertinoPicker(
                      scrollController: _scrollController,
                      magnification: 1.15,
                      useMagnifier: true,
                      squeeze: 1.0,
                      itemExtent: 52,
                      diameterRatio: 1.3,
                      selectionOverlay: Container(
                        decoration: BoxDecoration(
                          color: AppColors.brand.withValues(alpha: 0.08),
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: AppColors.brand.withValues(alpha: 0.2),
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
                      onSelectedItemChanged: _onChanged,
                      children: List.generate(_languages.length, (i) {
                        final lang = _languages[i];
                        final isActive = i == _currentIndex;
                        return Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: isActive ? 20 : 17,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 34,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.brand.withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isActive
                                          ? AppColors.brand.withValues(alpha: 0.5)
                                          : Colors.white.withValues(alpha: 0.12),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    lang.code,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(lang.name),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Confirm button ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLocalizations.done,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangOption {
  const _LangOption({
    required this.code,
    required this.name,
    required this.nameNative,
    required this.lang,
  });
  final String code; // ISO-like label: EN, RU
  final String name;
  final String nameNative;
  final AppLanguage lang;
}
