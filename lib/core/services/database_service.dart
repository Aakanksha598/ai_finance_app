import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';

class DatabaseService {
  static const String transactionsBox = 'transactions';
  static const String budgetsBox = 'budgets';
  static const String goalsBox = 'goals';
  static const String settingsBox = 'settings';

  static Future<void> initialize() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // Register adapters
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(BudgetPeriodAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(GoalTypeAdapter());
    Hive.registerAdapter(MicroActionAdapter());
    Hive.registerAdapter(GoalAdapter());

    // Open boxes
    await Hive.openBox<Transaction>(transactionsBox);
    await Hive.openBox<Budget>(budgetsBox);
    await Hive.openBox<Goal>(goalsBox);
    await Hive.openBox(settingsBox);
  }

  // Transaction operations
  static Future<void> addTransaction(Transaction transaction) async {
    final box = Hive.box<Transaction>(transactionsBox);
    await box.put(transaction.id, transaction);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    final box = Hive.box<Transaction>(transactionsBox);
    await box.put(transaction.id, transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    final box = Hive.box<Transaction>(transactionsBox);
    await box.delete(id);
  }

  static List<Transaction> getAllTransactions() {
    final box = Hive.box<Transaction>(transactionsBox);
    return box.values.toList();
  }

  static Transaction? getTransaction(String id) {
    final box = Hive.box<Transaction>(transactionsBox);
    return box.get(id);
  }

  // Budget operations
  static Future<void> addBudget(Budget budget) async {
    final box = Hive.box<Budget>(budgetsBox);
    await box.put(budget.id, budget);
  }

  static Future<void> updateBudget(Budget budget) async {
    final box = Hive.box<Budget>(budgetsBox);
    await box.put(budget.id, budget);
  }

  static Future<void> deleteBudget(String id) async {
    final box = Hive.box<Budget>(budgetsBox);
    await box.delete(id);
  }

  static List<Budget> getAllBudgets() {
    final box = Hive.box<Budget>(budgetsBox);
    return box.values.toList();
  }

  static Budget? getBudget(String id) {
    final box = Hive.box<Budget>(budgetsBox);
    return box.get(id);
  }

  // Goal operations
  static Future<void> addGoal(Goal goal) async {
    final box = Hive.box<Goal>(goalsBox);
    await box.put(goal.id, goal);
  }

  static Future<void> updateGoal(Goal goal) async {
    final box = Hive.box<Goal>(goalsBox);
    await box.put(goal.id, goal);
  }

  static Future<void> deleteGoal(String id) async {
    final box = Hive.box<Goal>(goalsBox);
    await box.delete(id);
  }

  static List<Goal> getAllGoals() {
    final box = Hive.box<Goal>(goalsBox);
    return box.values.toList();
  }

  static Goal? getGoal(String id) {
    final box = Hive.box<Goal>(goalsBox);
    return box.get(id);
  }

  // Settings operations
  static Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(settingsBox);
    await box.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    final box = Hive.box(settingsBox);
    return box.get(key, defaultValue: defaultValue);
  }

  // Analytics
  static double getTotalIncome() {
    final transactions = getAllTransactions();
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double getTotalExpenses() {
    final transactions = getAllTransactions();
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static Map<String, double> getCategoryExpenses() {
    final transactions = getAllTransactions()
        .where((t) => t.type == TransactionType.expense);
    
    final Map<String, double> categoryExpenses = {};
    for (final transaction in transactions) {
      categoryExpenses[transaction.category] = 
          (categoryExpenses[transaction.category] ?? 0.0) + transaction.amount;
    }
    return categoryExpenses;
  }

  static double getEmotionalSpending() {
    final transactions = getAllTransactions()
        .where((t) => t.type == TransactionType.expense && t.emotionalScore > 7);
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }
}