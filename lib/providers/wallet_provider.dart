import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/payment_method.dart';
import '../core/services/database_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class WalletProvider with ChangeNotifier {
  List<PaymentMethod> _paymentMethods = [];

  List<PaymentMethod> get paymentMethods => _paymentMethods;

  Future<void> loadData() async {
    try {
      _paymentMethods = await DatabaseHelper.instance.getPaymentMethods();

      // Translate default payment methods
      _paymentMethods = _paymentMethods.map((method) {
        if (method.id == 'cash') {
          return PaymentMethod(
            id: method.id,
            name: 'cash'.tr(), // Key must match translations
            color: method.color,
            icon: method.icon,
          );
        }
        return method;
      }).toList();

      if (_paymentMethods.isEmpty) {
        // Add default payment methods
        await addPaymentMethod(
          PaymentMethod(
            id: 'cash',
            name: 'cash'.tr(),
            color: 0xFF4CAF50,
            icon: 0xe8cc,
          ),
        ); // payment
      }
    } catch (e) {
      log('WalletProvider loadData error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    await DatabaseHelper.instance.insertPaymentMethod(method);
    _paymentMethods.add(method);
    notifyListeners();
  }

  Future<void> updatePaymentMethod(PaymentMethod method) async {
    await DatabaseHelper.instance.updatePaymentMethod(method);
    final index = _paymentMethods.indexWhere((m) => m.id == method.id);
    if (index != -1) {
      _paymentMethods[index] = method;
      notifyListeners();
    }
  }

  Future<void> deletePaymentMethod(String id) async {
    await DatabaseHelper.instance.deletePaymentMethod(id);
    _paymentMethods.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
