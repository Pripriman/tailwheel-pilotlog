import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/log_models.dart';
import '../../domain/logbook_repository.dart';
import '../../domain/reference_data.dart';
import '../../runtime/signal_relay.dart';
import '../../theme/log_palette.dart';
import '../../theme/log_type.dart';
import '../../widgets/currency_meter.dart';
import '../../widgets/document_card.dart';
import '../../widgets/stamp_button.dart';

class RemindersView extends StatelessWidget {
  final LogbookRepository repo;
  const RemindersView({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final certs = repo.certs;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        DocumentCard(
          crest: true,
          child: Row(
            children: [
              const Icon(Icons.alarm_rounded,
                  size: 26, color: LogPalette.navy),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Track expiry dates for your medical, flight review and certificates. We will remind you before each one lapses.',
                  style: LogType.body(color: LogPalette.ink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (certs.isEmpty)
          DocumentCard(
            child: Column(
              children: [
                const Icon(Icons.event_note_rounded,
                    size: 40, color: LogPalette.inkFaint),
                const SizedBox(height: 12),
                Text('No dates tracked yet', style: LogType.heading()),
                const SizedBox(height: 8),
                Text(
                  'Add your medical, flight review or a certificate expiry to start getting reminders.',
                  style: LogType.body(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...certs.map((c) => _certCard(context, c)),
        const SizedBox(height: 16),
        StampButton(
          label: 'Add a date to track',
          icon: Icons.add_rounded,
          onPressed: () => _openEditor(context, null),
        ),
      ],
    );
  }

  Widget _certCard(BuildContext context, CertItem c) {
    final days = c.daysRemaining(DateTime.now());
    final (color, status) = _status(days);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DocumentCard(
        onTap: () => _openEditor(context, c),
        child: Row(
          children: [
            Text(c.kind.glyph, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.label.isEmpty ? c.kind.label : c.label,
                      style: LogType.bodyStrong()),
                  const SizedBox(height: 3),
                  Text(
                    'Expires ${DateFormat('d MMM yyyy').format(c.expiresOn)}',
                    style: LogType.caption(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusPill(text: status, color: color),
                const SizedBox(height: 6),
                Text(
                  days < 0
                      ? '${-days}d ago'
                      : (days == 0 ? 'today' : 'in ${days}d'),
                  style: LogType.monoLabel(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (Color, String) _status(int days) {
    if (days < 0) return (LogPalette.expired, 'EXPIRED');
    if (days <= 30) return (LogPalette.caution, 'DUE SOON');
    return (LogPalette.valid, 'VALID');
  }

  Future<void> _openEditor(BuildContext context, CertItem? existing) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LogPalette.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _CertEditor(repo: repo, existing: existing),
    );
  }
}

class _CertEditor extends StatefulWidget {
  final LogbookRepository repo;
  final CertItem? existing;
  const _CertEditor({required this.repo, this.existing});

  @override
  State<_CertEditor> createState() => _CertEditorState();
}

class _CertEditorState extends State<_CertEditor> {
  late String _kindId;
  late DateTime _expires;
  late final TextEditingController _label;

  @override
  void initState() {
    super.initState();
    _kindId = widget.existing?.kindId ?? ReferenceData.certKinds.first.id;
    _expires = widget.existing?.expiresOn ??
        DateTime.now().add(const Duration(days: 365));
    _label = TextEditingController(text: widget.existing?.label ?? '');
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expires,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 15),
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
    if (picked != null) setState(() => _expires = picked);
  }

  Future<void> _save() async {
    await widget.repo.upsertCert(
      id: widget.existing?.id,
      kindId: _kindId,
      expiresOn: DateTime(_expires.year, _expires.month, _expires.day),
      label: _label.text.trim(),
    );
    await SignalRelay.askPermission();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (widget.existing != null) {
      await widget.repo.removeCert(widget.existing!.id);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final kind = ReferenceData.certKindById(_kindId);
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
              Text(widget.existing == null ? 'Track a date' : 'Edit date',
                  style: LogType.title()),
              const SizedBox(height: 18),
              Text('Type', style: LogType.label()),
              const SizedBox(height: 10),
              Column(
                children: ReferenceData.certKinds.map((k) {
                  final sel = k.id == _kindId;
                  return GestureDetector(
                    onTap: () => setState(() => _kindId = k.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: sel ? LogPalette.navyWash : LogPalette.paper,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: sel ? LogPalette.navy : LogPalette.rule,
                          width: sel ? 1.4 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(k.glyph, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(k.label, style: LogType.bodyStrong()),
                                Text(k.hint, style: LogType.caption()),
                              ],
                            ),
                          ),
                          if (sel)
                            const Icon(Icons.check_circle_rounded,
                                color: LogPalette.navy, size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text('Label (optional)', style: LogType.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _label,
                decoration: InputDecoration(hintText: kind.label),
              ),
              const SizedBox(height: 16),
              Text('Expiry date', style: LogType.label()),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    color: LogPalette.paper,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: LogPalette.rule),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded,
                          size: 17, color: LogPalette.navy),
                      const SizedBox(width: 8),
                      Text(DateFormat('d MMM yyyy').format(_expires),
                          style: LogType.bodyStrong()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              StampButton(
                label: 'Save reminder',
                icon: Icons.notifications_active_rounded,
                onPressed: _save,
              ),
              if (widget.existing != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: LogPalette.seal),
                    label: Text('Remove',
                        style: LogType.label(color: LogPalette.seal)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
