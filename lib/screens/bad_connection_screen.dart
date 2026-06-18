import 'package:flutter/material.dart';
import '../theme/log_palette.dart';
import '../theme/log_type.dart';
import '../widgets/stamp_button.dart';

class BadConnectionScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const BadConnectionScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LogPalette.documentWash),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: LogPalette.sealWash,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: LogPalette.seal, width: 1.2),
                  ),
                  child: const Icon(Icons.cloud_off_rounded,
                      size: 36, color: LogPalette.seal),
                ),
                const SizedBox(height: 24),
                Text('No connection',
                    style: LogType.title(), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(
                  'We could not reach the logbook service. Check your network and try again.',
                  style: LogType.body(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                StampButton(
                  label: 'Retry',
                  icon: Icons.refresh_rounded,
                  expand: false,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
