import 'reference_data.dart';

enum ConditionKind { day, night }

extension ConditionKindMeta on ConditionKind {
  String get id {
    switch (this) {
      case ConditionKind.day:
        return 'day';
      case ConditionKind.night:
        return 'night';
    }
  }

  String get label {
    switch (this) {
      case ConditionKind.day:
        return 'Day';
      case ConditionKind.night:
        return 'Night';
    }
  }

  static ConditionKind fromId(String? v) {
    switch (v) {
      case 'night':
        return ConditionKind.night;
      default:
        return ConditionKind.day;
    }
  }
}

class LogEntry {
  final String id;
  DateTime flownOn;
  String categoryId;
  String tail;
  String routeFrom;
  String routeTo;
  double totalTime;
  double pic;
  double dualReceived;
  double solo;
  double crossCountry;
  double nightTime;
  double instrument;
  double simInstrument;
  ConditionKind condition;
  int dayLandings;
  int nightLandings;
  String remarks;

  LogEntry({
    required this.id,
    required this.flownOn,
    required this.categoryId,
    required this.tail,
    required this.routeFrom,
    required this.routeTo,
    required this.totalTime,
    this.pic = 0,
    this.dualReceived = 0,
    this.solo = 0,
    this.crossCountry = 0,
    this.nightTime = 0,
    this.instrument = 0,
    this.simInstrument = 0,
    this.condition = ConditionKind.day,
    this.dayLandings = 0,
    this.nightLandings = 0,
    this.remarks = '',
  });

  AircraftCategory get category => ReferenceData.categoryById(categoryId);

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String get route {
    final f = routeFrom.trim();
    final t = routeTo.trim();
    if (f.isEmpty && t.isEmpty) return 'Local';
    if (t.isEmpty || t == f) return f;
    return '$f → $t';
  }

  int get totalLandings => dayLandings + nightLandings;

  bool withinDays(DateTime now, int days) {
    final age = _dateOnly(now).difference(_dateOnly(flownOn)).inDays;
    return age >= 0 && age < days;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'flownOn': flownOn.toIso8601String(),
        'category': categoryId,
        'tail': tail,
        'from': routeFrom,
        'to': routeTo,
        'total': totalTime,
        'pic': pic,
        'dual': dualReceived,
        'solo': solo,
        'xc': crossCountry,
        'night': nightTime,
        'ifr': instrument,
        'simIfr': simInstrument,
        'condition': condition.id,
        'dayLdg': dayLandings,
        'nightLdg': nightLandings,
        'remarks': remarks,
      };

  static double _d(dynamic v) => v == null ? 0 : (v as num).toDouble();
  static int _i(dynamic v) => v == null ? 0 : (v as num).toInt();

  static LogEntry fromJson(Map<String, dynamic> j) => LogEntry(
        id: j['id'] as String,
        flownOn: DateTime.parse(j['flownOn'] as String),
        categoryId: j['category'] as String? ?? 'asel',
        tail: j['tail'] as String? ?? '',
        routeFrom: j['from'] as String? ?? '',
        routeTo: j['to'] as String? ?? '',
        totalTime: _d(j['total']),
        pic: _d(j['pic']),
        dualReceived: _d(j['dual']),
        solo: _d(j['solo']),
        crossCountry: _d(j['xc']),
        nightTime: _d(j['night']),
        instrument: _d(j['ifr']),
        simInstrument: _d(j['simIfr']),
        condition: ConditionKindMeta.fromId(j['condition'] as String?),
        dayLandings: _i(j['dayLdg']),
        nightLandings: _i(j['nightLdg']),
        remarks: j['remarks'] as String? ?? '',
      );
}

class LogTotals {
  final double total;
  final double pic;
  final double dualReceived;
  final double solo;
  final double crossCountry;
  final double nightTime;
  final double instrument;
  final int dayLandings;
  final int nightLandings;
  final int flights;

  const LogTotals({
    required this.total,
    required this.pic,
    required this.dualReceived,
    required this.solo,
    required this.crossCountry,
    required this.nightTime,
    required this.instrument,
    required this.dayLandings,
    required this.nightLandings,
    required this.flights,
  });

  int get totalLandings => dayLandings + nightLandings;

  static LogTotals from(Iterable<LogEntry> entries) {
    double total = 0,
        pic = 0,
        dual = 0,
        solo = 0,
        xc = 0,
        night = 0,
        ifr = 0;
    int dayLdg = 0, nightLdg = 0, flights = 0;
    for (final e in entries) {
      total += e.totalTime;
      pic += e.pic;
      dual += e.dualReceived;
      solo += e.solo;
      xc += e.crossCountry;
      night += e.nightTime;
      ifr += e.instrument + e.simInstrument;
      dayLdg += e.dayLandings;
      nightLdg += e.nightLandings;
      flights += 1;
    }
    return LogTotals(
      total: total,
      pic: pic,
      dualReceived: dual,
      solo: solo,
      crossCountry: xc,
      nightTime: night,
      instrument: ifr,
      dayLandings: dayLdg,
      nightLandings: nightLdg,
      flights: flights,
    );
  }
}

class CurrencyStatus {
  final CurrencyRule rule;
  final int landingsLogged;
  final DateTime? validUntil;
  final DateTime? oldestCountedOn;

  const CurrencyStatus({
    required this.rule,
    required this.landingsLogged,
    required this.validUntil,
    required this.oldestCountedOn,
  });

  bool get current => landingsLogged >= rule.landingsRequired;
  int get remaining {
    final r = rule.landingsRequired - landingsLogged;
    return r < 0 ? 0 : r;
  }
}

class Endorsement {
  final String id;
  String title;
  String instructor;
  DateTime grantedOn;
  String note;

  Endorsement({
    required this.id,
    required this.title,
    required this.instructor,
    required this.grantedOn,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'instructor': instructor,
        'grantedOn': grantedOn.toIso8601String(),
        'note': note,
      };

  static Endorsement fromJson(Map<String, dynamic> j) => Endorsement(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        instructor: j['instructor'] as String? ?? '',
        grantedOn: DateTime.parse(j['grantedOn'] as String),
        note: j['note'] as String? ?? '',
      );
}

class CertItem {
  final String id;
  String kindId;
  DateTime expiresOn;
  String label;

  CertItem({
    required this.id,
    required this.kindId,
    required this.expiresOn,
    this.label = '',
  });

  CertKind get kind => ReferenceData.certKindById(kindId);

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int daysRemaining(DateTime now) =>
      _dateOnly(expiresOn).difference(_dateOnly(now)).inDays;

  bool get expired {
    return daysRemaining(DateTime.now()) < 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kindId,
        'expiresOn': expiresOn.toIso8601String(),
        'label': label,
      };

  static CertItem fromJson(Map<String, dynamic> j) => CertItem(
        id: j['id'] as String,
        kindId: j['kind'] as String? ?? 'medical',
        expiresOn: DateTime.parse(j['expiresOn'] as String),
        label: j['label'] as String? ?? '',
      );
}
