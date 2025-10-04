import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/transaction.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/receipt_service.dart';
import '../../../core/services/voice_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? preFilledData;

  const AddTransactionScreen({
    super.key,
    this.preFilledData,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _merchantController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _emotionalNoteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = 'Other';
  DateTime _selectedDate = DateTime.now();
  int _emotionalScore = 5;
  bool _isRecurring = false;
  String? _recurrencePattern;

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

  final List<String> _paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Bank Transfer',
    'Digital Wallet',
    'Other',
  ];

  final List<String> _recurrencePatterns = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  @override
  void initState() {
    super.initState();
    _preFillData();
  }

  void _preFillData() {
    if (widget.preFilledData != null) {
      final data = widget.preFilledData!;

      if (data['amount'] != null) {
        _amountController.text = data['amount'].toString();
      }

      if (data['description'] != null) {
        _descriptionController.text = data['description'];
      }

      if (data['category'] != null) {
        _selectedCategory = data['category'];
      }

      if (data['merchant'] != null) {
        _merchantController.text = data['merchant'];
      }

      if (data['type'] != null) {
        _selectedType = data['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense;
      }

      if (data['date'] != null) {
        _selectedDate = data['date'];
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    _paymentMethodController.dispose();
    _emotionalNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: _startVoiceInput,
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner),
            onPressed: _scanReceipt,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type
              Text(
                'Transaction Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.remove),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.add),
                  ),
                  ButtonSegment(
                    value: TransactionType.transfer,
                    label: Text('Transfer'),
                    icon: Icon(Icons.swap_horiz),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> selection) {
                  setState(() {
                    _selectedType = selection.first;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Merchant
              TextFormField(
                controller: _merchantController,
                decoration: const InputDecoration(
                  labelText: 'Merchant (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Payment Method
              DropdownButtonFormField<String>(
                value: _paymentMethodController.text.isEmpty
                    ? null
                    : _paymentMethodController.text,
                decoration: const InputDecoration(
                  labelText: 'Payment Method (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentMethodController.text = value ?? '';
                  });
                },
              ),

              const SizedBox(height: 24),

              // Emotional Spending Section
              Text(
                'Emotional Spending',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'How emotional was this purchase? (1-10)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _emotionalScore.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _emotionalScore.toString(),
                onChanged: (value) {
                  setState(() {
                    _emotionalScore = value.round();
                  });
                },
              ),

              const SizedBox(height: 16),

              // Emotional Note
              TextFormField(
                controller: _emotionalNoteController,
                decoration: const InputDecoration(
                  labelText: 'Emotional Note (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'How did you feel about this purchase?',
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Recurring Transaction
              CheckboxListTile(
                title: const Text('Recurring Transaction'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value ?? false;
                  });
                },
              ),

              if (_isRecurring) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _recurrencePattern,
                  decoration: const InputDecoration(
                    labelText: 'Recurrence Pattern',
                    border: OutlineInputBorder(),
                  ),
                  items: _recurrencePatterns.map((pattern) {
                    return DropdownMenuItem(
                      value: pattern,
                      child: Text(pattern),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _recurrencePattern = value;
                    });
                  },
                ),
              ],

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _startVoiceInput() async {
    try {
      await VoiceService.initialize();
      // TODO: Implement voice input processing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input feature coming soon!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice service not available: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scanReceipt() async {
    try {
      final receiptFile = await ReceiptService.captureReceipt();
      if (receiptFile != null) {
        final receiptData = await ReceiptService.processReceipt(receiptFile);
        _preFillFromReceipt(receiptData);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning receipt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _preFillFromReceipt(Map<String, dynamic> receiptData) {
    setState(() {
      if (receiptData['amount'] != null) {
        _amountController.text = receiptData['amount'].toString();
      }
      if (receiptData['description'] != null) {
        _descriptionController.text = receiptData['description'];
      }
      if (receiptData['category'] != null) {
        _selectedCategory = receiptData['category'];
      }
      if (receiptData['merchant'] != null) {
        _merchantController.text = receiptData['merchant'];
      }
      if (receiptData['date'] != null) {
        _selectedDate = receiptData['date'];
      }
    });
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: const Uuid().v4(),
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        description: _descriptionController.text,
        date: _selectedDate,
        type: _selectedType,
        merchant:
            _merchantController.text.isEmpty ? null : _merchantController.text,
        paymentMethod: _paymentMethodController.text.isEmpty
            ? null
            : _paymentMethodController.text,
        isRecurring: _isRecurring,
        recurrencePattern: _recurrencePattern,
        emotionalScore: _emotionalScore,
        emotionalNote: _emotionalNoteController.text.isEmpty
            ? null
            : _emotionalNoteController.text,
      );

      try {
        await context.read<TransactionProvider>().addTransaction(transaction);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving transaction: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
