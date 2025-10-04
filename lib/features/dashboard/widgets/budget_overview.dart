import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/app_providers.dart';
import '../../budget/screens/budget_screen.dart';

class BudgetOverview extends StatelessWidget {
  const BudgetOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        final activeBudgets = budgetProvider.activeBudgets;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BudgetScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activeBudgets.isEmpty)
              _buildEmptyState(context)
            else
              Column(
                children: activeBudgets.take(3).map((budget) {
                  return _buildBudgetCard(context, budget);
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets set',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a budget to track your spending',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BudgetScreen(),
                ),
              );
            },
            child: const Text('Create Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, budget) {
    final progress = budget.progress / 100;
    final isOverBudget = budget.isOverBudget;
    final isNearLimit = budget.isNearLimit;

    Color progressColor;
    if (isOverBudget) {
      progressColor = Colors.red;
    } else if (isNearLimit) {
      progressColor = Colors.orange;
    } else {
      progressColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  budget.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? Colors.red.withOpacity(0.1)
                      : isNearLimit
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOverBudget
                      ? 'Over Budget'
                      : isNearLimit
                          ? 'Near Limit'
                          : 'On Track',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isOverBudget
                            ? Colors.red
                            : isNearLimit
                                ? Colors.orange
                                : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${budget.currentAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              Text(
                'of \$${budget.targetAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress > 1.0 ? 1.0 : progress,
            backgroundColor:
                Theme.of(context).colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Text(
            '${budget.progress.toStringAsFixed(1)}% used',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }
}
