import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _localeKey = 'selected_locale';

  LocaleProvider() {
    _loadLocale();
  }

  Locale? get locale => _locale;

  Future<void> setLocale(BuildContext context, Locale locale) async {
    if (!['en', 'ar'].contains(locale.languageCode)) return;
    _locale = locale;

    // Update easy_localization locale
    await context.setLocale(locale);

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
}
