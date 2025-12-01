import 'package:flutter/material.dart';
import '../services/log_repository.dart';
import '../models/log_entry.dart';

class TabFeedScreen extends StatefulWidget {
  final LogRepository logRepository;

  const TabFeedScreen({super.key, required this.logRepository});

  @override
  State<TabFeedScreen> createState() => _TabFeedScreenState();
}

class _TabFeedScreenState extends State<TabFeedScreen> {
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
      // 익명 공유 on 인 것만 피드에 띄우는 모형
      _logs = logs.where((e) => e.isAnonymous).toList().reversed.toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        title: const Text('익명 피드'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(
                  child: Text('아직 익명으로 공유된 기록이 없어요.\n새 기록에서 익명 공유를 켜보세요.'),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.place ?? '어딘가에서의 순간',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log.note.isEmpty ? '(메모 없음)' : log.note,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              if (log.tags != null && log.tags!.isNotEmpty)
                                Text(
                                  log.tags!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                '익명 · ${log.timestamp}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
