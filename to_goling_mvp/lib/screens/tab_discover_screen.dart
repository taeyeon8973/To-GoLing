import 'package:flutter/material.dart';
import '../ui/tg_style.dart';

class TabDiscoverScreen extends StatelessWidget {
  const TabDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TG.bg,
      appBar: AppBar(
        title: const Text('🔥 Challenges · 👀 Discover · Trends'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SearchPill(),
          const SizedBox(height: 16),

          _SectionTitle('🔥 Challenges Near You (Stanford)'),
          const SizedBox(height: 10),
          _ChallengeCard(
            title: '#skypic',
            subtitle: 'Capture a photo of your day',
            point: 20,
          ),
          const SizedBox(height: 10),
          _ChallengeCard(
            title: '#nicecoffee',
            subtitle: 'Keep track of cool drinks',
            point: 10,
          ),

          const SizedBox(height: 22),
          _SectionTitle('AI-curated articles for you'),
          const SizedBox(height: 10),
          _ArticleCard(
            title: 'Where are people in their 20s gathering in San Francisco today?',
            snippet: 'Cafe and campus uploads spike. Peak around 5 PM.',
            imageUrl: 'https://picsum.photos/seed/tg1/900/600',
          ),
          const SizedBox(height: 12),
          _ArticleCard(
            title: 'Top 3 popular places on rainy days',
            snippet: 'Underground malls, libraries, and exhibitions trend.',
            imageUrl: 'https://picsum.photos/seed/tg2/900/600',
          ),
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TG.glassCard(radius: 999),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: const [
          Icon(Icons.search, color: Colors.black45),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search places / people / vibes',
              style: TextStyle(color: Colors.black45, fontSize: 13),
            ),
          ),
          Icon(Icons.auto_awesome, color: Color(0xFF7AA7FF)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: TG.ink,
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int point;

  const _ChallengeCard({
    required this.title,
    required this.subtitle,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TG.glassCard(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TG.neonBlue, TG.neonPink],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_fire_department, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            '+$point pts',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: TG.ink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: () {},
            child: const Text(
              'Join',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String title;
  final String snippet;
  final String imageUrl;

  const _ArticleCard({
    required this.title,
    required this.snippet,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TG.glassCard(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  snippet,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    FilledButton.tonal(
                      onPressed: () {},
                      child: const Text(
                        'Trend',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
