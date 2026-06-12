class ItineraryDay {
  final String id;
  final String tripId;
  DateTime date;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  ItineraryDay({
    required this.id,
    required this.tripId,
    required this.date,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'date': date.toIso8601String(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ItineraryDay.fromMap(Map<String, dynamic> map) => ItineraryDay(
        id: map['id'] as String,
        tripId: map['tripId'] as String,
        date: DateTime.parse(map['date'] as String),
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );
}
