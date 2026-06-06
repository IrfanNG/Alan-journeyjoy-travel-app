class Document {
  final String id;
  final String tripId;
  String name;
  String category;
  String? localPath;
  String? remoteUrl;
  String? mimeType;
  int fileSize;
  DateTime createdAt;
  DateTime updatedAt;

  Document({
    required this.id,
    required this.tripId,
    required this.name,
    this.category = 'Other',
    this.localPath,
    this.remoteUrl,
    this.mimeType,
    this.fileSize = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get sizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'name': name,
        'category': category,
        'localPath': localPath,
        'remoteUrl': remoteUrl,
        'mimeType': mimeType,
        'fileSize': fileSize,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Document.fromMap(Map<String, dynamic> map) => Document(
        id: map['id'] as String,
        tripId: map['tripId'] as String,
        name: map['name'] as String,
        category: map['category'] as String? ?? 'Other',
        localPath: map['localPath'] as String?,
        remoteUrl: map['remoteUrl'] as String?,
        mimeType: map['mimeType'] as String?,
        fileSize: (map['fileSize'] as num?)?.toInt() ?? 0,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : null,
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );
}
