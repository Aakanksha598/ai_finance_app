import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 2)
enum BudgetPeriod {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
}

@HiveType(typeId: 3)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  String category;

  @HiveField(5)
  BudgetPeriod period;

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime endDate;

  @HiveField(8)
  bool isActive;

  @HiveField(9)
  double alertThreshold; // Percentage (e.g., 80 for 80%)

  @HiveField(10)
  bool notificationsEnabled;

  @HiveField(11)
  String? description;

  @HiveField(12)
  String? icon;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime updatedAt;

  Budget({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.category,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.alertThreshold = 80.0,
    this.notificationsEnabled = true,
    this.description,
    this.icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get progress => (currentAmount / targetAmount) * 100;
  bool get isOverBudget => currentAmount > targetAmount;
  bool get isNearLimit => progress >= alertThreshold;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      targetAmount: json['targetAmount'].toDouble(),
      currentAmount: json['currentAmount']?.toDouble() ?? 0.0,
      category: json['category'],
      period: BudgetPeriod.values.firstWhere(
        (e) => e.toString() == 'BudgetPeriod.${json['period']}',
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? true,
      alertThreshold: json['alertThreshold']?.toDouble() ?? 80.0,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      description: json['description'],
      icon: json['icon'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'category': category,
      'period': period.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'alertThreshold': alertThreshold,
      'notificationsEnabled': notificationsEnabled,
      'description': description,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Budget copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? category,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    double? alertThreshold,
    bool? notificationsEnabled,
    String? description,
    String? icon,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      category: category ?? this.category,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
