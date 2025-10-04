import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/app_providers.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../../transactions/widgets/transaction_list_item.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final recentTransactions = transactionProvider.getRecentTransactions(5);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TransactionsScreen(),
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
            if (recentTransactions.isEmpty)
              _buildEmptyState(context)
            else
              Column(
                children: recentTransactions.map((transaction) {
                  return TransactionListItem(
                    transaction: transaction,
                    onTap: () {
                      // TODO: Show transaction details
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction details coming soon!'),
                        ),
                      );
                    },
                  );
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
            Icons.receipt_long_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to add transaction screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add transaction feature coming soon!'),
                ),
              );
            },
            child: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }
}
