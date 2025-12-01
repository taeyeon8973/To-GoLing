import 'package:flutter/material.dart';

class TabDiscoverScreen extends StatelessWidget {
  const TabDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        title: const Text('루틴 · 발견 · 트렌드'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Seoul 지역 챌린지',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _challengeChip(title: '#하늘사진', subtitle: '오늘 하늘 한 컷', point: 20),
          const SizedBox(height: 8),
          _challengeChip(title: '#동네산책', subtitle: '가까운 골목 기록', point: 10),
          const SizedBox(height: 24),
          const Text(
            'AI 큐레이션 기사',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _articleCard(
            title: '오늘 Seoul 20대는 어디에 모였나?',
            snippet: '카페·학교 주변 업로드 급증. 오후 5시 피크.',
          ),
          const SizedBox(height: 12),
          _articleCard(
            title: '비 오는 날 인기 장소 3',
            snippet: '지하 쇼핑몰·도서관·전시장 트렌드 분석.',
          ),
        ],
      ),
    );
  }

    Widget _challengeChip({
    required String title,
    required String subtitle,
    required int point,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${point}p',   // ← 요 줄만 point로!
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () {},
            child: const Text('참여', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }


  Widget _articleCard({required String title, required String snippet}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            snippet,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: () {},
                child: const Text('트렌드', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {},
                child: const Text('보기', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
