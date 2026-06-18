import 'package:flutter/material.dart';
import '../theme/log_palette.dart';
import '../theme/log_type.dart';

class CurrencyMeter extends StatelessWidget {
  final int logged;
  final int required;
  final bool current;

  const CurrencyMeter({
    super.key,
    required this.logged,
    required this.required,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final color = current ? LogPalette.valid : LogPalette.caution;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(required, (i) {
            final filled = i < logged;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i == required - 1 ? 0 : 6),
                height: 10,
                decoration: BoxDecoration(
                  color: filled ? color : LogPalette.paperDeep,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: filled ? color : LogPalette.rule,
                    width: 1,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          current
              ? 'Requirement met'
              : '${required - logged} more landing(s) needed',
          style: LogType.caption(color: color),
        ),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const StatusPill({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text, style: LogType.label(color: color)),
    );
  }
}
