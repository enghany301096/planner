# Easy Localization Setup - Complete Guide

## ✅ What Was Done

### 1. Translation Files Created
- **English**: `/assets/translations/en.json`
- **Arabic**: `/assets/translations/ar.json`

Both files contain translations for:
- Settings screen
- Payment methods screen
- Common UI elements (buttons, labels, etc.)

### 2. Configuration Changes

#### pubspec.yaml
- Added `assets/translations/` to assets section
- Package `easy_localization: ^3.0.8` already installed

#### main.dart
- Initialized `EasyLocalization` in `main()` function
- Wrapped app with `EasyLocalization` widget
- Configured supported locales: English (en) and Arabic (ar)
- Set fallback locale to English
- Added localization delegates to `CupertinoApp`

#### LocaleProvider
- Updated `setLocale()` method to accept `BuildContext`
- Integrated with `easy_localization` using `context.setLocale()`
- Maintains backward compatibility with `shared_preferences` for persistence

### 3. Screens Updated

#### SettingsScreen
- All hardcoded strings replaced with `.tr()` calls
- Language switcher now uses translated labels
- Settings options now display in selected language

#### PaymentMethodsScreen
- Navigation bar title translated
- All dialog messages translated
- Form labels and placeholders translated
- Error messages translated
- Support for named parameters in translations (e.g., delete confirmation with method name)

### 4. Type-Safe Keys (Optional)
Created `/lib/core/locale_keys.g.dart` with `LocaleKeys` class for type-safe translation key access.

## 🎯 How to Use

### Basic Translation
```dart
Text('settings'.tr())
```

### Translation with Parameters
```dart
Text('delete_payment_method_confirm'.tr(namedArgs: {'name': methodName}))
```

### Using Type-Safe Keys (Recommended)
```dart
import 'package:masrofy/core/locale_keys.g.dart';

Text(LocaleKeys.settings.tr())
```

### Changing Language
```dart
// In your code (already implemented in SettingsScreen)
localeProvider.setLocale(context, Locale('ar')); // Switch to Arabic
localeProvider.setLocale(context, Locale('en')); // Switch to English
```

## 📝 Adding New Translations

1. Add the key-value pair to both `en.json` and `ar.json`:
   ```json
   {
     "new_key": "English Text"
   }
   ```
   
2. Update `locale_keys.g.dart` (optional):
   ```dart
   static const new_key = 'new_key';
   ```

3. Use in your code:
   ```dart
   Text('new_key'.tr())
   ```

## 🌍 Supported Languages
- **English** (en) - Default/Fallback
- **Arabic** (ar) - RTL support included

## ✨ Features
- ✅ Automatic language persistence
- ✅ Hot reload support
- ✅ RTL support for Arabic
- ✅ Named parameters in translations
- ✅ Fallback to English if translation missing
- ✅ Type-safe translation keys

## 🔧 Testing
The app is currently running and localization is working correctly:
- Locale switching works
- Translations load properly
- Preferences are saved
- All screens display translated content

## 📚 Next Steps
To add more screens with localization:
1. Add translation keys to both JSON files
2. Import `easy_localization` in your screen
3. Replace hardcoded strings with `.tr()` calls
4. Update `locale_keys.g.dart` if using type-safe keys

Example:
```dart
import 'package:easy_localization/easy_localization.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('my_screen_title'.tr())),
      body: Text('my_screen_content'.tr()),
    );
  }
}
```
