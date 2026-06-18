class AircraftCategory {
  final String id;
  final String label;
  final String glyph;
  final bool complex;

  const AircraftCategory({
    required this.id,
    required this.label,
    required this.glyph,
    this.complex = false,
  });
}

class RatingDef {
  final String id;
  final String label;
  final String summary;

  const RatingDef({
    required this.id,
    required this.label,
    required this.summary,
  });
}

class CurrencyRule {
  final String id;
  final String label;
  final String detail;
  final int landingsRequired;
  final int windowDays;
  final bool nightWindow;

  const CurrencyRule({
    required this.id,
    required this.label,
    required this.detail,
    required this.landingsRequired,
    required this.windowDays,
    required this.nightWindow,
  });
}

class CertKind {
  final String id;
  final String label;
  final String hint;
  final String glyph;

  const CertKind({
    required this.id,
    required this.label,
    required this.hint,
    required this.glyph,
  });
}

class ReferenceData {
  static const List<AircraftCategory> categories = [
    AircraftCategory(
        id: 'asel', label: 'Single-engine land', glyph: '🛩️'),
    AircraftCategory(
        id: 'amel', label: 'Multi-engine land', glyph: '✈️', complex: true),
    AircraftCategory(id: 'tw', label: 'Tailwheel', glyph: '🛬'),
    AircraftCategory(
        id: 'complex', label: 'Complex / high-perf', glyph: '⚙️', complex: true),
    AircraftCategory(id: 'glider', label: 'Glider', glyph: '🪂'),
    AircraftCategory(id: 'heli', label: 'Helicopter', glyph: '🚁'),
    AircraftCategory(id: 'sim', label: 'Simulator / FTD', glyph: '🖥️'),
  ];

  static AircraftCategory categoryById(String id) => categories
      .firstWhere((c) => c.id == id, orElse: () => categories.first);

  static const List<RatingDef> ratings = [
    RatingDef(
      id: 'ppl',
      label: 'Private Pilot',
      summary:
          'Carry passengers, fly for personal travel. Typical minimums include 40 hours total with cross-country and night experience.',
    ),
    RatingDef(
      id: 'instrument',
      label: 'Instrument Rating',
      summary:
          'Fly in instrument meteorological conditions. Built on cross-country and instrument time under the hood or actual.',
    ),
    RatingDef(
      id: 'commercial',
      label: 'Commercial Pilot',
      summary:
          'Fly for compensation. Emphasises total time, cross-country and complex/high-performance experience.',
    ),
    RatingDef(
      id: 'multi',
      label: 'Multi-Engine',
      summary:
          'Operate aeroplanes with more than one engine. Logged separately as multi-engine land time.',
    ),
    RatingDef(
      id: 'cfi',
      label: 'Flight Instructor',
      summary:
          'Give instruction and endorsements. Builds dual-given time on top of the commercial certificate.',
    ),
    RatingDef(
      id: 'atp',
      label: 'Airline Transport',
      summary:
          'Highest pilot certificate. Requires substantial total, PIC, cross-country and night totals.',
    ),
  ];

  static const List<CurrencyRule> currencyRules = [
    CurrencyRule(
      id: 'pax_day',
      label: 'Passengers — day',
      detail:
          'Three take-offs and landings in the last 90 days to carry passengers in daylight.',
      landingsRequired: 3,
      windowDays: 90,
      nightWindow: false,
    ),
    CurrencyRule(
      id: 'pax_night',
      label: 'Passengers — night',
      detail:
          'Three take-offs and full-stop landings at night in the last 90 days to carry passengers after dark.',
      landingsRequired: 3,
      windowDays: 90,
      nightWindow: true,
    ),
  ];

  static const List<CertKind> certKinds = [
    CertKind(
      id: 'medical',
      label: 'Medical certificate',
      hint: 'Class duration depends on age and class of medical.',
      glyph: '🩺',
    ),
    CertKind(
      id: 'flight_review',
      label: 'Flight review',
      hint: 'A flight review is generally required every 24 calendar months.',
      glyph: '📋',
    ),
    CertKind(
      id: 'licence',
      label: 'Certificate / licence',
      hint: 'Track any expiry on a certificate or rating you hold.',
      glyph: '🪪',
    ),
  ];

  static CertKind certKindById(String id) =>
      certKinds.firstWhere((k) => k.id == id, orElse: () => certKinds.first);
}
