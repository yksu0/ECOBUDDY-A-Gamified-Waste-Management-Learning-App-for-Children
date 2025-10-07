// This is a basic Flutter widget test for EcoBuddy app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecobud/main.dart';
import 'package:ecobud/services/achievement_service.dart';
import 'package:ecobud/services/challenge_service.dart';
import 'package:ecobud/services/almanac_service.dart';
import 'package:ecobud/services/scan_history_service.dart';

void main() {
  testWidgets('EcoBuddy app smoke test', (WidgetTester tester) async {
    // Initialize services for testing
    final achievementService = AchievementService();
    final challengeService = ChallengeService();
    final almanacService = AlmanacService();
    final scanHistoryService = ScanHistoryService();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(EcoBuddyApp(
      achievementService: achievementService,
      challengeService: challengeService,
      almanacService: almanacService,
      scanHistoryService: scanHistoryService,
    ));

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
