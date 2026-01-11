import 'package:flutter/material.dart';
import '../services/log_repository.dart';
import '../ui/tg_style.dart';
import 'tab_map_screen.dart';
import 'tab_feed_screen.dart';
import 'tab_discover_screen.dart';
import 'tab_profile_screen.dart';

class MainShell extends StatefulWidget {
  final LogRepository logRepository;

  const MainShell({super.key, required this.logRepository});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 탭 화면들 정의
    final pages = [
      TabMapScreen(logRepository: widget.logRepository),
      TabFeedScreen(logRepository: widget.logRepository),
      const TabDiscoverScreen(),
      TabProfileScreen(logRepository: widget.logRepository),
    ];

    return Scaffold(
      backgroundColor: TG.bg,
      // 현재 선택된 탭 화면 보여주기
      body: pages[_currentIndex], // SafeArea는 각 탭 내부에서 처리하므로 여기서 뺌

      // ✅ 가운데 + 버튼 (위치 고정)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 10), // 버튼 위치 미세 조정
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: TG.softShadow,
        ),
        child: FloatingActionButton(
          backgroundColor: TG.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          onPressed: () => Navigator.pushNamed(context, '/new'),
          child: const Icon(Icons.add, size: 28),
        ),
      ),

      // ✅ 글로시 pill 하단바 (오버플로우 해결 버전)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 64, // 높이 고정으로 안정성 확보
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: TG.y2kGradient,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
              boxShadow: TG.softShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 공간 균등 배분 변경
              children: [
                _NavIcon(
                  icon: Icons.public,
                  label: 'Map',
                  selected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavIcon(
                  icon: Icons.forum,
                  label: 'Feed',
                  selected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),

                // ✅ 가운데 공간 확보 (유동적으로 조절)
                const SizedBox(width: 48),

                _NavIcon(
                  icon: Icons.trending_up,
                  label: 'Find',
                  selected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavIcon(
                  icon: Icons.person,
                  label: 'My', // Archives -> My로 줄임 (공간 확보)
                  selected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.92) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          // 선택 안 됐을 때는 테두리 없음
          border: selected ? Border.all(color: Colors.black.withOpacity(0.06)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 내용물만큼만 크기 차지
          children: [
            Icon(
              icon,
              size: 24, // 아이콘 크기 약간 키움
              color: selected ? TG.ink : Colors.black45,
            ),
            // ✅ [핵심 수정] 선택되었을 때만 글자를 보여줌! (오버플로우 해결의 열쇠)
            if (selected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TG.ink,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}