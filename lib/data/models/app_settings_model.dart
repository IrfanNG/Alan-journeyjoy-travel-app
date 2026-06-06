class AppSettings {
  String? username;
  bool hasSeenWelcome;
  bool darkModeEnabled;
  String currencyCode;

  AppSettings({
    this.username,
    this.hasSeenWelcome = false,
    this.darkModeEnabled = false,
    this.currencyCode = 'USD',
  });

  Map<String, dynamic> toMap() => {
        'username': username,
        'hasSeenWelcome': hasSeenWelcome,
        'darkModeEnabled': darkModeEnabled,
        'currencyCode': currencyCode,
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        username: map['username'] as String?,
        hasSeenWelcome: map['hasSeenWelcome'] as bool? ?? false,
        darkModeEnabled: map['darkModeEnabled'] as bool? ?? false,
        currencyCode: map['currencyCode'] as String? ?? 'USD',
      );
}
