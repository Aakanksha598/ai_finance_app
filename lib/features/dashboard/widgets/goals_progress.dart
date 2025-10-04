import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/app_providers.dart';
import '../../goals/screens/goals_screen.dart';

class GoalsProgress extends StatelessWidget {
  const GoalsProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        final activeGoals = goalProvider.activeGoals;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Savings Goals',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GoalsScreen(),
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
            if (activeGoals.isEmpty)
              _buildEmptyState(context)
            else
              Column(
                children: activeGoals.take(3).map((goal) {
                  return _buildGoalCard(context, goal);
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
            Icons.flag_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No savings goals',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up a goal to start saving',
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
                  builder: (context) => const GoalsScreen(),
                ),
              );
            },
            child: const Text('Create Goal'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, goal) {
    final progress = goal.progress / 100;
    final isOnTrack = goal.isOnTrack;
    final daysRemaining = goal.daysRemaining;

    Color progressColor;
    if (progress >= 100) {
      progressColor = Colors.green;
    } else if (isOnTrack) {
      progressColor = Theme.of(context).colorScheme.primary;
    } else {
      progressColor = Colors.orange;
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
                  goal.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progress >= 100
                      ? Colors.green.withOpacity(0.1)
                      : isOnTrack
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  progress >= 100
                      ? 'Completed'
                      : isOnTrack
                          ? 'On Track'
                          : 'Off Track',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: progress >= 100
                            ? Colors.green
                            : isOnTrack
                                ? Colors.blue
                                : Colors.orange,
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
                '\$${goal.currentAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              Text(
                'of \$${goal.targetAmount.toStringAsFixed(2)}',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.progress.toStringAsFixed(1)}% complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              if (daysRemaining > 0)
                Text(
                  '$daysRemaining days left',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
