class Activity {
  final String id;
  final String tripId;
  String name;
  String? details;
  DateTime date;
  String? timeText;
  String? referenceLink;
  DateTime updatedAt;

  Activity({
    required this.id,
    required this.tripId,
    required this.name,
    this.details,
    required this.date,
    this.timeText,
    this.referenceLink,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'name': name,
        'details': details,
        'date': date.toIso8601String(),
        'timeText': timeText,
        'referenceLink': referenceLink,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Activity.fromMap(Map<String, dynamic> map) => Activity(
        id: map['id'] as String,
        tripId: map['tripId'] as String,
        name: map['name'] as String,
        details: map['details'] as String?,
        date: DateTime.parse(map['date'] as String),
        timeText: map['timeText'] as String?,
        referenceLink: map['referenceLink'] as String?,
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );
}
