import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:journey_joy/data/services/local_storage_service.dart';
import 'package:journey_joy/main.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('journey_joy_test');
    await LocalStorageService.initForTesting(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('trips');
    await Hive.deleteBoxFromDisk('expenses');
    await Hive.deleteBoxFromDisk('flights');
    await Hive.deleteBoxFromDisk('activities');
    await Hive.deleteBoxFromDisk('packing');
    await Hive.deleteBoxFromDisk('settings');
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const JourneyJoyApp());
    expect(find.text('Journey Joy'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
