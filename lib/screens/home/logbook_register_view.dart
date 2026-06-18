import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/log_models.dart';
import '../../domain/logbook_repository.dart';
import '../../theme/log_palette.dart';
import '../../theme/log_type.dart';
import '../../widgets/document_card.dart';

class LogbookRegisterView extends StatelessWidget {
  final LogbookRepository repo;
  final VoidCallback onAdd;

  const LogbookRegisterView({
    super.key,
    required this.repo,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final entries = repo.entries;
    if (entries.isEmpty) {
      return _EmptyState(onAdd: onAdd);
    }

    final totals = repo.totals();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: [
        DocumentCard(
          crest: true,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              _summaryCell('FLIGHTS', '${totals.flights}'),
              _vrule(),
              _summaryCell('TOTAL', totals.total.toStringAsFixed(1)),
              _vrule(),
              _summaryCell('PIC', totals.pic.toStringAsFixed(1)),
              _vrule(),
              _summaryCell('LDG', '${totals.totalLandings}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('ENTRIES', style: LogType.label(color: LogPalette.inkSoft)),
            const Spacer(),
            Text('newest first', style: LogType.caption()),
          ],
        ),
        const SizedBox(height: 10),
        ...entries.map((e) => _EntryRow(
              entry: e,
              onDelete: () => _confirmDelete(context, e),
            )),
        const SizedBox(height: 8),
        Text(
          'Reference notes summarise common FAR/ACS principles and do not replace official regulations or instructor guidance.',
          style: LogType.caption(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _summaryCell(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value, style: LogType.hours(20)),
            const SizedBox(height: 3),
            Text(label, style: LogType.caption()),
          ],
        ),
      );

  Widget _vrule() => Container(
        width: 1,
        height: 32,
        color: LogPalette.rule,
      );

  Future<void> _confirmDelete(BuildContext context, LogEntry e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: LogPalette.sheet,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text('Remove entry?', style: LogType.heading()),
        content: Text(
          'This flight (${e.route} · ${e.totalTime.toStringAsFixed(1)} hrs) will be removed from your totals.',
          style: LogType.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LogPalette.seal),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) await repo.removeEntry(e.id);
  }
}

class _EntryRow extends StatelessWidget {
  final LogEntry entry;
  final VoidCallback onDelete;
  const _EntryRow({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isNight = entry.condition == ConditionKind.night;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: LogPalette.sheet,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LogPalette.rule),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(DateFormat('dd').format(entry.flownOn),
                    style: LogType.hours(20)),
                Text(DateFormat('MMM').format(entry.flownOn).toUpperCase(),
                    style: LogType.caption()),
              ],
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 40, color: LogPalette.rule),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(entry.category.glyph,
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          entry.tail.isEmpty ? entry.category.label : entry.tail,
                          style: LogType.bodyStrong(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isNight) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.nightlight_round,
                            size: 13, color: LogPalette.navy),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(entry.route, style: LogType.caption()),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (entry.pic > 0) _tag('PIC ${_h(entry.pic)}'),
                      if (entry.dualReceived > 0)
                        _tag('DUAL ${_h(entry.dualReceived)}'),
                      if (entry.crossCountry > 0)
                        _tag('XC ${_h(entry.crossCountry)}'),
                      if (entry.instrument > 0)
                        _tag('IFR ${_h(entry.instrument)}'),
                      _tag('LDG ${entry.totalLandings}'),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_h(entry.totalTime),
                    style: LogType.hours(19, color: LogPalette.navy)),
                Text('hrs', style: LogType.caption()),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: LogPalette.inkFaint,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _h(double v) => v.toStringAsFixed(1);

  Widget _tag(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: LogPalette.paperDeep,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: LogType.monoLabel(color: LogPalette.inkSoft)),
      );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: LogPalette.navyWash,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: LogPalette.navy, width: 1.4),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  size: 46, color: LogPalette.navy),
            ),
            const SizedBox(height: 22),
            Text('Your logbook is empty', style: LogType.title()),
            const SizedBox(height: 10),
            Text(
              'Add your first flight. Totals, currency and reminders all build from the entries you sign here.',
              style: LogType.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: LogPalette.navy,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text('Log a flight',
                  style: LogType.heading(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
