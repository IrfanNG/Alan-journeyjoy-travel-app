class Trip {
  final String id;
  String name;
  String colorHex;
  DateTime createdAt;

  Trip({
    required this.id,
    required this.name,
    this.colorHex = '#6C63FF',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Trip.fromMap(Map<String, dynamic> map) => Trip(
        id: map['id'] as String,
        name: map['name'] as String,
        colorHex: map['colorHex'] as String? ?? '#6C63FF',
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
