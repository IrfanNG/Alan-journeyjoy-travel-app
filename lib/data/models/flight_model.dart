class Flight {
  final String id;
  final String tripId;
  String flightNumber;
  String? airline;
  String fromLocation;
  String toLocation;
  DateTime departureTime;
  DateTime arrivalTime;
  DateTime updatedAt;

  Flight({
    required this.id,
    required this.tripId,
    required this.flightNumber,
    this.airline,
    required this.fromLocation,
    required this.toLocation,
    required this.departureTime,
    required this.arrivalTime,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'flightNumber': flightNumber,
        'airline': airline,
        'fromLocation': fromLocation,
        'toLocation': toLocation,
        'departureTime': departureTime.toIso8601String(),
        'arrivalTime': arrivalTime.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Flight.fromMap(Map<String, dynamic> map) => Flight(
        id: map['id'] as String,
        tripId: map['tripId'] as String,
        flightNumber: map['flightNumber'] as String,
        airline: map['airline'] as String?,
        fromLocation: map['fromLocation'] as String,
        toLocation: map['toLocation'] as String,
        departureTime: DateTime.parse(map['departureTime'] as String),
        arrivalTime: DateTime.parse(map['arrivalTime'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );
}
