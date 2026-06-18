import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'log_models.dart';
import 'reference_data.dart';

class LogbookRepository extends ChangeNotifier {
  static const _entriesKey = 'log.entries';
  static const _endorsementsKey = 'log.endorsements';
  static const _certsKey = 'log.certs';
  static const _uuid = Uuid();

  final List<LogEntry> _entries = [];
  final List<Endorsement> _endorsements = [];
  final List<CertItem> _certs = [];
  bool _loaded = false;

  List<LogEntry> get entries => List.unmodifiable(_entries);
  List<Endorsement> get endorsements => List.unmodifiable(_endorsements);
  List<CertItem> get certs => List.unmodifiable(_certs);
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _readEntries(prefs.getString(_entriesKey));
    _readEndorsements(prefs.getString(_endorsementsKey));
    _readCerts(prefs.getString(_certsKey));
    _sortAll();
    _loaded = true;
    notifyListeners();
  }

  void _readEntries(String? raw) {
    _entries.clear();
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List;
      for (final e in list) {
        _entries.add(LogEntry.fromJson(e as Map<String, dynamic>));
      }
    } catch (_) {}
  }

  void _readEndorsements(String? raw) {
    _endorsements.clear();
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List;
      for (final e in list) {
        _endorsements.add(Endorsement.fromJson(e as Map<String, dynamic>));
      }
    } catch (_) {}
  }

  void _readCerts(String? raw) {
    _certs.clear();
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List;
      for (final e in list) {
        _certs.add(CertItem.fromJson(e as Map<String, dynamic>));
      }
    } catch (_) {}
  }

  void _sortAll() {
    _entries.sort((a, b) => b.flownOn.compareTo(a.flownOn));
    _endorsements.sort((a, b) => b.grantedOn.compareTo(a.grantedOn));
    _certs.sort((a, b) => a.expiresOn.compareTo(b.expiresOn));
  }

  Future<void> _persistEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _entriesKey, jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistEndorsements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_endorsementsKey,
        jsonEncode(_endorsements.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistCerts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _certsKey, jsonEncode(_certs.map((e) => e.toJson()).toList()));
  }

  LogEntry? entryById(String id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<LogEntry> addEntry({
    required DateTime flownOn,
    required String categoryId,
    required String tail,
    required String routeFrom,
    required String routeTo,
    required double totalTime,
    double pic = 0,
    double dualReceived = 0,
    double solo = 0,
    double crossCountry = 0,
    double nightTime = 0,
    double instrument = 0,
    double simInstrument = 0,
    ConditionKind condition = ConditionKind.day,
    int dayLandings = 0,
    int nightLandings = 0,
    String remarks = '',
  }) async {
    final entry = LogEntry(
      id: _uuid.v4(),
      flownOn: flownOn,
      categoryId: categoryId,
      tail: tail,
      routeFrom: routeFrom,
      routeTo: routeTo,
      totalTime: totalTime,
      pic: pic,
      dualReceived: dualReceived,
      solo: solo,
      crossCountry: crossCountry,
      nightTime: nightTime,
      instrument: instrument,
      simInstrument: simInstrument,
      condition: condition,
      dayLandings: dayLandings,
      nightLandings: nightLandings,
      remarks: remarks,
    );
    _entries.insert(0, entry);
    _entries.sort((a, b) => b.flownOn.compareTo(a.flownOn));
    await _persistEntries();
    notifyListeners();
    return entry;
  }

  Future<void> removeEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _persistEntries();
    notifyListeners();
  }

  LogTotals totals() => LogTotals.from(_entries);

  LogTotals totalsForCategory(String categoryId) =>
      LogTotals.from(_entries.where((e) => e.categoryId == categoryId));

  List<MapEntry<String, LogTotals>> totalsByCategory() {
    final ids = <String>[];
    for (final e in _entries) {
      if (!ids.contains(e.categoryId)) ids.add(e.categoryId);
    }
    return ids
        .map((id) => MapEntry(id, totalsForCategory(id)))
        .toList(growable: false);
  }

  CurrencyStatus currencyFor(CurrencyRule rule, {DateTime? asOf}) {
    final now = asOf ?? DateTime.now();
    final counted = <LogEntry>[];
    for (final e in _entries) {
      if (!e.withinDays(now, rule.windowDays)) continue;
      final landings = rule.nightWindow ? e.nightLandings : e.dayLandings;
      if (landings > 0) counted.add(e);
    }
    counted.sort((a, b) => b.flownOn.compareTo(a.flownOn));
    var running = 0;
    DateTime? oldest;
    for (final e in counted) {
      final add = rule.nightWindow ? e.nightLandings : e.dayLandings;
      running += add;
      oldest = e.flownOn;
      if (running >= rule.landingsRequired) break;
    }
    final valid = (running >= rule.landingsRequired && oldest != null)
        ? DateTime(oldest.year, oldest.month, oldest.day)
            .add(Duration(days: rule.windowDays))
        : null;
    return CurrencyStatus(
      rule: rule,
      landingsLogged: running,
      validUntil: valid,
      oldestCountedOn: oldest,
    );
  }

  List<CurrencyStatus> currencyBoard({DateTime? asOf}) => ReferenceData
      .currencyRules
      .map((r) => currencyFor(r, asOf: asOf))
      .toList(growable: false);

  Future<Endorsement> addEndorsement({
    required String title,
    required String instructor,
    required DateTime grantedOn,
    String note = '',
  }) async {
    final item = Endorsement(
      id: _uuid.v4(),
      title: title,
      instructor: instructor,
      grantedOn: grantedOn,
      note: note,
    );
    _endorsements.insert(0, item);
    _endorsements.sort((a, b) => b.grantedOn.compareTo(a.grantedOn));
    await _persistEndorsements();
    notifyListeners();
    return item;
  }

  Future<void> removeEndorsement(String id) async {
    _endorsements.removeWhere((e) => e.id == id);
    await _persistEndorsements();
    notifyListeners();
  }

  Future<CertItem> upsertCert({
    String? id,
    required String kindId,
    required DateTime expiresOn,
    String label = '',
  }) async {
    if (id != null) {
      final existing = _certs.firstWhere(
        (c) => c.id == id,
        orElse: () => CertItem(id: id, kindId: kindId, expiresOn: expiresOn),
      );
      existing.kindId = kindId;
      existing.expiresOn = expiresOn;
      existing.label = label;
      if (!_certs.contains(existing)) _certs.add(existing);
      _certs.sort((a, b) => a.expiresOn.compareTo(b.expiresOn));
      await _persistCerts();
      notifyListeners();
      return existing;
    }
    final item = CertItem(
      id: _uuid.v4(),
      kindId: kindId,
      expiresOn: expiresOn,
      label: label,
    );
    _certs.add(item);
    _certs.sort((a, b) => a.expiresOn.compareTo(b.expiresOn));
    await _persistCerts();
    notifyListeners();
    return item;
  }

  Future<void> removeCert(String id) async {
    _certs.removeWhere((c) => c.id == id);
    await _persistCerts();
    notifyListeners();
  }

  String exportSummary() {
    final t = totals();
    final buf = StringBuffer();
    buf.writeln('PILOT LOGBOOK SUMMARY');
    buf.writeln('Generated ${DateTime.now().toIso8601String().split('T').first}');
    buf.writeln('');
    buf.writeln('Flights logged: ${t.flights}');
    buf.writeln('Total time:        ${t.total.toStringAsFixed(1)}');
    buf.writeln('PIC:               ${t.pic.toStringAsFixed(1)}');
    buf.writeln('Dual received:     ${t.dualReceived.toStringAsFixed(1)}');
    buf.writeln('Solo:              ${t.solo.toStringAsFixed(1)}');
    buf.writeln('Cross-country:     ${t.crossCountry.toStringAsFixed(1)}');
    buf.writeln('Night:             ${t.nightTime.toStringAsFixed(1)}');
    buf.writeln('Instrument:        ${t.instrument.toStringAsFixed(1)}');
    buf.writeln('Landings (day):    ${t.dayLandings}');
    buf.writeln('Landings (night):  ${t.nightLandings}');
    return buf.toString();
  }
}
