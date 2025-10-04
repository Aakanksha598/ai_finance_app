import 'package:flutter/material.dart';

import '../../../core/services/receipt_service.dart';
import '../../../core/services/voice_service.dart';
import '../../transactions/screens/add_transaction_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              context,
              'Voice Entry',
              Icons.mic,
              Colors.blue,
              () => _handleVoiceEntry(context),
            ),
            _buildActionCard(
              context,
              'Scan Receipt',
              Icons.document_scanner,
              Colors.green,
              () => _handleReceiptScan(context),
            ),
            _buildActionCard(
              context,
              'Manual Entry',
              Icons.edit,
              Colors.orange,
              () => _handleManualEntry(context),
            ),
            _buildActionCard(
              context,
              'AI Chat',
              Icons.chat,
              Colors.purple,
              () => _handleAIChat(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleVoiceEntry(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Initialize voice service
      await VoiceService.initialize();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show voice input dialog
      _showVoiceInputDialog(context);
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice service not available: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showVoiceInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Entry'),
        content: const Text(
            'Tap the microphone and speak your transaction details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement voice input processing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voice entry feature coming soon!'),
                ),
              );
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _handleReceiptScan(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Capture receipt
      final receiptFile = await ReceiptService.captureReceipt();

      // Close loading dialog
      Navigator.of(context).pop();

      if (receiptFile != null) {
        // Process receipt
        final receiptData = await ReceiptService.processReceipt(receiptFile);

        // Navigate to add transaction with pre-filled data
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddTransactionScreen(
              preFilledData: receiptData,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No receipt captured'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning receipt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleManualEntry(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );
  }

  void _handleAIChat(BuildContext context) {
    // TODO: Navigate to AI chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI Chat feature coming soon!'),
      ),
    );
  }
}
