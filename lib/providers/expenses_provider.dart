import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/project_task.dart';
import '../core/services/database_helper.dart';

class ExpensesProvider with ChangeNotifier {
  List<ExpenseCategory> _categories = [];
  List<Expense> _expenses = [];
  bool _isLoaded = false;

  List<ExpenseCategory> get categories => _categories;
  List<Expense> get expenses => _expenses;
  bool get isLoaded => _isLoaded;

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  List<Expense> recentExpenses([int count = 5]) =>
      _expenses.take(count).toList();

  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (final expense in _expenses) {
      map[expense.categoryId] =
          (map[expense.categoryId] ?? 0.0) + expense.amount;
    }
    return map;
  }

  ExpenseCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  bool hasExpenseForTask(String taskId) =>
      _expenses.any((e) => e.taskId == taskId);

  Future<void> loadData() async {
    try {
      _categories = await DatabaseHelper.instance.getExpenseCategories();
      if (_categories.isEmpty) {
        await _seedDefaultCategories();
        _categories = await DatabaseHelper.instance.getExpenseCategories();
      }
      _expenses = await DatabaseHelper.instance.getExpenses();
      _isLoaded = true;
    } catch (e) {
      log('ExpensesProvider loadData error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> _seedDefaultCategories() async {
    final defaults = [
      ExpenseCategory(
        id: 'cat_tools',
        name: 'Tools & Software',
        color: 0xFF6366F1,
        icon: 0xe3b7, // build icon
        isDefault: true,
      ),
      ExpenseCategory(
        id: 'cat_subscriptions',
        name: 'Subscriptions',
        color: 0xFF8B5CF6,
        icon: 0xe8f0, // subscriptions
        isDefault: true,
      ),
      ExpenseCategory(
        id: 'cat_office',
        name: 'Office',
        color: 0xFF10B981,
        icon: 0xe0af, // business_center
        isDefault: true,
      ),
      ExpenseCategory(
        id: 'cat_travel',
        name: 'Travel',
        color: 0xFFF59E0B,
        icon: 0xe1d5, // flight
        isDefault: true,
      ),
      ExpenseCategory(
        id: 'cat_other',
        name: 'Other',
        color: 0xFF64748B,
        icon: 0xe8b8, // category
        isDefault: true,
      ),
    ];
    for (final cat in defaults) {
      await DatabaseHelper.instance.insertExpenseCategory(cat);
    }
  }

  // ── Categories ──────────────────────────────────────────────────────────────

  Future<void> addCategory(ExpenseCategory category) async {
    try {
      await DatabaseHelper.instance.insertExpenseCategory(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      log('ExpensesProvider addCategory error: $e');
    }
  }

  Future<void> updateCategory(ExpenseCategory category) async {
    try {
      await DatabaseHelper.instance.updateExpenseCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      log('ExpensesProvider updateCategory error: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await DatabaseHelper.instance.deleteExpenseCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      log('ExpensesProvider deleteCategory error: $e');
    }
  }

  // ── Expenses ─────────────────────────────────────────────────────────────────

  Future<void> addExpense(Expense expense) async {
    try {
      await DatabaseHelper.instance.insertExpense(expense);
      _expenses.insert(0, expense);
      notifyListeners();
    } catch (e) {
      log('ExpensesProvider addExpense error: $e');
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await DatabaseHelper.instance.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }
    } catch (e) {
      log('ExpensesProvider updateExpense error: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await DatabaseHelper.instance.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      log('ExpensesProvider deleteExpense error: $e');
    }
  }

  /// Auto-create an expense record when a task is marked as paid.
  /// Silently skips if an expense for this task already exists.
  Future<void> addExpenseFromTask(ProjectTask task, String currency) async {
    if (hasExpenseForTask(task.id)) return;
    // Find a default fallback category (tools or other)
    final fallbackCategoryId = _categories.isNotEmpty
        ? (_categories.firstWhere(
            (c) => c.id == 'cat_tools',
            orElse: () => _categories.first,
          )).id
        : 'cat_other';

    final expense = Expense(
      id: const Uuid().v4(),
      title: task.name,
      amount: task.cost,
      date: DateTime.now(),
      categoryId: fallbackCategoryId,
      paymentMethodId: task.paymentMethodId,
      note: 'autoExpenseFromTask'.tr(),
      taskId: task.id,
      currency: currency,
    );
    await addExpense(expense);
  }

  /// Remove expense linked to a task (e.g. when task is unmarked as paid).
  Future<void> removeExpenseForTask(String taskId) async {
    try {
      await DatabaseHelper.instance.deleteExpenseByTaskId(taskId);
      _expenses.removeWhere((e) => e.taskId == taskId);
      notifyListeners();
    } catch (e) {
      log('ExpensesProvider removeExpenseForTask error: $e');
    }
  }
}
