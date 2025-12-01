import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import '../services/log_repository.dart';

class HomeScreen extends StatefulWidget {
  final LogRepository logRepository;

  const HomeScreen({super.key, required this.logRepository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LogEntry> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await widget.logRepository.getLogs();
    setState(() {
      _logs = logs.reversed.toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToGoLing · 순간 기록'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(
                  child: Text('기록이 없어요!\n오른쪽 아래 + 버튼을 눌러 기록해보세요.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          log.note.isEmpty ? '(메모 없음)' : log.note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle:
                            Text('${log.timestamp}', style: const TextStyle(fontSize: 12)),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/detail',
                          arguments: log,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/new');
          _loadLogs();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

