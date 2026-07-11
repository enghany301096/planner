import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../core/services/currency_service.dart';

class SettingsProvider with ChangeNotifier {
  bool _isBiometricEnabled = false;
  bool _areSettingsLoaded = false;
  bool _isDarkMode = false;
  String _currency = 'L.E';
  String _expensesCurrency = 'USD';
  double _hourCost = 5.0;
  bool _showHourCostInPrint = true;
  bool _showTaskTimeInPrint = true;
  bool _showTaskTypeInPrint = true;
  bool _showSubtasksInPrint = true;
  bool _isExpensesEnabled = true;
  double _usdToEgp = 48.50;
  double _usdToSar = 3.75;
  String _lastRatesUpdate = '';
  bool _isFetchingRates = false;
  List<String> listCurency = ['L.E', 'USD', 'SAR'];

  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get areSettingsLoaded => _areSettingsLoaded;
  bool get isDarkMode => _isDarkMode;

  String get currency => _currency;
  String get expensesCurrency => _expensesCurrency;
  double get hourCost => _hourCost;
  bool get showHourCostInPrint => _showHourCostInPrint;
  bool get showTaskTimeInPrint => _showTaskTimeInPrint;
  bool get showTaskTypeInPrint => _showTaskTypeInPrint;
  bool get showSubtasksInPrint => _showSubtasksInPrint;
  bool get isExpensesEnabled => _isExpensesEnabled;
  double get usdToEgp => _usdToEgp;
  double get usdToSar => _usdToSar;
  String get lastRatesUpdate => _lastRatesUpdate;
  bool get isFetchingRates => _isFetchingRates;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _currency = prefs.getString('currency') ?? 'L.E';
    _expensesCurrency = prefs.getString('expensesCurrency') ?? 'USD';
    _hourCost = prefs.getDouble('hourCost') ?? 5.0;
    _showHourCostInPrint = prefs.getBool('showHourCostInPrint') ?? true;
    _showTaskTimeInPrint = prefs.getBool('showTaskTimeInPrint') ?? true;
    _showTaskTypeInPrint = prefs.getBool('showTaskTypeInPrint') ?? true;
    _showSubtasksInPrint = prefs.getBool('showSubtasksInPrint') ?? true;
    _isExpensesEnabled = prefs.getBool('isExpensesEnabled') ?? true;
    _usdToEgp = prefs.getDouble('usdToEgp') ?? 48.50;
    _usdToSar = prefs.getDouble('usdToSar') ?? 3.75;
    _lastRatesUpdate = prefs.getString('lastRatesUpdate') ?? '';
    _areSettingsLoaded = true;
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _isBiometricEnabled = value;
    await prefs.setBool('isBiometricEnabled', value);
    notifyListeners();
  }

  Future<void> fetchAndSaveRates() async {
    _isFetchingRates = true;
    notifyListeners();

    final rates = await CurrencyService.fetchLatestRates();
    if (rates != null) {
      final prefs = await SharedPreferences.getInstance();
      _usdToEgp = rates['EGP'] ?? _usdToEgp;
      _usdToSar = rates['SAR'] ?? _usdToSar;
      
      final now = DateTime.now();
      final formatter = DateFormat('yyyy-MM-dd HH:mm');
      _lastRatesUpdate = formatter.format(now);

      await prefs.setDouble('usdToEgp', _usdToEgp);
      await prefs.setDouble('usdToSar', _usdToSar);
      await prefs.setString('lastRatesUpdate', _lastRatesUpdate);
    }
    
    _isFetchingRates = false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = value;
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    final prefs = await SharedPreferences.getInstance();
    _currency = value;
    await prefs.setString('currency', value);
    notifyListeners();
  }

  Future<void> setExpensesCurrency(String value) async {
    final prefs = await SharedPreferences.getInstance();
    _expensesCurrency = value;
    await prefs.setString('expensesCurrency', value);
    notifyListeners();
  }

  Future<void> setHourCost(double value) async {
    final prefs = await SharedPreferences.getInstance();
    _hourCost = value;
    await prefs.setDouble('hourCost', value);
    notifyListeners();
  }

  Future<void> setShowHourCostInPrint(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _showHourCostInPrint = value;
    await prefs.setBool('showHourCostInPrint', value);
    notifyListeners();
  }

  Future<void> setShowTaskTimeInPrint(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _showTaskTimeInPrint = value;
    await prefs.setBool('showTaskTimeInPrint', value);
    notifyListeners();
  }

  Future<void> setShowTaskTypeInPrint(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _showTaskTypeInPrint = value;
    await prefs.setBool('showTaskTypeInPrint', value);
    notifyListeners();
  }

  Future<void> setShowSubtasksInPrint(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _showSubtasksInPrint = value;
    await prefs.setBool('showSubtasksInPrint', value);
    notifyListeners();
  }

  Future<void> setExpensesEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _isExpensesEnabled = value;
    await prefs.setBool('isExpensesEnabled', value);
    notifyListeners();
  }
}
