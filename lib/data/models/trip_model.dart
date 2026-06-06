class Trip {
  final String id;
  String name;
  String colorHex;
  DateTime createdAt;
  DateTime updatedAt;

  Trip({
    required this.id,
    required this.name,
    this.colorHex = '#6C63FF',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Trip.fromMap(Map<String, dynamic> map) => Trip(
        id: map['id'] as String,
        name: map['name'] as String,
        colorHex: map['colorHex'] as String? ?? '#6C63FF',
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );
}
