import 'package:flutter/material.dart';

import '../../runtime/backend_link.dart';
import '../../runtime/signal_relay.dart';
import '../../state/logbook_scope.dart';
import '../../theme/log_palette.dart';
import '../../theme/log_type.dart';
import '../access/access_screen.dart';
import 'currency_board_view.dart';
import 'endorsement_book_view.dart';
import 'logbook_register_view.dart';
import 'new_entry_sheet.dart';
import 'reminders_view.dart';
import 'totals_board_view.dart';

class LogbookDeckShell extends StatefulWidget {
  const LogbookDeckShell({super.key});

  @override
  State<LogbookDeckShell> createState() => _LogbookDeckShellState();
}

class _LogbookDeckShellState extends State<LogbookDeckShell> {
  int _tab = 0;

  static const _titles = [
    'Flight log',
    'Totals',
    'Currency',
    'Reminders',
    'Ratings',
  ];

  Future<void> _addEntry() async {
    final repo = LogbookScope.read(context);
    final created = await openNewEntrySheet(context, repo);
    if (created != null && mounted) {
      setState(() => _tab = 0);
    }
  }

  void _openAccount() {
    final signedIn = BackendLink.signedIn;
    showModalBottomSheet(
      context: context,
      backgroundColor: LogPalette.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account', style: LogType.heading()),
                const SizedBox(height: 6),
                Text(
                  signedIn
                      ? (BackendLink.currentUser?.email ?? 'Signed in')
                      : 'You are using the logbook as a guest.',
                  style: LogType.body(),
                ),
                const SizedBox(height: 16),
                if (signedIn)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded,
                        color: LogPalette.seal),
                    title: Text('Sign out',
                        style: LogType.bodyStrong(color: LogPalette.seal)),
                    onTap: () async {
                      await SignalRelay.unbindUser();
                      await BackendLink.signOut();
                      if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                      if (mounted) setState(() {});
                    },
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.login_rounded,
                        color: LogPalette.navy),
                    title: Text('Sign in or create account',
                        style: LogType.bodyStrong(color: LogPalette.navy)),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AccessScreen(
                            onDone: () {
                              Navigator.of(context).maybePop();
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = LogbookScope.of(context);

    Widget body;
    switch (_tab) {
      case 1:
        body = TotalsBoardView(repo: repo);
        break;
      case 2:
        body = CurrencyBoardView(repo: repo);
        break;
      case 3:
        body = RemindersView(repo: repo);
        break;
      case 4:
        body = EndorsementBookView(repo: repo);
        break;
      default:
        body = LogbookRegisterView(repo: repo, onAdd: _addEntry);
    }

    return Scaffold(
      backgroundColor: LogPalette.paper,
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PILOT LOGBOOK',
                style: LogType.label(color: LogPalette.gold)),
            Text(_titles[_tab], style: LogType.title()),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            color: LogPalette.ink,
            onPressed: _openAccount,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: body,
      floatingActionButton: (_tab == 0 || _tab == 1)
          ? FloatingActionButton.extended(
              backgroundColor: LogPalette.navy,
              foregroundColor: Colors.white,
              onPressed: _addEntry,
              icon: const Icon(Icons.add_rounded),
              label: Text('Log flight',
                  style: LogType.label(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: _DeckBar(
        index: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _DeckBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _DeckBar({required this.index, required this.onChanged});

  static const _items = [
    (Icons.menu_book_rounded, 'Log'),
    (Icons.bar_chart_rounded, 'Totals'),
    (Icons.verified_rounded, 'Currency'),
    (Icons.alarm_rounded, 'Reminders'),
    (Icons.workspace_premium_rounded, 'Ratings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LogPalette.sheet,
        border: Border(
          top: BorderSide(color: LogPalette.rule),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == index;
              final item = _items[i];
              return Expanded(
                child: InkResponse(
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.$1,
                        size: 22,
                        color: selected
                            ? LogPalette.navy
                            : LogPalette.inkFaint,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        style: LogType.caption(
                          color: selected
                              ? LogPalette.navy
                              : LogPalette.inkFaint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
