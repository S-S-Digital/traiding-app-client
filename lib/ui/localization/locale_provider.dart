import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the app locale and persists the choice.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider({required AppLanguage initial}) : _language = initial;

  static const _key = 'app_language';
  final _storage = const FlutterSecureStorage();

  AppLanguage _language;
  AppLanguage get language => _language;

  bool get isRu => _language == AppLanguage.ru;

  Future<void> toggleLanguage() async {
    _language = _language == AppLanguage.en ? AppLanguage.ru : AppLanguage.en;
    AppLocalizations.setLanguage(_language);
    await _storage.write(key: _key, value: _language == AppLanguage.ru ? 'ru' : 'en');
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    if (lang == _language) return;
    _language = lang;
    AppLocalizations.setLanguage(lang);
    await _storage.write(key: _key, value: lang == AppLanguage.ru ? 'ru' : 'en');
    notifyListeners();
  }
}
