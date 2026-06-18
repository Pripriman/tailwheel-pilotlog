import 'package:flutter/material.dart';

import '../runtime/currency_gate.dart';
import '../runtime/trace_beacon.dart';
import '../theme/log_palette.dart';
import '../theme/log_type.dart';
import '../widgets/wings_ring.dart';
import 'bad_connection_screen.dart';
import 'content/logbook_deck_view.dart';
import 'native_root.dart';

class BootGateScreen extends StatefulWidget {
  const BootGateScreen({super.key});

  @override
  State<BootGateScreen> createState() => _BootGateScreenState();
}

class _BootGateScreenState extends State<BootGateScreen>
    with SingleTickerProviderStateMixin {
  late Future<GateResult> _future;
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _future = CurrencyGate.resolve();
  }

  void _retry() {
    setState(() {
      _future = CurrencyGate.resolve();
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GateResult>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _splash();
        }
        final result = snap.data ?? const GateResult(GateOutcome.native);
        switch (result.outcome) {
          case GateOutcome.badConnection:
            return BadConnectionScreen(onRetry: _retry);
          case GateOutcome.content:
            TraceBeacon.contentOpen();
            return LogbookDeckView(endpoint: result.endpoint!);
          case GateOutcome.native:
            return const NativeRoot();
        }
      },
    );
  }

  Widget _splash() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LogPalette.documentWash),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _spin,
                child: WingsRing(
                  size: 92,
                  progress: 0.72,
                  stroke: 8,
                  child: const Text('✈', style: TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(height: 24),
              Text('Opening the logbook…',
                  style: LogType.heading(color: LogPalette.navy)),
            ],
          ),
        ),
      ),
    );
  }
}
