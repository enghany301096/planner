import 'package:flutter/material.dart';

enum Language { ar, en }

enum TaskType { newFeature, bug, enhancement }

extension LanguageExtension on BuildContext {
  Language get lang {
    switch (Localizations.localeOf(this).languageCode) {
      case 'ar':
        return Language.ar;
      case 'en':
      default:
        return Language.en;
    }
  }
}
