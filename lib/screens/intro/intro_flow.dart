import 'package:flutter/material.dart';
import '../../theme/log_palette.dart';
import '../../theme/log_type.dart';
import '../../widgets/stamp_button.dart';

class _Page {
  final IconData icon;
  final String tag;
  final String title;
  final String body;
  const _Page(this.icon, this.tag, this.title, this.body);
}

class IntroFlow extends StatefulWidget {
  final VoidCallback onDone;
  const IntroFlow({super.key, required this.onDone});

  @override
  State<IntroFlow> createState() => _IntroFlowState();
}

class _IntroFlowState extends State<IntroFlow> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _Page(Icons.edit_note_rounded, 'LOG ENTRY', 'Log a flight in one form',
        'Record date, aircraft, route and every column — PIC, dual, solo, night, cross-country, instrument and landings — in a single entry.'),
    _Page(Icons.functions_rounded, 'TOTALS', 'Totals add themselves up',
        'Every category is summed automatically across all your flights. No more adding columns by hand before a checkride.'),
    _Page(Icons.event_available_rounded, 'CURRENCY', 'Stay legal to carry passengers',
        'See day and night passenger currency at a glance — three take-offs and landings in the last 90 days, tracked for you.'),
    _Page(Icons.notifications_active_rounded, 'REMINDERS', 'Never let a date lapse',
        'Track your medical, flight review and certificate expiries and get reminded before they run out.'),
  ];

  bool get _last => _index == _pages.length - 1;

  void _next() {
    if (_last) {
      widget.onDone();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LogPalette.documentWash),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  child: AnimatedOpacity(
                    opacity: _last ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: LinkButton(
                      label: 'Skip',
                      onPressed: _last ? null : widget.onDone,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              color: LogPalette.navyWash,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: LogPalette.navy, width: 1.4),
                            ),
                            child: Icon(p.icon,
                                size: 58, color: LogPalette.navy),
                          ),
                          const SizedBox(height: 32),
                          Text(p.tag,
                              style: LogType.label(color: LogPalette.gold)),
                          const SizedBox(height: 10),
                          Text(p.title,
                              style: LogType.title(),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 14),
                          Text(p.body,
                              style: LogType.body(),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? LogPalette.navy : LogPalette.rule,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(34, 24, 34, 28),
                child: StampButton(
                  label: _last ? 'Open my logbook' : 'Next',
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
