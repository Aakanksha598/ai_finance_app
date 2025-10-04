import 'package:flutter/material.dart';

import '../../../core/services/ai_service.dart';

class InsightsCard extends StatefulWidget {
  const InsightsCard({super.key});

  @override
  State<InsightsCard> createState() => _InsightsCardState();
}

class _InsightsCardState extends State<InsightsCard> {
  Map<String, dynamic>? _insights;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    try {
      final insights = await AIService.getFinancialInsights();
      setState(() {
        _insights = insights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_insights == null)
            _buildErrorState()
          else
            _buildInsightsContent(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Unable to load insights',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Try again later',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
        ),
      ],
    );
  }

  Widget _buildInsightsContent() {
    final insights = _insights!;

    if (insights.containsKey('message')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insights['message'],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 16),
          if (insights['recommendations'] != null)
            ...insights['recommendations']
                .map<Widget>((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rec,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
        ],
      );
    }

    return Column(
      children: [
        // Savings Rate
        _buildInsightRow(
          'Savings Rate',
          '${insights['savingsRate']?.toStringAsFixed(1)}%',
          Icons.savings,
          insights['savingsRate'] >= 20 ? Colors.green : Colors.orange,
        ),

        const SizedBox(height: 12),

        // Net Savings
        _buildInsightRow(
          'Net Savings',
          '\$${insights['netSavings']?.toStringAsFixed(2)}',
          Icons.trending_up,
          insights['netSavings'] > 0 ? Colors.green : Colors.red,
        ),

        const SizedBox(height: 12),

        // Top Spending Category
        if (insights['topSpendingCategory'] != null &&
            insights['topSpendingCategory'] != 'None')
          _buildInsightRow(
            'Top Spending',
            insights['topSpendingCategory'],
            Icons.category,
            Colors.blue,
            subtitle: '\$${insights['topSpendingAmount']?.toStringAsFixed(2)}',
          ),

        const SizedBox(height: 12),

        // Emotional Spending Alert
        if (insights['emotionalSpending'] != null &&
            insights['emotionalSpending'] > 0)
          _buildInsightRow(
            'Emotional Spending',
            '\$${insights['emotionalSpending']?.toStringAsFixed(2)}',
            Icons.psychology,
            Colors.orange,
            subtitle: 'Consider tracking triggers',
          ),

        const SizedBox(height: 16),

        // Recommendations
        if (insights['recommendations'] != null &&
            insights['recommendations'].isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              ...insights['recommendations']
                  .take(2)
                  .map<Widget>((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                rec,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
      ],
    );
  }

  Widget _buildInsightRow(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
