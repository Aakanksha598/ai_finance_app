import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
  @HiveField(2)
  transfer,
}

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String category;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  TransactionType type;

  @HiveField(6)
  String? receiptPath;

  @HiveField(7)
  String? voicePath;

  @HiveField(8)
  String? location;

  @HiveField(9)
  String? merchant;

  @HiveField(10)
  String? paymentMethod;

  @HiveField(11)
  bool isRecurring;

  @HiveField(12)
  String? recurrencePattern;

  @HiveField(13)
  int emotionalScore; // 1-10 scale

  @HiveField(14)
  String? emotionalNote;

  @HiveField(15)
  bool isOffline;

  @HiveField(16)
  DateTime createdAt;

  @HiveField(17)
  DateTime updatedAt;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.type,
    this.receiptPath,
    this.voicePath,
    this.location,
    this.merchant,
    this.paymentMethod,
    this.isRecurring = false,
    this.recurrencePattern,
    this.emotionalScore = 5,
    this.emotionalNote,
    this.isOffline = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
      ),
      receiptPath: json['receiptPath'],
      voicePath: json['voicePath'],
      location: json['location'],
      merchant: json['merchant'],
      paymentMethod: json['paymentMethod'],
      isRecurring: json['isRecurring'] ?? false,
      recurrencePattern: json['recurrencePattern'],
      emotionalScore: json['emotionalScore'] ?? 5,
      emotionalNote: json['emotionalNote'],
      isOffline: json['isOffline'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'receiptPath': receiptPath,
      'voicePath': voicePath,
      'location': location,
      'merchant': merchant,
      'paymentMethod': paymentMethod,
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
      'emotionalScore': emotionalScore,
      'emotionalNote': emotionalNote,
      'isOffline': isOffline,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Transaction copyWith({
    String? id,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    TransactionType? type,
    String? receiptPath,
    String? voicePath,
    String? location,
    String? merchant,
    String? paymentMethod,
    bool? isRecurring,
    String? recurrencePattern,
    int? emotionalScore,
    String? emotionalNote,
    bool? isOffline,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      receiptPath: receiptPath ?? this.receiptPath,
      voicePath: voicePath ?? this.voicePath,
      location: location ?? this.location,
      merchant: merchant ?? this.merchant,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      emotionalScore: emotionalScore ?? this.emotionalScore,
      emotionalNote: emotionalNote ?? this.emotionalNote,
      isOffline: isOffline ?? this.isOffline,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
