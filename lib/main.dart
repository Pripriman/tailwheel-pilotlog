import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'domain/logbook_repository.dart';
import 'runtime/backend_link.dart';
import 'runtime/signal_relay.dart';
import 'runtime/trace_beacon.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await BackendLink.boot();
  } catch (_) {}

  await SignalRelay.boot();
  TraceBeacon.boot();

  final repo = LogbookRepository();
  await repo.load();

  await _markFirstOpen();

  runApp(PilotLogApp(repo: repo));
}

Future<void> _markFirstOpen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    const key = 'log.firstOpenSent';
    if (!(prefs.getBool(key) ?? false)) {
      TraceBeacon.firstOpen();
      await prefs.setBool(key, true);
    }
  } catch (_) {}
}
