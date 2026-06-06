class AppSettings {
  String? username;
  bool hasSeenWelcome;
  bool darkModeEnabled;
  String currencyCode;
  DateTime updatedAt;

  AppSettings({
    this.username,
    this.hasSeenWelcome = false,
    this.darkModeEnabled = false,
    this.currencyCode = 'USD',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'username': username,
        'hasSeenWelcome': hasSeenWelcome,
        'darkModeEnabled': darkModeEnabled,
        'currencyCode': currencyCode,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        username: map['username'] as String?,
        hasSeenWelcome: map['hasSeenWelcome'] as bool? ?? false,
        darkModeEnabled: map['darkModeEnabled'] as bool? ?? false,
        currencyCode: map['currencyCode'] as String? ?? 'USD',
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );
}
