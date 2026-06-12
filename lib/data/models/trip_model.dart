class Trip {
  final String id;
  String name;
  String colorHex;
  DateTime? startDate;
  DateTime? endDate;
  DateTime createdAt;
  DateTime updatedAt;

  Trip({
    required this.id,
    required this.name,
    this.colorHex = '#6C63FF',
    this.startDate,
    this.endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Trip.fromMap(Map<String, dynamic> map) => Trip(
        id: map['id'] as String,
        name: map['name'] as String,
        colorHex: map['colorHex'] as String? ?? '#6C63FF',
        startDate: map['startDate'] != null
            ? DateTime.parse(map['startDate'] as String)
            : null,
        endDate: map['endDate'] != null
            ? DateTime.parse(map['endDate'] as String)
            : null,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );
}
