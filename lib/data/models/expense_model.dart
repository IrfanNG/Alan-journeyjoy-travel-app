class Expense {
  final String id;
  final String tripId;
  String itemName;
  double amount;
  String category;
  DateTime createdAt;
  DateTime updatedAt;

  Expense({
    required this.id,
    required this.tripId,
    required this.itemName,
    required this.amount,
    this.category = 'Other',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'itemName': itemName,
        'amount': amount,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'] as String,
        tripId: map['tripId'] as String,
        itemName: map['itemName'] as String,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String? ?? 'Other',
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );
}

const List<String> expenseCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Accommodation',
  'Other',
];
