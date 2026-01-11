import 'dart:io'; // ✅ 파일 처리를 위해 추가
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // ✅ 이미지 피커 추가
import 'package:uuid/uuid.dart';
import '../models/log_entry.dart';
import '../services/log_repository.dart';
import '../services/location_service.dart';
import '../ui/tg_style.dart';

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

  // ✅ 이미지 관련 변수 추가
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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
            '📍 ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';

        if (_placeController.text.isEmpty) {
          _placeController.text =
              '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
        }
      });
    }
  }

  // ✅ 이미지 선택 함수 (카메라/갤러리 선택 모달)
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라로 촬영'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    // TODO: _selectedImage가 있다면 서버에 업로드하거나 경로를 저장하는 로직 필요
    // 현재 LogEntry 모델에는 imagePath 필드가 없으므로, 추후 모델 업데이트가 필요합니다.
    // 예: imagePath: _selectedImage?.path, 

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
    return Scaffold(
      backgroundColor: TG.bg,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('New Moment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ✅ 수정된 사진 업로드 영역 (이미지 전달)
                    _PhotoUploadCard(
                      imageFile: _selectedImage,
                      onTap: _pickImage,
                      onClear: () => setState(() => _selectedImage = null),
                    ),
                    const SizedBox(height: 24),

                    // 장소 입력
                    const _SectionLabel(label: "Where?"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _placeController,
                      decoration: const InputDecoration(
                        hintText: 'Place name or address',
                        prefixIcon: Icon(Icons.place, size: 20, color: Colors.black45),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 6),
                      child: Text(
                        _locationText,
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 메모 입력
                    const _SectionLabel(label: "What happened?"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Share your vibe...',
                        contentPadding: const EdgeInsets.all(18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF7AA7FF), width: 1.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 태그 입력
                    const _SectionLabel(label: "Tags"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. #Chill, #Coffee, #NightView',
                        prefixIcon: Icon(Icons.tag, size: 20, color: Colors.black45),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 익명 공유 스위치
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                        boxShadow: TG.softShadow,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, size: 20, color: TG.ink),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Post Anonymously',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: TG.ink,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                            value: _isAnonymous,
                            activeColor: TG.ink,
                            onChanged: (v) => setState(() => _isAnonymous = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // 하단 저장 버튼
            _BottomSaveButton(
              onPressed: _save,
              isSaving: _saving,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------
// Sub-widgets for UI consistency
// ------------------------------------------------------------------------

// ✅ 사진 업로드 카드 위젯 수정 (이미지 미리보기 기능 추가)
class _PhotoUploadCard extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _PhotoUploadCard({
    required this.imageFile,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: TG.softShadow,
        // 이미지가 있을 경우 배경에 꽉 채우기
        image: imageFile != null
            ? DecorationImage(
                image: FileImage(imageFile!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 이미지가 없을 때만 아이콘과 텍스트 표시
              if (imageFile == null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: TG.softShadow,
                      ),
                      child: const Icon(Icons.add_a_photo, size: 32, color: TG.ink),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap to add photo',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              
              // 이미지가 있을 때 우측 상단에 삭제 버튼 표시
              if (imageFile != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onClear, // 삭제 버튼 클릭 시 초기화
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: TG.ink,
      ),
    );
  }
}

class _BottomSaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSaving;

  const _BottomSaveButton({required this.onPressed, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TG.bg.withOpacity(0),
            TG.bg,
          ],
          stops: const [0.0, 0.3],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: TG.ink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          onPressed: isSaving ? null : onPressed,
          child: isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Record Moment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
        ),
      ),
    );
  }
}