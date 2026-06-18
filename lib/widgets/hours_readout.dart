import 'package:flutter/material.dart';
import '../theme/log_palette.dart';
import '../theme/log_type.dart';

class HoursReadout extends StatelessWidget {
  final double hours;
  final String caption;
  final double size;
  final Color? color;

  const HoursReadout({
    super.key,
    required this.hours,
    this.caption = 'total hours',
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('HRS', style: LogType.label(color: LogPalette.inkFaint)),
        const SizedBox(height: 3),
        Text(hours.toStringAsFixed(1),
            style: LogType.hours(size, color: color ?? LogPalette.ink)),
        const SizedBox(height: 3),
        Text(caption,
            style: LogType.caption(color: LogPalette.inkSoft)),
      ],
    );
  }
}

class HoursReadoutMini extends StatelessWidget {
  final double hours;
  final String caption;

  const HoursReadoutMini({
    super.key,
    required this.hours,
    this.caption = 'hrs',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(hours.toStringAsFixed(1),
            style: LogType.hours(26, color: LogPalette.ink)),
        Text(caption, style: LogType.caption()),
      ],
    );
  }
}
