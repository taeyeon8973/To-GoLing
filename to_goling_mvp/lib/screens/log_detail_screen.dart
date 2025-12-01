import 'package:flutter/material.dart';
import '../models/log_entry.dart';

class LogDetailScreen extends StatelessWidget {
  final LogEntry log;

  const LogDetailScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기록 상세')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.timestamp.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (log.place != null && log.place!.isNotEmpty)
              Text(
                '장소: ${log.place}',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            if (log.latitude != null && log.longitude != null)
              Text(
                '좌표: ${log.latitude!.toStringAsFixed(4)}, ${log.longitude!.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Text(
              log.note.isEmpty ? '(메모 없음)' : log.note,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (log.tags != null && log.tags!.isNotEmpty)
              Text(
                '태그: ${log.tags}',
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
              ),
            const Spacer(),
            Text(
              log.isAnonymous
                  ? '익명으로 공유됨'
                  : '프로필 이름과 함께 공유됨',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
