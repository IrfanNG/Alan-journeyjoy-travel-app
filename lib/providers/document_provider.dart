import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../data/models/document_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/sync_service.dart';
import '../services/storage_service.dart';

class DocumentProvider extends ChangeNotifier {
  final SyncService? _syncService;
  final StorageService _storageService;
  List<Document> _documents = [];

  DocumentProvider({
    SyncService? syncService,
    StorageService? storageService,
  })  : _syncService = syncService,
        _storageService = storageService ?? StorageService();

  void loadDocuments() {
    _documents = LocalStorageService.getDocuments();
    notifyListeners();
  }

  List<Document> getDocumentsForTrip(String tripId) {
    return _documents.where((d) => d.tripId == tripId).toList();
  }

  Future<void> pickAndUpload(String tripId, String? userId) async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    final filePath = picked.path;
    if (filePath == null) return;

    final fileName = picked.name;
    final fileSize = picked.size;
    final mimeType = picked.extension != null
        ? 'application/${picked.extension}'
        : null;

    String? remoteUrl;
    if (userId != null) {
      remoteUrl = await _storageService.uploadFile(
        userId: userId,
        tripId: tripId,
        filePath: filePath,
        fileName: fileName,
      );
    }

    final doc = Document(
      id: const Uuid().v4(),
      tripId: tripId,
      name: fileName,
      category: 'Other',
      localPath: filePath,
      remoteUrl: remoteUrl,
      mimeType: mimeType,
      fileSize: fileSize,
    );

    _documents.add(doc);
    LocalStorageService.saveDocuments(_documents);
    notifyListeners();

    _syncService?.syncCreate(
      entityType: 'documents',
      tripId: tripId,
      entityId: doc.id,
      data: doc.toMap(),
    );
  }

  Future<void> deleteDocument(String id) async {
    final index = _documents.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final doc = _documents[index];
    final tripId = doc.tripId;

    if (doc.remoteUrl != null) {
      await _storageService.deleteFile(doc.remoteUrl!);
    }

    _documents.removeAt(index);
    LocalStorageService.saveDocuments(_documents);
    notifyListeners();

    _syncService?.syncDelete(
      entityType: 'documents',
      tripId: tripId,
      entityId: id,
    );
  }

  void deleteByTripId(String tripId) {
    _documents.removeWhere((d) => d.tripId == tripId);
    LocalStorageService.saveDocuments(_documents);
    notifyListeners();
  }

  void clear() {
    _documents.clear();
    LocalStorageService.saveDocuments(_documents);
    notifyListeners();
  }
}
