class Activity {
  final String id;
  final String tripId;
  String name;
  String? details;
  DateTime date;
  String? timeText;
  String? referenceLink;

  Activity({
    required this.id,
    required this.tripId,
    required this.name,
    this.details,
    required this.date,
    this.timeText,
    this.referenceLink,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'name': name,
        'details': details,
        'date': date.toIso8601String(),
        'timeText': timeText,
        'referenceLink': referenceLink,
      };

  factory Activity.fromMap(Map<String, dynamic> map) => Activity(
        id: map['id'] as String,
        tripId: map['tripId'] as String,
        name: map['name'] as String,
        details: map['details'] as String?,
        date: DateTime.parse(map['date'] as String),
        timeText: map['timeText'] as String?,
        referenceLink: map['referenceLink'] as String?,
      );
}
