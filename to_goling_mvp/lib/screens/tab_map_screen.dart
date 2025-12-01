import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../services/log_repository.dart';
import '../models/log_entry.dart';

class TabMapScreen extends StatefulWidget {
  final LogRepository logRepository;

  const TabMapScreen({super.key, required this.logRepository});

  @override
  State<TabMapScreen> createState() => _TabMapScreenState();
}

class _TabMapScreenState extends State<TabMapScreen> {
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
      _logs = logs;
      _loading = false;
    });
  }

  // 지도 초기 중심점: 기록이 있으면 그 평균, 없으면 서울대 근처
  latlng.LatLng get _initialCenter {
    final locs = _logs
        .where((e) => e.latitude != null && e.longitude != null)
        .toList();
    if (locs.isEmpty) {
      return latlng.LatLng(37.459882, 126.951905); // 서울대 근처 대충
    }
    final avgLat =
        locs.map((e) => e.latitude!).reduce((a, b) => a + b) / locs.length;
    final avgLng =
        locs.map((e) => e.longitude!).reduce((a, b) => a + b) / locs.length;
    return latlng.LatLng(avgLat, avgLng);
  }

  List<Marker> get _markers {
    final locs = _logs
        .where((e) => e.latitude != null && e.longitude != null)
        .toList();
    if (locs.isEmpty) return [];

    return locs.asMap().entries.map((entry) {
      final index = entry.key;
      final log = entry.value;
      final emoji = index.isEven ? '🦊' : '🐧';

      return Marker(
        point: latlng.LatLng(log.latitude!, log.longitude!),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: GestureDetector(
        onTap: () {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Text(
              log.place ?? '어딘가에서의 순간',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              log.note.isEmpty ? '(메모 없음)' : log.note,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (log.tags != null && log.tags!.isNotEmpty)
              Text(
                log.tags!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 8),
            Text(
              '${log.timestamp}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      this.context, // 바깥 context
                      '/detail',
                      arguments: log,
                    );
                  },
                  child: const Text('전체 기록 보기'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    // 나중에 공유 기능 붙일 자리
                  },
                  child: const Text('공유'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
},

  child: Text(
    emoji,
    style: const TextStyle(fontSize: 28),
  ),
),

      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'AI가 쓴 오늘의 일기',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    _logs.isEmpty
                        ? '오늘 기록된 순간이 아직 없어요.\n오른쪽 아래 + 버튼으로 첫 기록을 남겨보세요.'
                        : '오늘의 일기: 총 ${_logs.length}개의 순간을 기록했어요.\n'
                            '태그와 위치 데이터를 바탕으로 AI가 요약한 문장이 여기에 들어갈 예정입니다. (모형)',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '작년 오늘',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    '작년 오늘의 기록이 없어요.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '지도',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                // 🗺 실제 지도
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.grey.shade200,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _initialCenter,
                      initialZoom: 13,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all &
                            ~InteractiveFlag.rotate, // 회전만 비활성
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.to_goling_mvp',
                      ),
                      if (_markers.isNotEmpty)
                        MarkerLayer(markers: _markers),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      '최근 기록 위치',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
