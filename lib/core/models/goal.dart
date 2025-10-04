import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 4)
enum GoalType {
  @HiveField(0)
  savings,
  @HiveField(1)
  debt,
  @HiveField(2)
  investment,
  @HiveField(3)
  emergency,
  @HiveField(4)
  custom,
}

@HiveType(typeId: 5)
class MicroAction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  double amount;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime? completedAt;

  MicroAction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    this.isCompleted = false,
    this.completedAt,
  });

  factory MicroAction.fromJson(Map<String, dynamic> json) {
    return MicroAction(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

@HiveType(typeId: 6)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  GoalType type;

  @HiveField(5)
  DateTime targetDate;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  String? description;

  @HiveField(8)
  String? icon;

  @HiveField(9)
  List<MicroAction> microActions;

  @HiveField(10)
  double monthlyContribution;

  @HiveField(11)
  bool autoContribution;

  @HiveField(12)
  String? category;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime updatedAt;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.type,
    required this.targetDate,
    this.isActive = true,
    this.description,
    this.icon,
    this.microActions = const [],
    this.monthlyContribution = 0.0,
    this.autoContribution = false,
    this.category,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get progress => (currentAmount / targetAmount) * 100;
  double get remainingAmount => targetAmount - currentAmount;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
  bool get isOnTrack =>
      daysRemaining > 0 &&
      (currentAmount / targetAmount) >=
          (DateTime.now().difference(createdAt).inDays /
              targetDate.difference(createdAt).inDays);

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      name: json['name'],
      targetAmount: json['targetAmount'].toDouble(),
      currentAmount: json['currentAmount']?.toDouble() ?? 0.0,
      type: GoalType.values.firstWhere(
        (e) => e.toString() == 'GoalType.${json['type']}',
      ),
      targetDate: DateTime.parse(json['targetDate']),
      isActive: json['isActive'] ?? true,
      description: json['description'],
      icon: json['icon'],
      microActions: (json['microActions'] as List?)
              ?.map((e) => MicroAction.fromJson(e))
              .toList() ??
          [],
      monthlyContribution: json['monthlyContribution']?.toDouble() ?? 0.0,
      autoContribution: json['autoContribution'] ?? false,
      category: json['category'],
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
      'type': type.toString().split('.').last,
      'targetDate': targetDate.toIso8601String(),
      'isActive': isActive,
      'description': description,
      'icon': icon,
      'microActions': microActions.map((e) => e.toJson()).toList(),
      'monthlyContribution': monthlyContribution,
      'autoContribution': autoContribution,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Goal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    GoalType? type,
    DateTime? targetDate,
    bool? isActive,
    String? description,
    String? icon,
    List<MicroAction>? microActions,
    double? monthlyContribution,
    bool? autoContribution,
    String? category,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      type: type ?? this.type,
      targetDate: targetDate ?? this.targetDate,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      microActions: microActions ?? this.microActions,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      autoContribution: autoContribution ?? this.autoContribution,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
