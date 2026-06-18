import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/log_models.dart';
import '../../domain/logbook_repository.dart';
import '../../theme/log_palette.dart';
import '../../theme/log_type.dart';
import '../../widgets/currency_meter.dart';
import '../../widgets/document_card.dart';

class CurrencyBoardView extends StatelessWidget {
  final LogbookRepository repo;
  const CurrencyBoardView({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final board = repo.currencyBoard();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        DocumentCard(
          crest: true,
          child: Row(
            children: [
              const Icon(Icons.verified_rounded,
                  size: 26, color: LogPalette.navy),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Passenger-carrying currency is based on take-offs and landings logged in the last 90 days, counted from your entries.',
                  style: LogType.body(color: LogPalette.ink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...board.map(_currencyCard),
        const SizedBox(height: 8),
        Text(
          'These indicators summarise the common 90-day passenger recency rule. Always confirm against current regulations and your own records.',
          style: LogType.caption(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _currencyCard(CurrencyStatus s) {
    final color = s.current ? LogPalette.valid : LogPalette.caution;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DocumentCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  s.rule.nightWindow
                      ? Icons.nightlight_round
                      : Icons.wb_sunny_rounded,
                  size: 18,
                  color: LogPalette.navy,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.rule.label, style: LogType.heading()),
                ),
                StatusPill(
                  text: s.current ? 'CURRENT' : 'LAPSED',
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(s.rule.detail, style: LogType.body()),
            const SizedBox(height: 16),
            CurrencyMeter(
              logged: s.landingsLogged,
              required: s.rule.landingsRequired,
              current: s.current,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(
                    s.current
                        ? Icons.event_available_rounded
                        : Icons.event_busy_rounded,
                    size: 18,
                    color: color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.current && s.validUntil != null
                          ? 'Current through ${DateFormat('d MMM yyyy').format(s.validUntil!)}'
                          : '${s.remaining} more qualifying landing(s) to regain currency',
                      style: LogType.bodyStrong(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
