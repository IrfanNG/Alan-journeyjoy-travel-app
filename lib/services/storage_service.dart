import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage? _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? _tryInit();

  static FirebaseStorage? _tryInit() {
    try {
      return FirebaseStorage.instance;
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadFile({
    required String userId,
    required String tripId,
    required String filePath,
    String? fileName,
  }) async {
    if (_storage == null) return null;
    try {
      final name = fileName ?? p.basename(filePath);
      final ref = _storage.ref().child(
          'users/$userId/trips/$tripId/documents/$name');
      final task = await ref.putFile(
        File(filePath),
        SettableMetadata(contentType: _inferMimeType(name)),
      );
      return await task.ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteFile(String url) async {
    if (_storage == null) return;
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }

  String _inferMimeType(String fileName) {
    final ext = p.extension(fileName).toLowerCase();
    switch (ext) {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.doc':
      case '.docx':
        return 'application/msword';
      case '.xls':
      case '.xlsx':
        return 'application/vnd.ms-excel';
      default:
        return 'application/octet-stream';
    }
  }
}
