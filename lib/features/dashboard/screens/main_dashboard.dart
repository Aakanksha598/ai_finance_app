import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/app_providers.dart';
import '../../budget/screens/budget_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../../insights/screens/insights_screen.dart';
import '../../transactions/screens/add_transaction_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../widgets/balance_card.dart';
import '../widgets/budget_overview.dart';
import '../widgets/goals_progress.dart';
import '../widgets/insights_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_transactions.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const TransactionsScreen(),
    const BudgetScreen(),
    const GoalsScreen(),
    const InsightsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load data when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<BudgetProvider>().loadBudgets();
      context.read<GoalProvider>().loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
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
            )
          : null,
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<TransactionProvider>().loadTransactions();
            await context.read<BudgetProvider>().loadBudgets();
            await context.read<GoalProvider>().loadGoals();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        Text(
                          'Let\'s manage your finances',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Balance Card
                const BalanceCard(),

                const SizedBox(height: 24),

                // Quick Actions
                const QuickActions(),

                const SizedBox(height: 24),

                // Budget Overview
                const BudgetOverview(),

                const SizedBox(height: 24),

                // Goals Progress
                const GoalsProgress(),

                const SizedBox(height: 24),

                // AI Insights
                const InsightsCard(),

                const SizedBox(height: 24),

                // Recent Transactions
                const RecentTransactions(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
