import 'package:flutter/material.dart';
import '../services/log_repository.dart';
import '../models/log_entry.dart';

class TabProfileScreen extends StatefulWidget {
  final LogRepository logRepository;

  const TabProfileScreen({super.key, required this.logRepository});

  @override
  State<TabProfileScreen> createState() => _TabProfileScreenState();
}

class _TabProfileScreenState extends State<TabProfileScreen> {
  List<LogEntry> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs = await widget.logRepository.getLogs();
    setState(() {
      _logs = logs.reversed.toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _logs.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        title: const Text('내 아카이브'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lucy의 기록',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '총 $total개의 순간을 기록했어요.',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '최근 기록',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (_logs.isEmpty)
                    const Text(
                      '아직 기록이 없어요.',
                      style: TextStyle(fontSize: 13),
                    )
                  else
                    ..._logs.take(10).map(
                      (log) => Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            log.note.isEmpty ? '(메모 없음)' : log.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${log.timestamp}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/detail',
                              arguments: log,
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
