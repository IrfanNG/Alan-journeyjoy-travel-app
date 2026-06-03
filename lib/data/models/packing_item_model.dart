class PackingItem {
  final String id;
  final String tripId;
  String name;
  bool isPacked;

  PackingItem({
    required this.id,
    required this.tripId,
    required this.name,
    this.isPacked = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'name': name,
        'isPacked': isPacked,
      };

  factory PackingItem.fromMap(Map<String, dynamic> map) => PackingItem(
        id: map['id'] as String,
        tripId: map['tripId'] as String,
        name: map['name'] as String,
        isPacked: map['isPacked'] as bool? ?? false,
      );
}
