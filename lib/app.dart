import 'package:flutter/material.dart';

import 'domain/logbook_repository.dart';
import 'screens/boot_gate_screen.dart';
import 'state/logbook_scope.dart';
import 'theme/logbook_theme.dart';

class PilotLogApp extends StatelessWidget {
  final LogbookRepository repo;
  const PilotLogApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return LogbookScope(
      repo: repo,
      child: MaterialApp(
        title: 'Aviator Pilot Logbook',
        debugShowCheckedModeBanner: false,
        theme: LogbookTheme.build(),
        home: const BootGateScreen(),
      ),
    );
  }
}
