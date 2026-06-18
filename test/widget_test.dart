import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pilotlog/domain/log_models.dart';
import 'package:pilotlog/domain/reference_data.dart';
import 'package:pilotlog/widgets/wings_ring.dart';

void main() {
  testWidgets('WingsRing renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: WingsRing(size: 80, progress: 0.5)),
        ),
      ),
    );
    expect(find.byType(WingsRing), findsOneWidget);
  });

  test('totals sum across entries', () {
    final entries = [
      LogEntry(
        id: 'a',
        flownOn: DateTime(2026, 1, 1),
        categoryId: 'asel',
        tail: 'N1',
        routeFrom: 'KSQL',
        routeTo: 'KPAO',
        totalTime: 1.5,
        pic: 1.5,
        dayLandings: 2,
      ),
      LogEntry(
        id: 'b',
        flownOn: DateTime(2026, 1, 2),
        categoryId: 'asel',
        tail: 'N1',
        routeFrom: 'KPAO',
        routeTo: 'KSQL',
        totalTime: 2.0,
        pic: 2.0,
        crossCountry: 2.0,
        nightLandings: 1,
      ),
    ];
    final totals = LogTotals.from(entries);
    expect(totals.total, 3.5);
    expect(totals.pic, 3.5);
    expect(totals.crossCountry, 2.0);
    expect(totals.totalLandings, 3);
  });

  test('reference data covers core currency rules', () {
    expect(ReferenceData.currencyRules.length, 2);
    expect(ReferenceData.currencyRules.first.windowDays, 90);
    expect(ReferenceData.categoryById('amel').complex, true);
  });
}
