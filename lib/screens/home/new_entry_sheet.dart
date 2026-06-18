import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../domain/log_models.dart';
import '../../domain/logbook_repository.dart';
import '../../domain/reference_data.dart';
import '../../theme/log_palette.dart';
import '../../theme/log_type.dart';
import '../../widgets/stamp_button.dart';

Future<LogEntry?> openNewEntrySheet(
  BuildContext context,
  LogbookRepository repo,
) {
  return showModalBottomSheet<LogEntry>(
    context: context,
    isScrollControlled: true,
    backgroundColor: LogPalette.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _NewEntrySheet(repo: repo),
  );
}

class _NewEntrySheet extends StatefulWidget {
  final LogbookRepository repo;
  const _NewEntrySheet({required this.repo});

  @override
  State<_NewEntrySheet> createState() => _NewEntrySheetState();
}

class _NewEntrySheetState extends State<_NewEntrySheet> {
  DateTime _flownOn = DateTime.now();
  String _categoryId = ReferenceData.categories.first.id;
  ConditionKind _condition = ConditionKind.day;

  final _tail = TextEditingController();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _total = TextEditingController();
  final _pic = TextEditingController();
  final _dual = TextEditingController();
  final _solo = TextEditingController();
  final _xc = TextEditingController();
  final _night = TextEditingController();
  final _ifr = TextEditingController();
  int _dayLandings = 1;
  int _nightLandings = 0;
  bool _busy = false;

  @override
  void dispose() {
    _tail.dispose();
    _from.dispose();
    _to.dispose();
    _total.dispose();
    _pic.dispose();
    _dual.dispose();
    _solo.dispose();
    _xc.dispose();
    _night.dispose();
    _ifr.dispose();
    super.dispose();
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _flownOn,
      firstDate: DateTime(now.year - 30),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: LogPalette.navy,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _flownOn = picked);
  }

  Future<void> _save() async {
    final total = _num(_total);
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the total flight time.')),
      );
      return;
    }
    setState(() => _busy = true);
    final entry = await widget.repo.addEntry(
      flownOn: DateTime(_flownOn.year, _flownOn.month, _flownOn.day),
      categoryId: _categoryId,
      tail: _tail.text.trim().toUpperCase(),
      routeFrom: _from.text.trim().toUpperCase(),
      routeTo: _to.text.trim().toUpperCase(),
      totalTime: total,
      pic: _num(_pic),
      dualReceived: _num(_dual),
      solo: _num(_solo),
      crossCountry: _num(_xc),
      nightTime: _condition == ConditionKind.night
          ? (_num(_night) == 0 ? total : _num(_night))
          : _num(_night),
      instrument: _num(_ifr),
      condition: _condition,
      dayLandings: _dayLandings,
      nightLandings: _nightLandings,
    );
    if (mounted) Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LogPalette.rule,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('New flight entry', style: LogType.title()),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      'Date',
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 15),
                          decoration: _boxDeco(),
                          child: Row(
                            children: [
                              const Icon(Icons.event_rounded,
                                  size: 17, color: LogPalette.navy),
                              const SizedBox(width: 8),
                              Text(DateFormat('d MMM yyyy').format(_flownOn),
                                  style: LogType.bodyStrong()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Category', style: LogType.label()),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReferenceData.categories.map((c) {
                  final sel = c.id == _categoryId;
                  return GestureDetector(
                    onTap: () => setState(() => _categoryId = c.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel ? LogPalette.navyWash : LogPalette.paper,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: sel ? LogPalette.navy : LogPalette.rule,
                          width: sel ? 1.4 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(c.glyph,
                              style: const TextStyle(fontSize: 15)),
                          const SizedBox(width: 7),
                          Text(c.label,
                              style: LogType.bodyStrong(
                                  color: sel
                                      ? LogPalette.navy
                                      : LogPalette.ink)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _field(
                      'Aircraft',
                      TextField(
                        controller: _tail,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(hintText: 'N12345'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      'From',
                      TextField(
                        controller: _from,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(hintText: 'KSQL'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      'To',
                      TextField(
                        controller: _to,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(hintText: 'KPAO'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _conditionToggle(),
              const SizedBox(height: 16),
              Text('Hours', style: LogType.label()),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _hourField('Total', _total)),
                  const SizedBox(width: 10),
                  Expanded(child: _hourField('PIC', _pic)),
                  const SizedBox(width: 10),
                  Expanded(child: _hourField('Dual', _dual)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _hourField('Solo', _solo)),
                  const SizedBox(width: 10),
                  Expanded(child: _hourField('XC', _xc)),
                  const SizedBox(width: 10),
                  Expanded(child: _hourField('Night', _night)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _hourField('Instrument', _ifr)),
                  const SizedBox(width: 10),
                  const Spacer(),
                  const SizedBox(width: 10),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _stepper('Day landings', _dayLandings,
                        (v) => setState(() => _dayLandings = v)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _stepper('Night landings', _nightLandings,
                        (v) => setState(() => _nightLandings = v)),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              StampButton(
                label: 'Sign entry',
                icon: Icons.edit_rounded,
                busy: _busy,
                onPressed: _busy ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDeco() => BoxDecoration(
        color: LogPalette.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LogPalette.rule),
      );

  Widget _field(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: LogType.label()),
          const SizedBox(height: 8),
          child,
        ],
      );

  Widget _hourField(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: LogType.caption(color: LogPalette.inkSoft)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: LogType.hours(16),
          decoration: const InputDecoration(
            hintText: '0.0',
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          ),
        ),
      ],
    );
  }

  Widget _conditionToggle() {
    return Row(
      children: ConditionKind.values.map((k) {
        final sel = k == _condition;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _condition = k),
            child: Container(
              margin: EdgeInsets.only(
                  right: k == ConditionKind.values.last ? 0 : 10),
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? LogPalette.navy : LogPalette.paper,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: sel ? LogPalette.navy : LogPalette.rule,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    k == ConditionKind.night
                        ? Icons.nightlight_round
                        : Icons.wb_sunny_rounded,
                    size: 16,
                    color: sel ? LogPalette.goldSoft : LogPalette.inkSoft,
                  ),
                  const SizedBox(width: 8),
                  Text(k.label,
                      style: LogType.bodyStrong(
                          color: sel ? Colors.white : LogPalette.ink)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _stepper(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: LogType.label()),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: _boxDeco(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                color: LogPalette.inkSoft,
                onPressed:
                    value > 0 ? () => onChanged(value - 1) : null,
              ),
              Text('$value', style: LogType.hours(18)),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                color: LogPalette.navy,
                onPressed:
                    value < 99 ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
