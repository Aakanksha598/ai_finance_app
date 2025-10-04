import 'dart:convert';

import 'package:ai_finance_app/core/models/budget.dart';
import 'package:ai_finance_app/core/models/goal.dart';
import 'package:ai_finance_app/core/models/transaction.dart';
import 'package:http/http.dart' as http;

import 'database_service.dart';

class AIService {
  // TODO: Replace with your actual OpenAI API key
  static const String _openAIKey = 'your-openai-api-key-here';
  static const String _openAIUrl = 'https://api.openai.com/v1/chat/completions';

  // Financial insights
  static Future<Map<String, dynamic>> getFinancialInsights() async {
    final transactions = DatabaseService.getAllTransactions();
    final budgets = DatabaseService.getAllBudgets();
    final goals = DatabaseService.getAllGoals();

    if (transactions.isEmpty) {
      return {
        'message':
            'No transactions found. Start adding transactions to get insights!',
        'recommendations': [
          'Add your first transaction to begin tracking',
          'Set up a budget to control spending',
          'Create a savings goal to build wealth',
        ],
      };
    }

    final totalIncome = DatabaseService.getTotalIncome();
    final totalExpenses = DatabaseService.getTotalExpenses();
    final savingsRate = totalIncome > 0
        ? ((totalIncome - totalExpenses) / totalIncome) * 100
        : 0.0; // Ensure it's a double

    final categoryExpenses = DatabaseService.getCategoryExpenses();
    final emotionalSpending = DatabaseService.getEmotionalSpending();

    // Find top spending category safely
    String topCategory = 'None';
    double topAmount = 0.0;
    if (categoryExpenses.isNotEmpty) {
      categoryExpenses.forEach((category, amount) {
        if (amount > topAmount) {
          topAmount = amount;
          topCategory = category;
        }
      });
    }

    // Analyze trends with correct month arithmetic
    final now = DateTime.now();
    final lastMonthDate = DateTime(now.year, now.month - 1); // Fix for month 1
    final thisMonthExpenses = transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final lastMonthExpenses = transactions
        .where((t) =>
            t.date.year == lastMonthDate.year &&
            t.date.month == lastMonthDate.month)
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenseTrend =
        thisMonthExpenses > lastMonthExpenses ? 'increasing' : 'decreasing';

    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'savingsRate': savingsRate,
      'netSavings': totalIncome - totalExpenses,
      'topSpendingCategory': topCategory,
      'topSpendingAmount': topAmount,
      'emotionalSpending': emotionalSpending,
      'expenseTrend': expenseTrend,
      'recommendations': _generateRecommendations(
        savingsRate: savingsRate,
        emotionalSpending: emotionalSpending,
        topCategory: topCategory,
        expenseTrend: expenseTrend,
        budgets: budgets,
        goals: goals,
      ),
    };
  }

  // Spending forecasting
  static Future<Map<String, dynamic>> forecastSpending({
    required int months,
  }) async {
    final transactions = DatabaseService.getAllTransactions()
        .where((t) => t.type == TransactionType.expense)
        .toList();

    if (transactions.isEmpty) {
      return {
        'forecast': [],
        'message': 'No spending data available for forecasting',
      };
    }

    // Simple trend-based forecasting
    final monthlyExpenses = <double>[];
    final now = DateTime.now();

    for (int i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month - i);
      final monthTransactions = transactions
          .where(
              (t) => t.date.year == month.year && t.date.month == month.month)
          .toList();

      final monthTotal =
          monthTransactions.fold(0.0, (sum, t) => sum + t.amount);
      monthlyExpenses.add(monthTotal);
    }

    // Reverse to chronological order
    final expensesChronological = monthlyExpenses.reversed.toList();

    // Calculate average and trend
    final average = expensesChronological.reduce((a, b) => a + b) /
        expensesChronological.length;
    final trend = expensesChronological.length > 1
        ? (expensesChronological.last - expensesChronological.first) /
            (expensesChronological.length - 1)
        : 0.0;

    // Generate forecast
    final forecast = <Map<String, dynamic>>[];
    for (int i = 1; i <= months; i++) {
      final forecastAmount = average + (trend * i);
      final forecastDate = DateTime(now.year, now.month + i);

      forecast.add({
        'month': '${forecastDate.month}/${forecastDate.year}',
        'amount': forecastAmount,
        'confidence': 0.7, // Simple confidence score
      });
    }

    return {
      'forecast': forecast,
      'averageMonthlySpending': average,
      'trend': trend > 0 ? 'increasing' : 'decreasing',
      'confidence': 'Based on historical data analysis',
    };
  }

  // AI Chat response
  static Future<String> getAIResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_openAIUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful financial advisor assistant. Provide practical, actionable advice for personal finance management, budgeting, saving, and investing. Keep responses concise and friendly.',
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'I apologize, but I\'m having trouble connecting to my AI service right now. Please try again later or contact support if the issue persists.';
      }
    } catch (e) {
      return 'I apologize, but I\'m experiencing technical difficulties. Please try again later.';
    }
  }

  // Analyze emotional spending
  static Map<String, dynamic> analyzeEmotionalSpending(
      List<Transaction> transactions) {
    final emotionalTransactions = transactions
        .where((t) => t.type == TransactionType.expense && t.emotionalScore > 7)
        .toList();

    if (emotionalTransactions.isEmpty) {
      return {
        'total': 0.0,
        'percentage': 0.0,
        'categories': {},
        'recommendations': ['Great job! No emotional spending detected.'],
      };
    }

    final totalEmotionalSpending =
        emotionalTransactions.fold(0.0, (sum, t) => sum + t.amount);

    final totalSpending = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    // This line is robust. It prevents division by zero.
    final percentage = totalSpending > 0
        ? (totalEmotionalSpending / totalSpending) * 100
        : 0.0;

    // Analyze emotional spending by category
    final emotionalCategories = <String, double>{};
    for (final transaction in emotionalTransactions) {
      emotionalCategories[transaction.category] =
          (emotionalCategories[transaction.category] ?? 0.0) +
              transaction.amount;
    }

    return {
      'total': totalEmotionalSpending,
      'percentage': percentage,
      'categories': emotionalCategories,
      'recommendations': _generateEmotionalSpendingRecommendations(percentage),
    };
  }

  // Generate smart recommendations
  static List<String> generateSmartRecommendations() {
    final transactions = DatabaseService.getAllTransactions();
    final budgets = DatabaseService.getAllBudgets();
    final goals = DatabaseService.getAllGoals();

    final recommendations = <String>[];
    // Check for missing budgets
    if (budgets.isEmpty) {
      recommendations.add('Create a budget to better control your spending');
    }

    // Check for missing goals
    if (goals.isEmpty) {
      recommendations
          .add('Set up a savings goal to build your financial future');
    }

    // Check for emotional spending
    final emotionalSpending = DatabaseService.getEmotionalSpending();
    if (emotionalSpending > 0) {
      recommendations.add(
          'Consider tracking your emotional spending to identify triggers');
    }

    // Check for irregular income
    final incomeTransactions =
        transactions.where((t) => t.type == TransactionType.income).toList();
    if (incomeTransactions.length > 1) {
      final amounts = incomeTransactions.map((t) => t.amount).toList();
      final variance = _calculateVariance(amounts);
      if (variance > 1000) {
        // High variance threshold
        recommendations.add(
            'Your income varies significantly. Consider building an emergency fund');
      }
    }

    // Check for high expenses in one category
    final categoryExpenses = DatabaseService.getCategoryExpenses();
    final totalExpenses = DatabaseService.getTotalExpenses();
    categoryExpenses.forEach((category, amount) {
      if (totalExpenses > 0 && (amount / totalExpenses > 0.5)) {
        // More than 50% in one category
        recommendations.add(
            'Consider diversifying your spending. $category takes up ${((amount / totalExpenses) * 100).toStringAsFixed(1)}% of your expenses');
      }
    });

    return recommendations.isEmpty
        ? ['You\'re doing great! Keep up the good financial habits.']
        : recommendations;
  }

  // Helper methods
  static List<String> _generateRecommendations({
    required double savingsRate,
    required double emotionalSpending,
    required String topCategory,
    required String expenseTrend,
    required List<Budget> budgets,
    required List<Goal> goals,
  }) {
    final recommendations = <String>[];

    if (savingsRate < 20) {
      recommendations.add(
          'Try to save at least 20% of your income. Consider reducing expenses in $topCategory');
    }

    if (emotionalSpending > 0) {
      recommendations
          .add('Track your emotional spending to identify spending triggers');
    }

    if (expenseTrend == 'increasing') {
      recommendations.add(
          'Your expenses are trending upward. Review your spending habits');
    }

    if (budgets.isEmpty) {
      recommendations.add('Create a budget to better control your spending');
    }

    if (goals.isEmpty) {
      recommendations
          .add('Set up a savings goal to build your financial future');
    }

    return recommendations.isEmpty
        ? ['You\'re doing great! Keep up the good financial habits.']
        : recommendations;
  }

  static List<String> _generateEmotionalSpendingRecommendations(
      double percentage) {
    if (percentage < 10) {
      return ['Great job! Your emotional spending is well controlled.'];
    } else if (percentage < 25) {
      return [
        'Consider setting a budget for discretionary spending',
        'Try the 24-hour rule: wait 24 hours before making non-essential purchases',
      ];
    } else {
      return [
        'Your emotional spending is high. Consider working with a financial advisor',
        'Try implementing a "cooling-off" period for large purchases',
        'Track your emotions when spending to identify triggers',
      ];
    }
  }

  static double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDifferences =
        values.map((value) => (value - mean) * (value - mean));
    return squaredDifferences.reduce((a, b) => a + b) / values.length;
  }
}
