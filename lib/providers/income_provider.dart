import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/income.dart';
import '../models/income_category.dart';
import '../models/project_task.dart';
import '../core/services/database_helper.dart';

class IncomeProvider with ChangeNotifier {
  List<IncomeCategory> _categories = [];
  List<Income> _incomes = [];
  bool _isLoaded = false;

  List<IncomeCategory> get categories => _categories;
  List<Income> get incomes => _incomes;
  bool get isLoaded => _isLoaded;

  double get totalIncomes => _incomes.fold(0.0, (sum, e) => sum + e.amount);

  List<Income> recentIncomes([int count = 5]) => _incomes.take(count).toList();

  IncomeCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  bool hasIncomeForTask(String taskId) =>
      _incomes.any((e) => e.taskId == taskId);

  Future<void> loadData() async {
    try {
      _categories = await DatabaseHelper.instance.getIncomeCategories();
      if (_categories.isEmpty) {
        await _seedDefaultCategories();
        _categories = await DatabaseHelper.instance.getIncomeCategories();
      }
      _incomes = await DatabaseHelper.instance.getIncomes();
      _isLoaded = true;
    } catch (e) {
      log('IncomeProvider loadData error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> _seedDefaultCategories() async {
    final defaults = [
      IncomeCategory(
        id: 'inc_projects',
        name: 'Projects',
        color: 0xFF10B981,
        icon: 0xe0af,
        isDefault: true,
      ),
      IncomeCategory(
        id: 'inc_freelance',
        name: 'Freelance',
        color: 0xFF6366F1,
        icon: 0xe3f7,
        isDefault: true,
      ),
      IncomeCategory(
        id: 'inc_other',
        name: 'Other',
        color: 0xFF64748B,
        icon: 0xe8b8,
        isDefault: true,
      ),
    ];
    for (final cat in defaults) {
      await DatabaseHelper.instance.insertIncomeCategory(cat);
    }
  }

  Future<void> addCategory(IncomeCategory category) async {
    await DatabaseHelper.instance.insertIncomeCategory(category);
    _categories.add(category);
    notifyListeners();
  }

  Future<void> updateCategory(IncomeCategory category) async {
    await DatabaseHelper.instance.updateIncomeCategory(category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(String id) async {
    final used = await DatabaseHelper.instance.countIncomesByCategory(id);
    if (used > 0) return false;
    await DatabaseHelper.instance.deleteIncomeCategory(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
    return true;
  }

  Future<void> addIncome(Income income) async {
    await DatabaseHelper.instance.insertIncome(income);
    _incomes.insert(0, income);
    notifyListeners();
  }

  Future<void> updateIncome(Income income) async {
    await DatabaseHelper.instance.updateIncome(income);
    final index = _incomes.indexWhere((e) => e.id == income.id);
    if (index != -1) {
      _incomes[index] = income;
      notifyListeners();
    }
  }

  Future<void> deleteIncome(String id) async {
    await DatabaseHelper.instance.deleteIncome(id);
    _incomes.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> addIncomeFromTask(ProjectTask task, String currency) async {
    if (hasIncomeForTask(task.id)) return;
    final fallbackCategoryId = _categories.isNotEmpty
        ? (_categories.firstWhere(
            (c) => c.id == 'inc_projects',
            orElse: () => _categories.first,
          )).id
        : 'inc_other';

    final income = Income(
      id: const Uuid().v4(),
      title: task.name,
      amount: task.cost,
      date: DateTime.now(),
      categoryId: fallbackCategoryId,
      paymentMethodId: task.paymentMethodId,
      note: 'autoIncomeFromTask'.tr(),
      taskId: task.id,
      currency: currency,
    );
    await addIncome(income);
  }

  Future<void> removeIncomeForTask(String taskId) async {
    await DatabaseHelper.instance.deleteIncomeByTaskId(taskId);
    _incomes.removeWhere((e) => e.taskId == taskId);
    notifyListeners();
  }
}
