import 'package:flutter/material.dart';
import '../services/log_repository.dart';
import '../models/log_entry.dart';
import '../ui/tg_style.dart';

enum ArchiveViewMode { list, calendar, gallery }

class TabProfileScreen extends StatefulWidget {
  final LogRepository logRepository;

  const TabProfileScreen({
    super.key,
    required this.logRepository,
  });

  @override
  State<TabProfileScreen> createState() => _TabProfileScreenState();
}

class _TabProfileScreenState extends State<TabProfileScreen> {
  int _topSegment = 0; // 0=Archive, 1=Routine
  ArchiveViewMode _archiveMode = ArchiveViewMode.list;

  List<LogEntry> _logs = [];
  bool _loading = true;

  final List<_RoutineItem> _routine = [
    _RoutineItem(title: '🏃‍♀️ Run at the park', isDone: false, lat: 37.4982, lng: 127.0268),
    _RoutineItem(title: '☕️ Grab coffee', isDone: false, lat: 37.4976, lng: 127.0261),
    _RoutineItem(title: '📚 Library', isDone: true, lat: 37.4992, lng: 127.0279),
  ];

  final String _profileEmoji = "🍒";
  int _followers = 128;
  int _following = 203;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await widget.logRepository.getLogs();
    setState(() {
      _logs = logs.toList();
      _logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TG.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHeader(
                emoji: _profileEmoji,
                followers: _followers,
                following: _following,
                onTapFollowers: () => _showSimpleList(context, title: "Followers", count: _followers),
                onTapFollowing: () => _showSimpleList(context, title: "Following", count: _following),
              ),
              const SizedBox(height: 14),

              _SegmentedPill(
                left: "Archive",
                right: "Routine",
                value: _topSegment,
                onChanged: (v) => setState(() => _topSegment = v),
              ),
              const SizedBox(height: 14),

              Expanded(
                child: _topSegment == 0
                    ? _ArchiveSection(
                        loading: _loading,
                        logs: _logs,
                        mode: _archiveMode,
                        onModeChanged: (m) => setState(() => _archiveMode = m),
                        onTapLog: (log) {
                          Navigator.pushNamed(context, '/detail', arguments: log);
                        },
                      )
                    : _RoutineSection(
                        routine: _routine,
                        onToggleDone: (id) {
                          setState(() {
                            final idx = _routine.indexWhere((e) => e.id == id);
                            if (idx >= 0) {
                              _routine[idx] = _routine[idx].copyWith(isDone: !_routine[idx].isDone);
                            }
                          });
                        },
                        onAddRoutine: () async {
                          final item = await _showAddRoutineSheet(context);
                          if (item != null) {
                            setState(() => _routine.insert(0, item));
                          }
                        },
                        onPushToMap: (item) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Added to map: ${item.title}")),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSimpleList(BuildContext context, {required String title, required int count}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: TG.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text("Stub list ($count)", style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<_RoutineItem?> _showAddRoutineSheet(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();

    return showModalBottomSheet<_RoutineItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: TG.softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add routine", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(hintText: "e.g. 🥯 Bagel place to visit"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "lat (optional)"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: lngCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "lng (optional)"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TG.ink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) return;

                      final lat = double.tryParse(latCtrl.text.trim());
                      final lng = double.tryParse(lngCtrl.text.trim());

                      Navigator.pop(
                        context,
                        _RoutineItem(
                          title: title,
                          isDone: false,
                          lat: lat,
                          lng: lng,
                        ),
                      );
                    },
                    child: const Text("Add"),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* -------------------------- PROFILE HEADER -------------------------- */

class _ProfileHeader extends StatelessWidget {
  final String emoji;
  final int followers;
  final int following;
  final VoidCallback onTapFollowers;
  final VoidCallback onTapFollowing;

  const _ProfileHeader({
    required this.emoji,
    required this.followers,
    required this.following,
    required this.onTapFollowers,
    required this.onTapFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: TG.softShadow,
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Taeyeon", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _CountPill(label: "following", value: following, onTap: onTapFollowing),
                  const SizedBox(width: 10),
                  _CountPill(label: "followers", value: followers, onTap: onTapFollowers),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onTap;

  const _CountPill({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: TG.softShadow,
        ),
        child: Row(
          children: [
            Text("$value", style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/* -------------------------- SEGMENTED PILL -------------------------- */

class _SegmentedPill extends StatelessWidget {
  final String left;
  final String right;
  final int value;
  final ValueChanged<int> onChanged;

  const _SegmentedPill({
    required this.left,
    required this.right,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: TG.y2kGradient,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: TG.softShadow,
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _SegBtn(
              text: left,
              selected: value == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SegBtn(
              text: right,
              selected: value == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SegBtn({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.92) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: selected ? Border.all(color: Colors.black.withOpacity(0.06)) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? TG.ink : Colors.black54,
          ),
        ),
      ),
    );
  }
}

/* -------------------------- ARCHIVE SECTION ------------------------- */

class _ArchiveSection extends StatelessWidget {
  final bool loading;
  final List<LogEntry> logs;
  final ArchiveViewMode mode;
  final ValueChanged<ArchiveViewMode> onModeChanged;
  final ValueChanged<LogEntry> onTapLog;

  const _ArchiveSection({
    required this.loading,
    required this.logs,
    required this.mode,
    required this.onModeChanged,
    required this.onTapLog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _ModeIcon(
              icon: Icons.list,
              selected: mode == ArchiveViewMode.list,
              onTap: () => onModeChanged(ArchiveViewMode.list),
            ),
            const SizedBox(width: 8),
            _ModeIcon(
              icon: Icons.calendar_month,
              selected: mode == ArchiveViewMode.calendar,
              onTap: () => onModeChanged(ArchiveViewMode.calendar),
            ),
            const SizedBox(width: 8),
            _ModeIcon(
              icon: Icons.grid_view,
              selected: mode == ArchiveViewMode.gallery,
              onTap: () => onModeChanged(ArchiveViewMode.gallery),
            ),
            const Spacer(),
            Text("${logs.length} records", style: const TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : logs.isEmpty
                  ? const Center(child: Text("No records yet."))
                  : switch (mode) {
                      ArchiveViewMode.list => _ArchiveList(logs: logs, onTapLog: onTapLog),
                      ArchiveViewMode.calendar => _ArchiveCalendar(logs: logs),
                      ArchiveViewMode.gallery => _ArchiveGallery(logs: logs, onTapLog: onTapLog),
                    },
        ),
      ],
    );
  }
}

class _ModeIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeIcon({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: selected ? TG.softShadow : null,
        ),
        child: Icon(icon, size: 20, color: selected ? TG.ink : Colors.black54),
      ),
    );
  }
}

class _ArchiveList extends StatelessWidget {
  final List<LogEntry> logs;
  final ValueChanged<LogEntry> onTapLog;

  const _ArchiveList({required this.logs, required this.onTapLog});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: logs.length,
      itemBuilder: (context, i) {
        final log = logs[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: TG.softShadow,
          ),
          child: ListTile(
            onTap: () => onTapLog(log),
            title: Text(
              log.note.isEmpty ? "(No note)" : log.note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text("${log.timestamp}", style: const TextStyle(color: Colors.black54)),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

class _ArchiveGallery extends StatelessWidget {
  final List<LogEntry> logs;
  final ValueChanged<LogEntry> onTapLog;

  const _ArchiveGallery({required this.logs, required this.onTapLog});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: logs.length,
      itemBuilder: (context, i) {
        final log = logs[i];
        return GestureDetector(
          onTap: () => onTapLog(log),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
              boxShadow: TG.softShadow,
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.note.isEmpty ? "(No note)" : log.note,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  "${log.timestamp}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* -------------------------- CALENDAR ------------------------ */

class _ArchiveCalendar extends StatefulWidget {
  final List<LogEntry> logs;
  const _ArchiveCalendar({required this.logs});

  @override
  State<_ArchiveCalendar> createState() => _ArchiveCalendarState();
}

class _ArchiveCalendarState extends State<_ArchiveCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final byDay = <DateTime, int>{};
    for (final l in widget.logs) {
      final d = DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day);
      byDay[d] = (byDay[d] ?? 0) + 1;
    }

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final firstWeekdayIndex = _month.weekday - 1; // Mon=0..Sun=6
    final leadingEmpty = firstWeekdayIndex;
    final totalCells = leadingEmpty + daysInMonth;

    final title = "${_month.year}.${_month.month.toString().padLeft(2, '0')}";

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1, 1)),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Center(
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1, 1)),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _W("M"), _W("T"), _W("W"), _W("T"), _W("F"), _W("S"), _W("S"),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: totalCells,
            itemBuilder: (_, index) {
              if (index < leadingEmpty) return const SizedBox();
              final day = (index - leadingEmpty) + 1;
              final d = DateTime(_month.year, _month.month, day);
              final cnt = byDay[d] ?? 0;
              return _CalCell(day: day, count: cnt);
            },
          ),
        ),
      ],
    );
  }
}

class _W extends StatelessWidget {
  final String s;
  const _W(this.s);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Center(
        child: Text(s, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _CalCell extends StatelessWidget {
  final int day;
  final int count;
  const _CalCell({required this.day, required this.count});

  @override
  Widget build(BuildContext context) {
    final has = count > 0;
    return Container(
      decoration: BoxDecoration(
        color: has ? Colors.white : Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: has ? TG.softShadow : null,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$day", style: TextStyle(fontWeight: FontWeight.w900, color: has ? TG.ink : Colors.black54)),
          if (has) ...[
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: TG.ink, borderRadius: BorderRadius.circular(999)),
              child: Text("$count",
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
            ),
          ],
        ],
      ),
    );
  }
}

/* -------------------------- ROUTINE SECTION ------------------------- */

class _RoutineSection extends StatelessWidget {
  final List<_RoutineItem> routine;
  final ValueChanged<String> onToggleDone;
  final VoidCallback onAddRoutine;
  final ValueChanged<_RoutineItem> onPushToMap;

  const _RoutineSection({
    required this.routine,
    required this.onToggleDone,
    required this.onAddRoutine,
    required this.onPushToMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text("Routine", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(width: 8),
            Text("${routine.length}", style: const TextStyle(color: Colors.black54)),
            const Spacer(),
            GestureDetector(
              onTap: onAddRoutine,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  boxShadow: TG.softShadow,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 6),
                    Text("Add", style: TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: routine.length,
            itemBuilder: (context, i) {
              final item = routine[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  boxShadow: TG.softShadow,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => onToggleDone(item.id),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: item.isDone ? TG.ink : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black.withOpacity(0.2)),
                        ),
                        child: item.isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: item.isDone ? Colors.black38 : TG.ink,
                          decoration: item.isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onPushToMap(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: TG.ink, borderRadius: BorderRadius.circular(999)),
                        child: const Text("Map", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/* -------------------------- ROUTINE MODEL --------------------------- */

class _RoutineItem {
  final String id;
  final String title;
  final bool isDone;
  final double? lat;
  final double? lng;

  _RoutineItem({
    String? id,
    required this.title,
    required this.isDone,
    required this.lat,
    required this.lng,
  }) : id = id ?? UniqueKey().toString();

  _RoutineItem copyWith({String? title, bool? isDone, double? lat, double? lng}) {
    return _RoutineItem(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
