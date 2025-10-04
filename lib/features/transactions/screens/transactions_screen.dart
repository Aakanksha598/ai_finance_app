import 'package:ai_finance_app/core/models/transaction.dart';
import 'package:ai_finance_app/core/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/transaction_list_item.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? _selectedType = TransactionType.expense;
  String? _selectedCategory;
  String _searchQuery = '';

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Health',
    'Utilities',
    'Income',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Optionally show a search bar or dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Search Transactions'),
                  content: TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search by description, category, or merchant',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('Clear'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Transaction type filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'All',
                        null,
                        _selectedType == null,
                        () => setState(() => _selectedType = null),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Income',
                        TransactionType.income,
                        _selectedType == TransactionType.income,
                        () => setState(
                            () => _selectedType = TransactionType.income),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Expense',
                        TransactionType.expense,
                        _selectedType == TransactionType.expense,
                        () => setState(
                            () => _selectedType = TransactionType.expense),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Transfer',
                        TransactionType.transfer,
                        _selectedType == TransactionType.transfer,
                        () => setState(
                            () => _selectedType = TransactionType.transfer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Category filter
                if (_selectedCategory != null)
                  Row(
                    children: [
                      Text(
                        'Category: ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCategory!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = null),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Transactions list
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                List<Transaction> filteredTransactions =
                    transactionProvider.transactions;

                // Filter by type
                if (_selectedType != null) {
                  filteredTransactions = filteredTransactions
                      .where((t) => t.type == _selectedType)
                      .toList();
                }

                // Filter by category
                if (_selectedCategory != null) {
                  filteredTransactions = filteredTransactions
                      .where((t) => t.category == _selectedCategory)
                      .toList();
                }

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  filteredTransactions = filteredTransactions
                      .where((t) =>
                          t.description
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          t.category
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          (t.merchant
                                  ?.toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ??
                              false))
                      .toList();
                }

                if (filteredTransactions.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return TransactionListItem(
                      transaction: transaction,
                      onTap: () {
                        _showTransactionDetails(transaction);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    TransactionType? type,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add a new transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              );
            },
            child: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Category:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction Details',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Amount
                    Text(
                      '\$${transaction.amount.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: transaction.type == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                          ),
                    ),
                    const SizedBox(height: 20),
                    // Details
                    _buildDetailRow('Description', transaction.description),
                    _buildDetailRow('Category', transaction.category),
                    _buildDetailRow(
                        'Type', transaction.type.toString().split('.').last),
                    _buildDetailRow('Date', _formatDate(transaction.date)),
                    if (transaction.merchant != null)
                      _buildDetailRow('Merchant', transaction.merchant!),
                    if (transaction.paymentMethod != null)
                      _buildDetailRow(
                          'Payment Method', transaction.paymentMethod!),
                    if (transaction.location != null)
                      _buildDetailRow('Location', transaction.location!),
                    if (transaction.emotionalNote != null)
                      _buildDetailRow(
                          'Emotional Note', transaction.emotionalNote!),
                    const Spacer(),
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Implement edit functionality
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Edit functionality coming soon!'),
                                ),
                              );
                            },
                            child: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Implement delete functionality
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Delete functionality coming soon!'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
