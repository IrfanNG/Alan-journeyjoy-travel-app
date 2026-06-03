class Expense {
  final String id;
  final String tripId;
  String itemName;
  double amount;
  String category;
  DateTime createdAt;

  Expense({
    required this.id,
    required this.tripId,
    required this.itemName,
    required this.amount,
    this.category = 'Other',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'itemName': itemName,
        'amount': amount,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'] as String,
        tripId: map['tripId'] as String,
        itemName: map['itemName'] as String,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String? ?? 'Other',
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

const List<String> expenseCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Accommodation',
  'Other',
];
