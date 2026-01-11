import 'package:flutter/material.dart';
import '../services/log_repository.dart';
import '../services/social_repository.dart';
import '../ui/tg_style.dart';

class TabFeedScreen extends StatefulWidget {
  final LogRepository logRepository;

  const TabFeedScreen({
    super.key,
    required this.logRepository,
  });

  @override
  State<TabFeedScreen> createState() => _TabFeedScreenState();
}

class _TabFeedScreenState extends State<TabFeedScreen> {
  final SocialRepository social = SocialRepository.instance;

  bool _loading = true;
  List<TgPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final posts = await social.getFeedPosts();
    setState(() {
      _posts = posts;
      _loading = false;
    });
  }

  Future<void> _toggleFollow(String userId) async {
    await social.toggleFollow(userId);
    await _refresh(); // feed updates immediately based on following-only rule
  }

  @override
  Widget build(BuildContext context) {
    final following = social.followingUsers;

    return Scaffold(
      backgroundColor: TG.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  const Text(
                    "Feed",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                      boxShadow: TG.softShadow,
                    ),
                    child: Text(
                      "Following: ${social.followingCount}",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const Spacer(),
                  _IconPill(
                    icon: Icons.person_add_alt_1,
                    onTap: () => _openPeopleSheet(context),
                  ),
                  const SizedBox(width: 10),
                  _IconPill(
                    icon: Icons.refresh,
                    onTap: _refresh,
                  ),
                ],
              ),
            ),

            // Following "stories" row
            SizedBox(
              height: 90,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: following.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final u = following[i];
                  return _StoryChip(
                    emoji: u.emoji,
                    name: u.name,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Open ${u.name}'s profile (stub)")),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _posts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              "Your feed is empty.\nFollow people to see their posts here.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.55),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            itemCount: _posts.length,
                            itemBuilder: (context, i) {
                              final p = _posts[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _PostCard(
                                  post: p,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Post detail (stub)")),
                                    );
                                  },
                                  onTapAvatar: () => _openMiniProfile(context, p.user),
                                  onFollowToggle: () => _toggleFollow(p.user.id),
                                  isFollowing: social.isFollowing(p.user.id),
                                ),
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

  void _openMiniProfile(BuildContext context, TgUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final isFollowing = social.isFollowing(user.id);
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: TG.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user.emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(height: 8),
              Text(
                user.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.black.withOpacity(0.08) : TG.ink,
                    foregroundColor: isFollowing ? TG.ink : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    await _toggleFollow(user.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(isFollowing ? "Unfollow" : "Follow"),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _openPeopleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: TG.softShadow,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "People",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                for (final u in social.allUsers)
                  _PeopleRow(
                    user: u,
                    following: social.isFollowing(u.id),
                    onToggle: () async {
                      await _toggleFollow(u.id);
                    },
                  ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ----------------------------- UI ----------------------------- */

class _PostCard extends StatelessWidget {
  final TgPost post;
  final VoidCallback onTap;
  final VoidCallback onTapAvatar;
  final VoidCallback onFollowToggle;
  final bool isFollowing;

  const _PostCard({
    required this.post,
    required this.onTap,
    required this.onTapAvatar,
    required this.onFollowToggle,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: TG.softShadow,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(onTap: onTapAvatar, child: _Avatar(emoji: post.user.emoji)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.user.name,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _timeAgo(post.createdAt),
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _LocationPill(text: post.locationName),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "${post.moodEmoji}  ${post.text}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, height: 1.25),
              ),
              if (post.hasPhoto) ...[
                const SizedBox(height: 12),
                _PhotoStub(),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _TinyPill(text: "❤️ ${post.likes}"),
                  const SizedBox(width: 10),
                  _TinyPill(text: "💬 ${post.comments}"),
                  const Spacer(),
                  _FollowPill(
                    following: isFollowing,
                    onTap: onFollowToggle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowPill extends StatelessWidget {
  final bool following;
  final VoidCallback onTap;

  const _FollowPill({required this.following, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: following ? Colors.black.withOpacity(0.08) : TG.ink,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          following ? "Following" : "Follow",
          style: TextStyle(
            color: following ? TG.ink : Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PeopleRow extends StatelessWidget {
  final TgUser user;
  final bool following;
  final VoidCallback onToggle;

  const _PeopleRow({
    required this.user,
    required this.following,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _Avatar(emoji: user.emoji),
      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w900)),
      trailing: _FollowPill(following: following, onTap: onToggle),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String emoji;
  const _Avatar({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: TG.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 18)),
    );
  }
}

class _LocationPill extends StatelessWidget {
  final String text;
  const _LocationPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          const Icon(Icons.place, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  final String text;
  const _TinyPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _PhotoStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.06),
            Colors.black.withOpacity(0.02),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          "Photo (stub)",
          style: TextStyle(color: Colors.black38, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _StoryChip extends StatelessWidget {
  final String emoji;
  final String name;
  final VoidCallback onTap;

  const _StoryChip({
    required this.emoji,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: TG.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconPill({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: TG.softShadow,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

/* ----------------------------- HELPERS ----------------------------- */

String _timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 60) return "${d.inMinutes}m";
  if (d.inHours < 24) return "${d.inHours}h";
  return "${d.inDays}d";
}
