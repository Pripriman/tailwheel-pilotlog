import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../domain/log_models.dart';
import '../../domain/logbook_repository.dart';
import '../../theme/log_palette.dart';
import '../../theme/log_type.dart';
import '../../widgets/document_card.dart';
import '../../widgets/stamp_button.dart';
import 'ratings_reference.dart';

class EndorsementBookView extends StatelessWidget {
  final LogbookRepository repo;
  const EndorsementBookView({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final endorsements = repo.endorsements;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        DocumentCard(
          crest: true,
          onTap: () => _showSummary(context),
          child: Row(
            children: [
              const Icon(Icons.summarize_rounded,
                  size: 26, color: LogPalette.navy),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Export totals summary',
                        style: LogType.bodyStrong()),
                    const SizedBox(height: 2),
                    Text('A plain-text recap for an examiner or your records.',
                        style: LogType.caption()),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: LogPalette.inkFaint),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text('ENDORSEMENTS',
                style: LogType.label(color: LogPalette.inkSoft)),
            const Spacer(),
            LinkButton(
              label: 'Add',
              icon: Icons.add_rounded,
              onPressed: () => _openEditor(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (endorsements.isEmpty)
          DocumentCard(
            child: Column(
              children: [
                const Icon(Icons.draw_rounded,
                    size: 38, color: LogPalette.inkFaint),
                const SizedBox(height: 12),
                Text('No endorsements yet', style: LogType.heading()),
                const SizedBox(height: 8),
                Text(
                  'Record instructor endorsements — solo, cross-country, complex, high-performance and more.',
                  style: LogType.body(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...endorsements.map((e) => _endorsementCard(context, e)),
        const SizedBox(height: 22),
        Text('RATINGS REFERENCE',
            style: LogType.label(color: LogPalette.inkSoft)),
        const SizedBox(height: 10),
        ...ratingDefsCards(),
      ],
    );
  }

  Widget _endorsementCard(BuildContext context, Endorsement e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DocumentCard(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: LogPalette.goldWash,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: LogPalette.goldSoft),
              ),
              child: const Icon(Icons.verified_user_rounded,
                  color: LogPalette.gold, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, style: LogType.bodyStrong()),
                  const SizedBox(height: 3),
                  Text(
                    '${e.instructor.isEmpty ? 'Instructor' : e.instructor} · ${DateFormat('d MMM yyyy').format(e.grantedOn)}',
                    style: LogType.caption(),
                  ),
                  if (e.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(e.note, style: LogType.body()),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              color: LogPalette.inkFaint,
              onPressed: () => repo.removeEndorsement(e.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showSummary(BuildContext context) {
    final text = repo.exportSummary();
    showModalBottomSheet(
      context: context,
      backgroundColor: LogPalette.sheet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Totals summary', style: LogType.title()),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LogPalette.paper,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: LogPalette.rule),
                ),
                child: Text(text, style: LogType.monoLabel()),
              ),
              const SizedBox(height: 16),
              StampButton(
                label: 'Copy to clipboard',
                icon: Icons.copy_rounded,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (sheetCtx.mounted) {
                    Navigator.pop(sheetCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Summary copied.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LogPalette.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _EndorsementEditor(repo: repo),
    );
  }
}

class _EndorsementEditor extends StatefulWidget {
  final LogbookRepository repo;
  const _EndorsementEditor({required this.repo});

  @override
  State<_EndorsementEditor> createState() => _EndorsementEditorState();
}

class _EndorsementEditorState extends State<_EndorsementEditor> {
  final _title = TextEditingController();
  final _instructor = TextEditingController();
  final _note = TextEditingController();
  DateTime _granted = DateTime.now();

  @override
  void dispose() {
    _title.dispose();
    _instructor.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _granted,
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
    if (picked != null) setState(() => _granted = picked);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the endorsement title.')),
      );
      return;
    }
    await widget.repo.addEndorsement(
      title: title,
      instructor: _instructor.text.trim(),
      grantedOn: DateTime(_granted.year, _granted.month, _granted.day),
      note: _note.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
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
              Text('New endorsement', style: LogType.title()),
              const SizedBox(height: 18),
              Text('Title', style: LogType.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _title,
                decoration: const InputDecoration(
                    hintText: 'Solo cross-country endorsement'),
              ),
              const SizedBox(height: 16),
              Text('Instructor', style: LogType.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _instructor,
                decoration:
                    const InputDecoration(hintText: 'CFI name / certificate'),
              ),
              const SizedBox(height: 16),
              Text('Date', style: LogType.label()),
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
                      Text(DateFormat('d MMM yyyy').format(_granted),
                          style: LogType.bodyStrong()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Note (optional)', style: LogType.label()),
              const SizedBox(height: 8),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: 'Reference, limitations, remarks'),
              ),
              const SizedBox(height: 22),
              StampButton(
                label: 'Save endorsement',
                icon: Icons.verified_user_rounded,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
