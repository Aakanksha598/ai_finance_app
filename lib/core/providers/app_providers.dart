import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../models/budget.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

// Transaction Provider
class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = DatabaseService.getAllTransactions();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Error loading transactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await DatabaseService.addTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await DatabaseService.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      print('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await DatabaseService.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  List<Transaction> getRecentTransactions(int count) {
    return _transactions.take(count).toList();
  }

  double getTotalIncome() {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpenses() {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getBalance() {
    return getTotalIncome() - getTotalExpenses();
  }
}

// Budget Provider
class BudgetProvider extends ChangeNotifier {
  List<Budget> _budgets = [];
  bool _isLoading = false;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  List<Budget> get activeBudgets => _budgets.where((b) => b.isActive).toList();

  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _budgets = DatabaseService.getAllBudgets();
    } catch (e) {
      print('Error loading budgets: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await DatabaseService.addBudget(budget);
      await loadBudgets();
    } catch (e) {
      print('Error adding budget: $e');
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await DatabaseService.updateBudget(budget);
      await loadBudgets();
    } catch (e) {
      print('Error updating budget: $e');
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await DatabaseService.deleteBudget(id);
      await loadBudgets();
    } catch (e) {
      print('Error deleting budget: $e');
    }
  }

  Budget? getBudgetById(String id) {
    try {
      return _budgets.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Budget> getBudgetsByCategory(String category) {
    return _budgets.where((b) => b.category == category).toList();
  }

  List<Budget> getOverBudgetBudgets() {
    return _budgets.where((b) => b.isOverBudget).toList();
  }

  List<Budget> getNearLimitBudgets() {
    return _budgets.where((b) => b.isNearLimit).toList();
  }
}

// Goal Provider
class GoalProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = DatabaseService.getAllGoals();
    } catch (e) {
      print('Error loading goals: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    try {
      await DatabaseService.addGoal(goal);
      await loadGoals();
    } catch (e) {
      print('Error adding goal: $e');
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      await DatabaseService.updateGoal(goal);
      await loadGoals();
    } catch (e) {
      print('Error updating goal: $e');
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await DatabaseService.deleteGoal(id);
      await loadGoals();
    } catch (e) {
      print('Error deleting goal: $e');
    }
  }

  Goal? getGoalById(String id) {
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Goal> getGoalsByType(GoalType type) {
    return _goals.where((g) => g.type == type).toList();
  }

  List<Goal> getGoalsByCategory(String category) {
    return _goals.where((g) => g.category == category).toList();
  }

  List<Goal> getOnTrackGoals() {
    return _goals.where((g) => g.isOnTrack).toList();
  }

  List<Goal> getOffTrackGoals() {
    return _goals.where((g) => !g.isOnTrack).toList();
  }
}

// App State Provider
class AppStateProvider extends ChangeNotifier {
  bool _isOfflineMode = false;
  bool _isDarkMode = false;
  String _currency = 'USD';
  bool _hasCompletedOnboarding = false;

  bool get isOfflineMode => _isOfflineMode;
  bool get isDarkMode => _isDarkMode;
  String get currency => _currency;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  Future<void> initialize() async {
    _isOfflineMode =
        DatabaseService.getSetting('isOfflineMode', defaultValue: false);
    _isDarkMode = DatabaseService.getSetting('isDarkMode', defaultValue: false);
    _currency = DatabaseService.getSetting('currency', defaultValue: 'USD');
    _hasCompletedOnboarding = DatabaseService.getSetting(
        'hasCompletedOnboarding',
        defaultValue: false);
    notifyListeners();
  }

  Future<void> toggleOfflineMode() async {
    _isOfflineMode = !_isOfflineMode;
    await DatabaseService.saveSetting('isOfflineMode', _isOfflineMode);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await DatabaseService.saveSetting('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    await DatabaseService.saveSetting('currency', _currency);
    notifyListeners();
  }

  Future<void> setOnboardingCompleted() async {
    _hasCompletedOnboarding = true;
    await DatabaseService.saveSetting('hasCompletedOnboarding', true);
    notifyListeners();
  }
}

// ...existing provider classes...

class AppProviders {
  static final List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => TransactionProvider()),
    ChangeNotifierProvider(create: (_) => BudgetProvider()),
    ChangeNotifierProvider(create: (_) => GoalProvider()),
    ChangeNotifierProvider(create: (_) => AppStateProvider()),
    // Add more providers here if needed
  ];
}
