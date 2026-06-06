class PackingItem {
  final String id;
  final String tripId;
  String name;
  bool isPacked;
  DateTime updatedAt;

  PackingItem({
    required this.id,
    required this.tripId,
    required this.name,
    this.isPacked = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'name': name,
        'isPacked': isPacked,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory PackingItem.fromMap(Map<String, dynamic> map) => PackingItem(
        id: map['id'] as String,
        tripId: map['tripId'] as String,
        name: map['name'] as String,
        isPacked: map['isPacked'] as bool? ?? false,
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );
}
