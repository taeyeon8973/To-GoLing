import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/log_entry.dart';
import '../services/log_repository.dart';
import '../services/location_service.dart';

class NewLogScreen extends StatefulWidget {
  final LogRepository logRepository;

  const NewLogScreen({super.key, required this.logRepository});

  @override
  State<NewLogScreen> createState() => _NewLogScreenState();
}

class _NewLogScreenState extends State<NewLogScreen> {
  final _noteController = TextEditingController();
  final _placeController = TextEditingController();
  final _tagsController = TextEditingController();

  bool _saving = false;
  String _locationText = '위치를 불러오는 중...';
  double? _lat;
  double? _lng;
  bool _isAnonymous = true;

  final _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final pos = await _locationService.getCurrentPosition();
    if (!mounted) return;
    if (pos == null) {
      setState(() {
        _locationText = '위치를 가져올 수 없어요.';
      });
    } else {
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _locationText =
            '위치: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';

        // 장소 입력칸에 기본값으로 위도/경도 넣어두기
        if (_placeController.text.isEmpty) {
          _placeController.text =
              '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
        }
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final log = LogEntry(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      latitude: _lat,
      longitude: _lng,
      note: _noteController.text.trim(),
      place: _placeController.text.trim().isEmpty
          ? null
          : _placeController.text.trim(),
      tags: _tagsController.text.trim().isEmpty
          ? null
          : _tagsController.text.trim(),
      isAnonymous: _isAnonymous,
    );

    await widget.logRepository.addLog(log);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _placeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        centerTitle: true,
        title: const Text('순간 기록하기'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 상단 사진 카드
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '📷 탭하여 촬영/업로드',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 장소 입력
                    Text(
                      '장소',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _placeController,
                      decoration: InputDecoration(
                        hintText: '자동 인식된 장소 또는 직접 입력',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary, width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _locationText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 메모
                    Text(
                      '메모',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '지금 이 순간을 기록해보세요',
                        filled: true,
                        fillColor: Colors.white,
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary, width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 태그
                    Text(
                      '#태그 (쉼표로 구분)',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        hintText: '#카페, #산책, #공부',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary, width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 익명 공유 스위치
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            '익명 공유 (이름 표시 없음)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isAnonymous,
                          onChanged: (v) {
                            setState(() => _isAnonymous = v);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 하단 저장 버튼
            SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('저장'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
